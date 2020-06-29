//
//  Carch_EXC_BAD_ACCESSVC.m
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/30.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import "Carch_EXC_BAD_ACCESSVC.h"
#import <objc/runtime.h>

// 创建一个分类，使用关联方式，实现实例变量
@interface Carch_EXC_BAD_ACCESSVC (AssociatedCatogry)

@property (nonatomic ,strong) UIView *associatedView;

@end

@implementation Carch_EXC_BAD_ACCESSVC (AssociatedCatogry)

- (void)setAssociatedView:(UIView *)associatedView {
    objc_setAssociatedObject(self, @selector(associatedView), associatedView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)associatedView {
    //NSLog(@"temp:%@",_cmd);
    return objc_getAssociatedObject(self, _cmd);
}

@end

@interface Carch_EXC_BAD_ACCESSVC ()

@property (nonatomic ,copy) void(^block)(void);
@property (nonatomic ,weak) UIView *weakView;
@property (nonatomic ,assign) UIView *assignView;
@property (nonatomic ,unsafe_unretained) UIView *unSafeView;

@end

@implementation Carch_EXC_BAD_ACCESSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self testCase1];
//    [self testCase2];
    [self testCase3];
}

// 悬挂指针：访问没有实现的blcok
- (void)testCase1 {
    self.block();
}

// 悬挂指针：对象没有被初始化
- (void)testCase2 {
    UIView* view = [UIView alloc];  // 只alloc，没有init
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
}

/**
 悬挂指针：访问的对象已经被释放掉
 */
- (void)testCase3 {
    {
        UIView* view = [[UIView alloc] init];
        view.backgroundColor = [UIColor blackColor];
        self.weakView = view;
        self.unSafeView = view;
        self.assignView = view;
        self.associatedView = view;
    }
    
    // ARC下weak对象释放后会自动置nil，因此下面的代码不会崩溃
    [self.view addSubview:self.weakView];
    // 野指针场景一：unsafe_unretained修饰的对象释放后，不会自动置nil，变成野指针，因此下面的代码会崩溃
    //[self.view addSubview:self.unSafeView];
    // 野指针场景二：应该使用strong/weak修饰的对象，却错误的使用assign修饰，释放后不会自动置nil
    //[self.view addSubview:self.assignView];
    // 野指针场景三：给类添加添加关联变量的时候，类似场景二，应该使用OBJC_ASSOCIATION_RETAIN_NONATOMIC修饰，却错误使用OBJC_ASSOCIATION_ASSIGN
    [self.view addSubview:self.associatedView];
}

@end
