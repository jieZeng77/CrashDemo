//
//  ViewController.m
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/29.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import "ViewController.h"
#import "UnrecognizedSelectorVC.h"
#import "KVCCrashVC.h"
#import "KVOCrashVC.h"
#import "Carch_EXC_BAD_ACCESSVC.h"
#import "ThreadCrashVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // unrecognized selector sent to instance
    
    CGFloat kwSize = [UIScreen mainScreen].bounds.size.width;
    CGFloat tmpY = 100;
    NSArray *arr = @[@"unrecognized selector sent",@"KVC Crash",@"KVO Crash",@"EXC_BAD_ACCESS,malloc的对象或者越界访问",@"多线程中的崩溃"];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(15, tmpY, kwSize-30, 40);
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.backgroundColor = [UIColor brownColor];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnDone:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btn.tag = 1000+i;
        tmpY += 50;
    }
}


- (void)btnDone:(UIButton *)btn {
    NSInteger index = btn.tag - 1000;
    switch (index) {
        case 0:
        {
            UnrecognizedSelectorVC *vc = [[UnrecognizedSelectorVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            KVCCrashVC *vc = [[KVCCrashVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            case 2:
            {
                KVOCrashVC *vc = [[KVOCrashVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 3:
            {
                Carch_EXC_BAD_ACCESSVC *vc = [[Carch_EXC_BAD_ACCESSVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 4:
            {
                ThreadCrashVC *vc = [[ThreadCrashVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
    }
}

@end
