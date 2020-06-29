//
//  UncaughtExceptionHandler.h
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/30.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UncaughtExceptionHandler : NSObject{
    BOOL dismissed;
}

//@property (nonatomic ,assign) BOOL dismissed;

#pragma mark - OC 部分
/*
 开启crash信息收集
 */
+ (void)setDefaultHandler;
/*
 写入日志
 未上传的日志文件路劲：Document/Exception 文件名：UnUpload_时间.txt
*/
+ (void)writeException:(NSString *)exceptionString;
/*
 上传日志
 每次上传一个rCrash日志 上传完毕的日志会转移到Document/Exception/Uploaded文件夹下
 并且修改文件名
 */
+ (void)checkAndSendException;

@end

#pragma mark - C++部分
void InstallUncaughtExceptionHandler(void);

NS_ASSUME_NONNULL_END
