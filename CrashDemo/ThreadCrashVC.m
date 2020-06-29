//
//  ThreadCrashVC.m
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/30.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import "ThreadCrashVC.h"

@interface ThreadCrashVC ()

@end

@implementation ThreadCrashVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self testCase1];
    [self testCase3];
}

// dispatch_group_leave比dispatch_group_enter执行的次数多
// EXC_BAD_INSTRUCTION
- (void)testCase1 {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_leave(group);
}

// 在子线程更新UI
// [reports] Main Thread Checker: UI API called on a background thread: -[UIViewController view]
- (void)testCase2 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.view.backgroundColor = [UIColor redColor];
    });
}

// 多个线程同时释放一个对象
- (void)testCase3 {
    // ==================使用信号量同步后不崩溃==================
//    {
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
//        __block NSObject *obj = [NSObject new];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{while (YES) {
//                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//                obj = [NSObject new];
//                dispatch_semaphore_signal(semaphore);
//            }
//        });while (YES) {
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//            obj = [NSObject new];
//            dispatch_semaphore_signal(semaphore);
//        }
//    }
    // ==================未同步则崩溃==================
    {
        __block NSObject *obj = [[NSObject alloc] init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            while (YES) {
                obj = [[NSObject alloc] init];
            }
        });
        
        while (YES) {
            obj = [[NSObject alloc] init];
        }
    }
}

@end
