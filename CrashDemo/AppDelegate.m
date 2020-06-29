//
//  AppDelegate.m
//  CrashDemo
//
//  Created by 曾杰 on 2020/5/29.
//  Copyright © 2020 曾杰. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UncaughtExceptionHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window setRootViewController:navVC];
    
    [UncaughtExceptionHandler setDefaultHandler];
    
    // 斐波那契数列 f(n) = f(n-1) + f(n-2);
    NSInteger result = [AppDelegate fibonacciWithNum:10];
    NSLog(@"%ld",result);
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[@0,@1]];
    for (int i = 2; i <= 10; i++) {
        NSInteger a = [[array objectAtIndex:i-1] integerValue];
        NSInteger b = [[array objectAtIndex:i-2] integerValue];
        NSInteger result = a + b;
        [array addObject:[NSNumber numberWithInteger:result]];
    }
    NSLog(@"%@",array);
    
    NSInteger min = 0;
    NSInteger max = 1;
    NSLog(@"%ld",min);
    NSLog(@"%ld",max);
    for (int i = 2; i <= 10; i++) {
        NSInteger tmp = min;
        min = max;
        max = min + tmp;
        NSLog(@"%ld",max);
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

+ (NSInteger)fibonacciWithNum:(NSInteger)num {
    if (num <= 0) {
        return 0;
    }
    
    if (num == 1) {
        return 1;
    }
    
    NSInteger result = [AppDelegate fibonacciWithNum:num-1] + [AppDelegate fibonacciWithNum:num-2];
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
