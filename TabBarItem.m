//
//  B2BVerticalContentButton.m
//  B2BMall
//
//  Created by karl.luo on 16/5/25.
//  Copyright © 2016年 karl.luo. All rights reserved.
//

#import "TabBarItem.h"
#import "UIView+HQFrameLayout.h"

@interface TabBarItem ()

@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation TabBarItem


- (void)drawRect:(CGRect)rect {
    [self.badgeLabel removeFromSuperview];
    [self.dotView removeFromSuperview];
    [self addSubview:self.badgeLabel];
    [self addSubview:self.dotView];
    
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.imageView.contentMode = UIViewContentModeCenter;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.backgroundColor = [UIColor clearColor];
    CGRect imageFrame = [self imageView].frame;
    CGRect titleFrame = [self titleLabel].frame;
    CGFloat space = (self.frame.size.height - 5 - imageFrame.size.height - titleFrame.size.height) / 2;
    // 图标居中
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width / 2;
    
    center.y = self.imageView.frame.size.height / 2 + space + 3;
    self.imageView.center = center;
    
    // 标题居中
    titleFrame.origin.x = 0;
    titleFrame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + 5;
    titleFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = titleFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.imageView.y += _imageBottomMargin;
    
    self.badgeLabel.center  = CGPointMake(CGRectGetMaxX(self.imageView.frame) + 0.0, CGRectGetMidY(self.imageView.frame)-_badgeLabel.height / 2 + 2.0);
    self.dotView.center     = CGPointMake(CGRectGetMaxX(self.imageView.frame) + 0.0f, self.imageView.y + 3.0f);
}

#pragma mark - getter/setter
- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        
        _badgeLabel         = [[UILabel alloc] init];
        _badgeLabel.frame   = CGRectMake(0.0, 0.0, 0.0, 0.0);
        _badgeLabel.backgroundColor     = self.badgeBackColor;
        _badgeLabel.layer.borderWidth   = 1.0f;
        _badgeLabel.layer.borderColor   = self.badgeBorderColor.CGColor;
        _badgeLabel.textColor           = [UIColor whiteColor];
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.textAlignment   = NSTextAlignmentCenter;
        _badgeLabel.font            = [UIFont systemFontOfSize:10.0];
    }
    return _badgeLabel;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 8.0f, 8.0f)];
        _dotView.layer.cornerRadius = _dotView.height / 2;
        _dotView.backgroundColor    = self.dotColor;
        _dotView.hidden = YES;
    }
    return _dotView;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    
    if ([badgeValue integerValue] == 0) {
        self.badgeLabel.frame = CGRectZero;
        return;
    } else if ([badgeValue integerValue] > 99) {
        badgeValue = @"99+";
    }
    
    CGSize badgeSize = [badgeValue length] > 0 ? [badgeValue sizeWithAttributes:@{NSFontAttributeName:self.badgeLabel.font}] : CGSizeZero;
    self.badgeLabel.frame = CGRectMake(self.badgeLabel.x, self.badgeLabel.y, (badgeSize.width > 15.0 && [badgeValue length] > 1) ? (badgeSize.width  + 4) : 15.0, 15.0);
    self.badgeLabel.layer.cornerRadius = self.badgeLabel.frame.size.height / 2;
    self.badgeLabel.text = badgeValue;
    _badgeValue = badgeValue;
}

@synthesize badgeBackColor = _badgeBackColor;
- (UIColor *)badgeBackColor {
    
    if (!_badgeBackColor) {
        _badgeBackColor = [UIColor colorWithRed:0.97 green:0.32 blue:0.43 alpha:1.0];
    }
    return _badgeBackColor;
}

- (void)setBadgeBackColor:(UIColor *)badgeBackColor {
    
    self.badgeLabel.backgroundColor = badgeBackColor;
    _badgeBackColor = badgeBackColor;
    if ([badgeBackColor isEqual:[UIColor whiteColor]]
        || [badgeBackColor isEqual:[UIColor clearColor]]) {
        if (![_badgeBorderColor isEqual:[UIColor whiteColor]]
            && ![_badgeBorderColor isEqual:[UIColor clearColor]]) {
            _badgeLabel.textColor   = _badgeBorderColor;
        } else {
            self.badgeBorderColor   = [UIColor colorWithRed:102.0 / 255.0 green:102.0 / 255.0 blue:102.0 / 255.0 alpha:1.0];
            _badgeLabel.textColor   = _badgeBorderColor;
        }
    } else {
        
        _badgeLabel.textColor   = [UIColor whiteColor];
    }
}

@synthesize dotColor = _dotColor;
- (void)setDotColor:(UIColor *)dotColor {
    _dotColor = dotColor;
    self.dotView.backgroundColor = dotColor;
}

- (UIColor *)dotColor {
    if (!_dotColor) {
        _dotColor = [UIColor colorWithRed:0.97 green:0.32 blue:0.43 alpha:1.0];
    }
    return _dotColor;
}

-(void)setImageBottomMargin:(CGFloat)imageBottomMargin{
    _imageBottomMargin = imageBottomMargin;
}


@synthesize badgeBorderColor = _badgeBorderColor;
- (UIColor *)badgeBorderColor {
    
    if (!_badgeBorderColor) {
        _badgeBorderColor = [UIColor clearColor];
    }
    return _badgeBorderColor;
}

- (void)setBadgeBorderColor:(UIColor *)badgeBorderColor {
    
    self.badgeLabel.layer.borderColor = badgeBorderColor.CGColor;
    _badgeBorderColor = badgeBorderColor;
    if ([_badgeBackColor isEqual:[UIColor whiteColor]]
        || [_badgeBackColor isEqual:[UIColor clearColor]]) {
        
        _badgeLabel.textColor   = badgeBorderColor;
    }
}

@end
