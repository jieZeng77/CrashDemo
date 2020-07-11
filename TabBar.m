//
//  TabBar.m
//  ViewControllertransitionDemo
//
//  Created by karl.luo on 16/8/23.
//  Copyright © 2016年 karl.luo. All rights reserved.
//

#import "TabBar.h"
#import "TabBarItem.h"
#import "UIView+HQFrameLayout.h"
#import "CartVC.h"
#import "BaseNavigationController.h"

static NSInteger const kBeginTabBarItemTag = 10000;
@interface TabBar ()

@property (nonatomic, strong) TabBarItem *selectedItem;
@property (nonatomic, strong) NSMutableArray *itemArray;    // 用于保存所有操作项
@property (nonatomic, strong) TabBarItem *bigBarItem;       // 大按钮
@property (nonatomic ,strong) NSTimer *cartCountdownTimer;  // 购物车倒计时
@property (nonatomic ,assign) NSInteger cartCountdown;      // 购物车倒计时时间

@end

@implementation TabBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_bigBarItem != nil && CGRectContainsPoint(_bigBarItem.frame, point)) {   // 大按钮时，设置可操作范围
        return self.bigBarItem;
    }
    return [super hitTest:point withEvent:event];
}

- (void)setTabBarItems:(NSArray *)images selectedImages:(NSArray *)selectedImages titles:(NSArray *)titles defaultIndex:(NSInteger)defaultIndex {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCountDown) name:LogoutNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCountDown) name:EmptyCartNotify object:nil];
    
    if (!isiOS10) {
        UIView *lineView = [UIView new];
        lineView.frame = CGRectMake(0.0, 0.0, self.width, 0.5f);
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineView];
        [self bringSubviewToFront:lineView];
        NSLog(@"%@", lineView);
    }
    
    self.itemArray = [NSMutableArray new];
    CGFloat tabBarItemWidth = self.width / images.count;
    for (NSInteger i = 0; i < images.count; i++) {
        
        BOOL isWZHAction = [ServerInfoSingleton sharedInstance].serverInfo.isWZHAction;
        if (i == 2 && isWZHAction) {
            self.bigBarItem.tag = kBeginTabBarItemTag + i;
            [self addSubview:self.bigBarItem];
            [self.itemArray addObject:self.bigBarItem];
        } else {
            
            TabBarItem *itemButton = [[TabBarItem alloc] init];
            itemButton.frame = CGRectMake(tabBarItemWidth * i, 0.0f, tabBarItemWidth, self.height);
            itemButton.backgroundColor  = [UIColor clearColor];
            itemButton.badgeBackColor   = MainColorForRoseRed;
            itemButton.dotColor         = MainColorForRoseRed;
            itemButton.tag = kBeginTabBarItemTag + i;
            [itemButton setImage:images[i] forState:UIControlStateNormal];
            [itemButton setImage:selectedImages[i] forState:UIControlStateSelected];
            [itemButton setTitle:titles[i] forState:UIControlStateNormal];
            [itemButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [itemButton setTitleColor:MainColorForRoseRed forState:UIControlStateSelected];
            [itemButton addTarget:self action:@selector(tabBarItemClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:itemButton];
            
            if (defaultIndex == i) {
                [self tabBarItemClick:itemButton];
            }
            [self.itemArray addObject:itemButton];
        }
    }
}

- (void)setBadgeValue:(NSString *)badgeValue badgeIndex:(NSInteger)index {
    
    for (TabBarItem *button in self.subviews) {
        if (button.tag - kBeginTabBarItemTag == index) {
            if ([badgeValue isEqual:[NSNull null]]
                || [badgeValue length] <= 0) {
                button.badgeValue = @"0";
            } else {
                button.badgeValue = badgeValue;
            }
        }
    }
}

- (TabBarItem *)bigBarItem {
    if (!_bigBarItem) {
        
        BOOL isWZHAction = [ServerInfoSingleton sharedInstance].serverInfo.isWZHAction;
        
        UIImage *image = [UIImage imageNamed:@"bar_circle_N_hover"];
        if (isWZHAction) {
            NSString *documentsDirectory = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),@"tabIcon@2x.png"];
            image = [UIImage imageWithContentsOfFile:documentsDirectory];
            if (!image) {
                image = [UIImage imageNamed:@"tabIcon_default"];
            }
        }
        _bigBarItem = [[TabBarItem alloc] init];
        _bigBarItem.frame   = CGRectMake(0.0, self.height - image.size.height, image.size.width, image.size.height);
        _bigBarItem.centerX = self.centerX;
        _bigBarItem.backgroundColor = [UIColor clearColor];
        [_bigBarItem setImage:image forState:UIControlStateNormal];
        [_bigBarItem setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_bigBarItem addTarget:self action:@selector(bigBarItemClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bigBarItem;
}

- (void)tabBarItemClick:(TabBarItem *)button {
    
    if (button == self.selectedItem) {
        return;
    }
    
    self.selectedItem.selected = NO;
    button.selected = YES;
    self.selectedItem  = button;
    _selectedIndex = self.selectedItem.tag - kBeginTabBarItemTag;
    
    BOOL isWZHAction = [ServerInfoSingleton sharedInstance].serverInfo.isWZHAction;
    
    if (_selectedIndex == 2 && !isWZHAction) {
        button.hidden = YES;
        [self addSubview:self.bigBarItem];
    } else {
        if (!isWZHAction) {
            if (self.itemArray.count > 3) {
                TabBarItem *circleBarItem = [self.itemArray objectAtIndex:2];
                circleBarItem.hidden    = NO;
            }
            [self.bigBarItem removeFromSuperview];
            self.bigBarItem = nil;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(selectWithTabBar:index:)]) {
        [_delegate selectWithTabBar:self index:self.selectedItem.tag - kBeginTabBarItemTag];
    }
    
    // 给TabBar图片添加动画 打开就可以
    /*
    for (UIView *imageView in button.subviews) {
        if ([imageView isKindOfClass:NSClassFromString(@"UIImageView")]) {
            //需要实现的帧动画,这里根据需求自定义
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
            animation.keyPath = @"transform.scale";
            animation.values = @[@1.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
            animation.duration = 1;
            animation.calculationMode = kCAAnimationCubic;
            //把动画添加上去就OK了
            [imageView.layer addAnimation:animation forKey:nil];
        }
    }
     */
}

- (void)bigBarItemClick {
    if ([ServerInfoSingleton sharedInstance].serverInfo.isWZHAction) {
        [self tabBarItemClick:self.bigBarItem];
        return;
    }
    
    if (self.bigItemClickAction) {
        self.bigItemClickAction();
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    TabBarItem *button =  [self.itemArray objectAtIndex:selectedIndex];
    [self tabBarItemClick:button];
}

- (void)itemIndex:(NSInteger)index isHiden:(BOOL)isHiden {
    TabBarItem *tabBarItem      = [self.itemArray objectAtIndex:index];
    tabBarItem.dotView.hidden   = isHiden;
}

#pragma mark - Add Cart countTime
/*
 *  加入购物车，倒计时处理
 */
- (void)showCountdownWhenAddToCart:(BOOL)isReset
{
    if (isReset) {
        //（倒计时存在，则不重置）
        if (_cartCountdown <= 0) {
            _cartCountdown = [ServerInfoSingleton sharedInstance].serverInfo.cartTime;
        }
    }else{
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        
        // 获取上一次购物车剩余的倒计时间
        NSInteger oldCartCountdown = [userdefault integerForKey:CartCountDown];
        if (oldCartCountdown <= 0) {
            // 已过期，保存新的购物车剩余倒计时
            _cartCountdown = 0;
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:CartCountDown];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
        
        // 获取APP退出的时间
        NSDate *oldData = (NSDate *)[userdefault objectForKey:AppCloseTime];
        if (oldData == nil || ![oldData isKindOfClass:[NSDate class]]) {
            // 已过期，保存新的购物车剩余倒计时
            _cartCountdown = 0;
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:CartCountDown];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
        
        // 当前的时间
        NSDate *now = [NSDate date];
        // 比较两个时间
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit type = NSCalendarUnitSecond;
        NSDateComponents *cmps = [calendar components:type fromDate:oldData toDate:now options:0];
        NSInteger timeDifference = oldCartCountdown - cmps.second;
        if (timeDifference <= 0) {
            // 已过期，保存新的购物车剩余倒计时
            _cartCountdown = 0;
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:CartCountDown];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }else{
            // 进行倒计时
            _cartCountdown = timeDifference;
        }
    }
    
    if (_cartCountdown <= 0) {
        // 已过期，保存新的购物车剩余倒计时
        _cartCountdown = 0;
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:CartCountDown];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    // 保存新的购物车剩余倒计时
    [[NSUserDefaults standardUserDefaults] setObject:@(_cartCountdown) forKey:CartCountDown];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 开始20分钟倒计时
    NSInteger minutes = _cartCountdown / 60;
    minutes = minutes % 60;
    NSInteger seconds = _cartCountdown % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d",(int)minutes,(int)seconds];
    
    [self reSetTabBarItemTitle:timeStr titleColor:MainColorForRoseRed selectedTitleColor:MainColorForRoseRed itemIndex:3];
    
    // 重新启动倒计时
    [_cartCountdownTimer invalidate];
    _cartCountdownTimer = nil;
    
    _cartCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdownStar) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_cartCountdownTimer forMode:UITrackingRunLoopMode];
}

- (void)countdownStar
{
    _cartCountdown--;
    if (_cartCountdown > 0) {
        NSInteger minutes = _cartCountdown / 60;
        minutes = minutes % 60;
        NSInteger seconds = _cartCountdown % 60;
        
        NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d",(int)minutes,(int)seconds];
        [self reSetTabBarItemTitle:timeStr titleColor:MainColorForRoseRed selectedTitleColor:MainColorForRoseRed itemIndex:3];
        
        // 如果购物车视图已存在，则显示倒计时
        CartVC *tabCartVC = [self tabCartVC];
        if (tabCartVC) {
            [tabCartVC showCountdownTime:timeStr];
        }
        
        // 如果购物车视图已存在，则显示倒计时
        CartVC *pushCartVC = [self pushCartVC];
        if (pushCartVC) {
            [pushCartVC showCountdownTime:timeStr];
        }
        
    }else{
        
        [self reSetTabBarItemTitle:@"购物车"
                        titleColor:[UIColor grayColor]
                selectedTitleColor:MainColorForRoseRed
                         itemIndex:3];
        
        _cartCountdown = 0;
        
        // 停掉倒计时
        [_cartCountdownTimer invalidate];
        _cartCountdownTimer = nil;
        
        // 如果购物车视图已存在，则显示倒计时
        CartVC *tabCartVC = [self tabCartVC];
        if (tabCartVC) {
            [tabCartVC showCountdownTime:@""];
        }
        
        // 如果购物车视图已存在，则显示倒计时
        CartVC *pushCartVC = [self pushCartVC];
        if (pushCartVC) {
            [pushCartVC showCountdownTime:@""];
        }
    }
    
    // 保存新的购物车剩余倒计时
    [[NSUserDefaults standardUserDefaults] setObject:@(_cartCountdown) forKey:CartCountDown];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 保存APP退出的时间
- (void)saveTimeWhenAppClose
{
    // 当前的时间
    NSDate *closeTime = [NSDate date];
    // 保存APP退出时间
    [[NSUserDefaults standardUserDefaults] setObject:closeTime forKey:AppCloseTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 获取当前的倒计时时间
- (NSInteger)getCurrentCartCountdown
{
    return _cartCountdown;
}

// 获取TabBar的CartVC
- (CartVC *)tabCartVC
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    TabBarController *tabBarVC = appDelegate.mainTabBarController;
    
    BaseNavigationController *nav = tabBarVC.selectedViewController;
    if ([nav isKindOfClass:[BaseNavigationController class]]) {
        CartVC *vc = [nav.viewControllers firstObject];
        if (vc && [vc isKindOfClass:[CartVC class]]) {
            return vc;
        }
    }
    
    return nil;
}

// 获取Push出来CartVC
- (CartVC *)pushCartVC
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    TabBarController *tabBarVC = appDelegate.mainTabBarController;
    
    BaseNavigationController *nav = tabBarVC.selectedViewController;
    if ([nav isKindOfClass:[BaseNavigationController class]] && nav.viewControllers.count > 1) {
        for (int i = 1; i < nav.viewControllers.count; i++) {
            CartVC *vc = nav.viewControllers[i];
            if (vc && [vc isKindOfClass:[CartVC class]]) {
                return vc;
            }
        }
    }
    
    return nil;
}

- (void)reSetTabBarItemTitle:(NSString *)title
                  titleColor:(UIColor *)titleColor
          selectedTitleColor:(UIColor *)selectedColor
                   itemIndex:(NSInteger)itemIndex
{
    TabBarItem *item = (TabBarItem *)[self viewWithTag:kBeginTabBarItemTag+itemIndex];
    
    if (item) {
        [item setTitle:title forState:UIControlStateNormal];
        [item setTitleColor:titleColor forState:UIControlStateNormal];
        [item setTitleColor:selectedColor forState:UIControlStateSelected];
    }
}

- (void)clearCountDown
{
    _cartCountdown = 0;
}

@end
