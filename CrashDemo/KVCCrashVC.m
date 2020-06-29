//
//  KVCCrashVC.m
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/30.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import "KVCCrashVC.h"

@interface KVCCrashModel : NSObject
@property (nonatomic ,strong) NSString *name;
@end

@implementation KVCCrashModel

// 解决case1
//- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key {
//
//}



@end


@interface KVCCrashVC ()

@end

@implementation KVCCrashVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self testCase1];
    [self testCase2];
    
}

// KVC，设置了不存在的key
- (void)testCase1 {
    KVCCrashModel *model = [[KVCCrashModel alloc] init];
    [model setValue:@"value" forKey:@"key"];
    
    // 解决，实现
    // - (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key
}

// KVC，设置key = nil crash; value = nil, normal
- (void)testCase2 {
    KVCCrashModel *model = [[KVCCrashModel alloc] init];
    
    // value 为nil不会崩溃
    [model setValue:nil forKey:@"name"];
    
    // key为nil会崩溃（直接写nil编译器会提示警告，更多时候我们传的是变量）
    NSString *tmp;
    [model setValue:@"value" forKey:tmp];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
