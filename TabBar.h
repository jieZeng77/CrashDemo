//
//  TabBar.h
//  ViewControllertransitionDemo
//
//  Created by karl.luo on 16/8/23.
//  Copyright © 2016年 karl.luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabBar;
@protocol TabBarDelegate <NSObject>

@required
- (void)selectWithTabBar:(TabBar *)tabBar index:(NSUInteger)index;

@end

@interface TabBar : UIView

@property (nonatomic, weak) id<TabBarDelegate>delegate;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) void(^bigItemClickAction)();
/**
 *  设置TabBarItem
 *
 *  @param items        UITabBarItem集合
 *  @param defaultIndex 默认的选项
 */
- (void)setTabBarItems:(NSArray *)images selectedImages:(NSArray *)selectedImages titles:(NSArray *)titles defaultIndex:(NSInteger)defaultIndex;
/**
 *  设置显示数字
 *
 *  @param badgeValue 数字值
 *  @param index      要设置TabBarItem数字索引
 */
- (void)setBadgeValue:(NSString *)badgeValue badgeIndex:(NSInteger)index;
/**
 *  红色点标记操作
 *
 *  @param index   操作Item索引
 *  @param isHiden 是否隐藏
 */
- (void)itemIndex:(NSInteger)index isHiden:(BOOL)isHiden;

/**
 *  加入购物车／APP启动，购物车TabItem倒计时处理
 *
 *  @param isReset        是否需要重置倒计时
 */
- (void)showCountdownWhenAddToCart:(BOOL)isReset;

/**
 *  保存APP退出的时间
 */
- (void)saveTimeWhenAppClose;

/**
 *  获取当前的倒计时时间
 */
- (NSInteger)getCurrentCartCountdown;

@end
