//
//  YMFAppDelegate.m
//  YunMoFang
//
//  Created by Talent Wang on 2017/2/6.
//  Copyright © 2017年 Yunyun Network Technology Co.,Ltd. All rights reserved.
//

#import "YMFAppDelegate.h"

#import "YMFUserDefaultsKeys.h"

#import "YMFGuideViewController.h"
#import "YMFLoginViewController.h"
#import "YMFBaseTabBarController.h"
#import "YMFBaseNavigationController.h"

@implementation YMFAppDelegate

#pragma mark - Life cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureWindowRootViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - Register app
- (void)registerApp{
    
}

#pragma mark - Set up user interfaces
- (void)configureWindowRootViewController{
    BOOL isAppFirstLaunch = [self isAppFirstLaunch];
    UIViewController *windowRootViewController = nil;
    if (isAppFirstLaunch) {
        [self recordAppFirstLaunch];
        windowRootViewController = [[YMFGuideViewController alloc] init];
    }
    else{
        windowRootViewController = [[YMFLoginViewController alloc] init];
    }
    self.window.rootViewController = windowRootViewController;
}

#pragma mark - App launch record
- (BOOL)isAppFirstLaunch{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isAppFirstLaunch = ![standardUserDefaults objectForKey:kIsAppFirstLaunchUserDefaultsKey];
    return isAppFirstLaunch;
}

- (BOOL)recordAppFirstLaunch{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:@false forKey:kIsAppFirstLaunchUserDefaultsKey];
    BOOL success = [standardUserDefaults synchronize];
    return success;
}

#pragma mark - Getter
- (UIWindow *)window{
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor whiteColor];
    }
    return _window;
}

@end
