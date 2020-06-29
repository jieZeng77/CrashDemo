//
//  UnrecognizedSelectorVC.m
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/29.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import "UnrecognizedSelectorVC.h"

@interface UnrecognizedSelectorObjc ()

- (void)actionTest;

@end

@implementation UnrecognizedSelectorObjc

- (void)actionTest {
    [self.delegate notImplementionFunc];
}
@end



@interface UnrecognizedSelectorVC ()<UnrecognizeSelectorObjcDelegate>

@end

@implementation UnrecognizedSelectorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self case1];
}

// 场景一，没有实现代理
- (void)case1 {
    UnrecognizedSelectorObjc *tmpObj = [[UnrecognizedSelectorObjc alloc]init];
    tmpObj.delegate = self;
    [tmpObj actionTest];
}

#pragma mark - <UnrecognizeSelectorObjcDelegate>
//- (void)notImplementionFunc {
//
//}

@end
