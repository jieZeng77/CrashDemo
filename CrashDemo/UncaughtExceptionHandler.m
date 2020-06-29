//
//  UncaughtExceptionHandler.m
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/30.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#include <execinfo.h>
#include <libkern/OSAtomic.h>
#import "sys/utsname.h"
#import <Security/Security.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#pragma mark - UncaughtExceptionHandler实现
static NSString *ExceptionFileName = @"Exception";
static NSString *FilePrex = @"NoUpload_";
static NSString *kCrashFileUploadedTime = @"CrashFileUploadedLastTime";
static int MaxCountOfUploadedCrashFile = 10;
 
void handleException(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = exception.reason;
    NSString *name = exception.name;
    
    NSString *exceptionString = [NSString stringWithFormat:@"name:              %@\n"
                                 "reason:             %@\n\n"
                                 "callStackSymbols:\n%@",
                                 name,
                                 reason,
                                 [arr componentsJoinedByString:@"\n"]];
    [UncaughtExceptionHandler writeException:exceptionString];
}
 
@implementation UncaughtExceptionHandler
 
#pragma mark -  开启Crash日志 + 收集
//开启日志监测功能
+ (void)setDefaultHandler {
    NSSetUncaughtExceptionHandler (&handleException);
}
 
/*
    将日志写入 Document 文件夹下
    一个Crash日志信息 对应一个 .txt文件
 */
+ (void)writeException:(NSString *)string {
    NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *strAppBuild = [NSString stringWithFormat:@"V%@ (%@)",
                             [dicInfo objectForKey:@"CFBundleShortVersionString"],
                             [dicInfo objectForKey:@"CFBundleVersion"]
                             ];
    //可以添加一些用户的相关信息 uid mobile等
    NSString *exceptionString = [NSString stringWithFormat:@"=============异常崩溃报告=============\n"
                                 "version:            %@\n"
                                 "deviceType:         %@\n"
                                 "IOS Ver:            %@\n"
                                 "availableMemory:    %.1fMB\n"
                                 "usedMemory:         %.1fMB\n"
                                 "time:               %@\n"
                                 "%@",
                                 strAppBuild,
                                 [UncaughtExceptionHandler getDeviceName],
                                 [UncaughtExceptionHandler deviceIOSSystemDesc],
                                 [UncaughtExceptionHandler availableMemory],
                                 [UncaughtExceptionHandler usedMemory],
                                 [UncaughtExceptionHandler getTimeStr],
                                 string];
    
    NSString *folderPath = [self getExceptionStorePath];
    if (folderPath.length > 0) {
        NSString *sFile = [self getFullExceptionFileName];
        NSString *filePath = [folderPath stringByAppendingPathComponent:sFile];
        [exceptionString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}
 
#pragma mark -  上传日志
//模拟 发送日志 （一次发送一个txt）
+ (void)checkAndSendException {
    
#if TARGET_IPHONE_SIMULATOR//模拟器
 //do nothing
#elif TARGET_OS_IPHONE//真机
    
    //1小时内不再上传
    NSTimeInterval fNow = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval fLast = [[NSUserDefaults standardUserDefaults] doubleForKey:kCrashFileUploadedTime];
    if (fLast > 0 && (fNow - fLast) < 1*60*60) {
        NSLog(@"距上次崩溃日志上传时间尚未1小时：%f秒", (fNow - fLast));
        return;
    }
    
    //取最新一个日志文件
    NSArray* arrCrashFiles = [self getAllUnuploadedCrashFiles];
    if (arrCrashFiles.count <= 0)
    {
        NSLog(@"没有需要上传的崩溃日志文件");
        return;
    }
    
    NSString* sLastCrashFile = arrCrashFiles.lastObject;
    NSString* excpDir = [self getExceptionStorePath];
    NSString* filePath = [excpDir stringByAppendingPathComponent:sLastCrashFile];
    NSError *error;
    NSString *dataString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error){
        NSLog(@"读取崩溃日志文件内容时失败。文件名：%@， 原因：%@", sLastCrashFile, error.localizedDescription);
        return;
    }
    
    //模拟网络请求 发送日志
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //记录上传成功的时间
        NSTimeInterval fTime = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setDouble:fTime forKey:kCrashFileUploadedTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //移到成功目录
        [self moveCrashFileToUploadedDir:sLastCrashFile];
        //检测成功目录中的崩溃日志文件，过多就要删除
        [self restrictExeceptionFileCount];
    });
    
#endif
}
 
#pragma mark -  日志文件路径
//构造Crash文件 完整路径
+ (NSString*) getFullExceptionFileName {
    //NoUpload_Excetipion_2016-10-10_12-00-32.txt
    NSString* sFileName = [NSString stringWithFormat:@"%@%@_%@.txt",
                           FilePrex,
                           ExceptionFileName,
                           [self getTimeStr]
                           ];
    return sFileName;
}
 
//获取异常文件夹 Document下 构造一个 Exception文件夹
+ (NSString *)getExceptionStorePath {
    NSString *documentsPath = [UncaughtExceptionHandler getDocumentPath];
    NSString *exceptionPath = [documentsPath stringByAppendingPathComponent:@"Exception"];
    if ([UncaughtExceptionHandler assurePathExisted:exceptionPath]){
        return exceptionPath;
    }
    else {
        NSLog(@"崩溃日志文件目录创建失败！");
        return nil;
    }
}
 
//Doucment
+ (NSString *)getDocumentPath {
    NSString* sHomeDir = NSHomeDirectory();
    NSString* logDataPath = [sHomeDir stringByAppendingPathComponent:@"Documents"];
    return logDataPath;
}
 
+ (NSString *)getCrashFilesUpladedStorePath {
    NSString *exceptionPath = [self getExceptionStorePath];
    if (!exceptionPath) {
        return nil;
    }
    
    NSString *exceptionUpladedPath = [exceptionPath stringByAppendingPathComponent:@"Uploaded"];
    if ([UncaughtExceptionHandler assurePathExisted:exceptionUpladedPath]) {
        return exceptionUpladedPath;
    }
    else {
        NSLog(@"崩溃日志文件上传目录创建失败！");
        return nil;
    }
}
 
#pragma mark -  相关
 
+(BOOL) assurePathExisted:(NSString*)sPath {
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:sPath isDirectory:&isDir]) {
        return YES;
    }
    else {
        if ([sPath length] <= 0) {
            return NO;
        }
        BOOL bResult = [[NSFileManager defaultManager] createDirectoryAtPath:sPath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:nil];
        if (!bResult) {
            NSLog(@"创建目录失败：%@", sPath);
        }
        return bResult;
    }
}
 
+ (NSString *)getTimeStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss.SSS"];
    return [dateFormatter stringFromDate:[NSDate date]];
}
 
//文件不能太多
+ (BOOL) restrictExeceptionFileCount {
    //崩溃日志目录检查
    NSString* exceptionPath = [self getCrashFilesUpladedStorePath];
    if (!exceptionPath) {
        return YES;
    }
    //取得崩溃文件列表
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError* err = nil;
    NSArray *arrFiles = [fileMgr contentsOfDirectoryAtPath:exceptionPath error:&err];
    if (!arrFiles || err != nil) {
        if (err) {
            NSLog(@"遍历目录失败：%@", err.localizedDescription);
        }
        return NO;
    }
    //排序
    NSArray *arrSortedFiles = [arrFiles sortedArrayUsingComparator:^(NSString* file1, NSString* file2)
                               {
                                   return [file1 compare:file2 options:NSNumericSearch];
                               }];
    
    BOOL bRes = YES;
    NSUInteger nShouldRemoveCount = arrSortedFiles.count > MaxCountOfUploadedCrashFile ? (arrSortedFiles.count - MaxCountOfUploadedCrashFile) : 0;
    for (NSUInteger i = 0; i < nShouldRemoveCount; i ++) {
        NSString* file = [arrSortedFiles firstObject];
        NSString *filepath = [exceptionPath stringByAppendingPathComponent:file];
        
        NSError* err = nil;
        bRes &= [fileMgr removeItemAtPath:filepath error:&err];
        if (err) {
            NSLog(@"删除旧崩溃日志文件失败：%@", err.localizedDescription);
        }
    }
    
    return bRes;
}
 
//获取未上传文件列表，并排好序
+ (NSArray*) getAllUnuploadedCrashFiles {
    NSMutableArray* arrRes = [NSMutableArray array];
    //崩溃日志目录检查
    NSString* exceptionPath = [self getExceptionStorePath];
    if (!exceptionPath) {
        return arrRes;
    }
    
    //取得崩溃文件列表
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError* err = nil;
    NSArray *arrFiles = [fileMgr contentsOfDirectoryAtPath:exceptionPath error:&err];
    if (!arrFiles || err != nil) {
        if (err) {
            NSLog(@"遍历目录失败：%@", err.localizedDescription);
        }
        return arrRes;
    }
    
    //遍历未上传崩溃文件
    NSMutableArray* arrUnuploadFiles = [NSMutableArray array];
    for (NSString* sFile in arrFiles) {
        //过滤子目录
        BOOL isDir;
        NSString* sFilePath = [exceptionPath stringByAppendingPathComponent:sFile];
        if ([fileMgr fileExistsAtPath:sFilePath isDirectory:&isDir] && isDir) {
            continue;
        }
        
        //匹配”NoUpload_“前缀
        NSRange rng = [sFile rangeOfString:FilePrex];
        if (rng.location == 0 && rng.length != NSNotFound) {
            [arrUnuploadFiles addObject:sFile];
        }
        else {
            //上传过的，全部移到已经上传目录
            rng = [sFile rangeOfString:ExceptionFileName];
            if (rng.location == 0 && rng.length != NSNotFound) {
                [self moveCrashFileToUploadedDir:sFile];
            }
        }
    }
    //排序
    NSArray *arrSortedFiles = [arrUnuploadFiles sortedArrayUsingComparator:^(NSString* file1, NSString* file2){
        //改成按名称中的时间排序
        return [file1 compare:file2 options:NSNumericSearch];
    }];
    [arrRes addObjectsFromArray:arrSortedFiles];
    return arrRes;
}
 
//将崩溃文件移到已上传目录
+(BOOL) moveCrashFileToUploadedDir:(NSString*)sFile {
    //匹配”NoUpload_“前缀
    NSString* sNewFile = sFile;
    NSRange rng = [sFile rangeOfString:FilePrex];
    if (rng.location == 0 && rng.length != NSNotFound) {
        NSUInteger fromIdx = rng.location + rng.length;
        sNewFile = [sFile substringFromIndex:fromIdx];
    }
 
    //移到已经上传目录
    BOOL bRes = NO;
    rng = [sNewFile rangeOfString:ExceptionFileName];
    if (rng.location == 0 && rng.length != NSNotFound) {
        //崩溃日志目录检查
        NSString* exceptionPath = [self getExceptionStorePath];
        NSString* uploadPath = [self getCrashFilesUpladedStorePath];
        
        NSString* thisFilePath = [exceptionPath stringByAppendingPathComponent:sFile];
        NSString *newFilePath = [uploadPath stringByAppendingPathComponent:sNewFile];
        
        NSError* errMove = nil;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        bRes = [fileMgr moveItemAtPath:thisFilePath toPath:newFilePath error:&errMove];
        if(errMove) {
            NSLog(@"移动崩溃日志文件失败：file=%@", sFile);
        }
    }
    
    return bRes;
}
 
#pragma mark - 设备相关信息
//获取设备信息
+ (NSString *)getDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}
 
//IOS版本
+(NSString*) deviceIOSSystemDesc {
    NSString* sIos = [[UIDevice currentDevice] systemName]; // "iPhone OS"
    NSString* sIosVer = [[UIDevice currentDevice] systemVersion]; // "5.1.1"
    return [NSString stringWithFormat:@"%@ %@", sIos, sIosVer];
}
 
 
// 获取当前设备可用内存(单位：MB）
+ (double)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return 0;
    }
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}
 
// 获取当前任务所占用的内存（单位：MB）
+ (double)usedMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return 0;
    }
    return taskInfo.resident_size / 1024.0 / 1024.0;
}
 
 
#pragma mark - 阻止应用崩溃直接输出错误日志便于定位问题
//阻止应用崩溃直接输出错误日志便于定位问题
NSString *const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString *const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString *const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
 
volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;
 
const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;
 
 
+ (NSArray *)backtrace {
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}
 
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
    if (anIndex == 0) {
        dismissed = YES;
    }
}
 
- (void)handleExceptionToPreventCrash:(NSException *)exception {
    NSString *message = [NSString stringWithFormat:@"如果点击继续，程序有可能会出现其他的问题，建议您还是点击退出按钮并重新打开\n\n"@"异常原因如下:\n%@\n%@", exception.reason,exception.userInfo[UncaughtExceptionHandlerAddressesKey]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"抱歉，程序出现了异常"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"退出"
                                         otherButtonTitles:@"继续", nil];
    
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT,SIG_DFL);
    signal(SIGILL,SIG_DFL);
    signal(SIGSEGV,SIG_DFL);
    signal(SIGFPE,SIG_DFL);
    signal(SIGBUS,SIG_DFL);
    signal(SIGPIPE,SIG_DFL);
    
    if ([exception.name isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [exception.userInfo[UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else {
        [exception raise];
    }
}
 
@end
 
#pragma mark - C++部分
 
void CatchException(NSException *exception) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
    userInfo[UncaughtExceptionHandlerAddressesKey] = callStack;
    
    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleExceptionToPreventCrash:)
                                                              withObject:[NSException exceptionWithName:exception.name reason:exception.reason userInfo:userInfo]
                                                           waitUntilDone:YES];
}
 
void SignalHandler(int signal) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo = [@{UncaughtExceptionHandlerSignalKey : @(signal)} mutableCopy];
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    userInfo[UncaughtExceptionHandlerAddressesKey] = callStack;
    
    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleExceptionToPreventCrash:)
                                                              withObject:[NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                                                                                 reason:[NSString stringWithFormat:@"Signal %d was raised.", signal]
                                                                                               userInfo:@{UncaughtExceptionHandlerSignalKey : @(signal)}]
                                                           waitUntilDone:YES];
}
 
extern void InstallUncaughtExceptionHandler(void) {
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSSetUncaughtExceptionHandler(&CatchException);
#elif TARGET_OS_IPHONE//真机
    NSSetUncaughtExceptionHandler(&CatchException);
    signal(SIGABRT,SignalHandler);
    signal(SIGILL,SignalHandler);
    signal(SIGSEGV,SignalHandler);
    signal(SIGFPE,SignalHandler);
    signal(SIGBUS,SignalHandler);
    signal(SIGPIPE,SignalHandler);
#endif
}
