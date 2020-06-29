//
//  UnrecognizedSelectorVC.h
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/29.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 代理协议
@protocol UnrecognizeSelectorObjcDelegate <NSObject>

@optional
- (void)notImplementionFunc;

@end

// 测试控制器的代理对象
@interface UnrecognizedSelectorObjc : NSObject

@property (nonatomic ,weak) id<UnrecognizeSelectorObjcDelegate> delegate;
@property (nonatomic ,strong) NSString *name;

@end

// 测试控制器
@interface UnrecognizedSelectorVC : UIViewController

@property (nonatomic ,copy) NSMutableArray *mutableArray;

@end

NS_ASSUME_NONNULL_END
