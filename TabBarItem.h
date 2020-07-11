//
//  B2BVerticalContentButton.h
//  B2BMall
//
//  Created by karl.luo on 16/5/25.
//  Copyright © 2016年 karl.luo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief 图标文字垂直居中(带数量标识)
 */
@interface TabBarItem : UIButton

@property (nonatomic, copy) NSString *badgeValue;               // 数量标识，当为0时不显示
@property (nonatomic, strong) UIColor *badgeBackColor;          // 标识的背景颜色，默认玫红色
@property (nonatomic, strong) UIColor *badgeBorderColor;        // 标识的边框颜色，默认没有颜色
@property (nonatomic, assign) CGFloat imageBottomMargin;        // 设置图片底部距离文字底部的距离

@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, strong) UIColor *dotColor;                // 点标记颜色

@end
