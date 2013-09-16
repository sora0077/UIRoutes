//
//  UIAppDelegate.m
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/13.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "UIAppDelegate.h"

#import "UIRoutes.h"
#import "UIModalSegue.h"
#import "UIPushSegue.h"
#import "UIPushElseModalSegue.h"

#import "DemoViewController.h"

@implementation UIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    UIViewController *viewController = [DemoViewController new];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];

    [UIRoutes routingOnWindow:self.window];

    {

    UIStory *story = [UIStory storyWithPattern:@"push/user/:id" segue:[UIPushElseModalSegue class] unwind:[UIPushElseModalUnwindSegue class]];

    [[UIRoutes defaultScheme] addStory:story handler:^UIViewController *(NSURL *url, NSDictionary *params) {
        NSLog(@"%@ %@", url, params);
        UIViewController *viewController = [DemoViewController new];
        viewController.view.backgroundColor = [UIColor greenColor];
        return viewController;
    }];
    }
    {

    UIStory *story = [UIStory storyWithPattern:@"push/profile/:id" segue:[UIModalSegue class] unwind:[UIModalUnwindSegue class]];

    [[UIRoutes defaultScheme] addStory:story handler:^UIViewController *(NSURL *url, NSDictionary *params) {
        NSLog(@"%@ %@", url, params);
        UIViewController *viewController = [DemoViewController new];
        viewController.view.backgroundColor = [UIColor blueColor];
        return viewController;
    }];
    }

    UIStory *unresolved = [UIStory unresolvedStoryWithSegue:[UIModalSegue class] unwind:[UIModalUnwindSegue class]];
    [[UIRoutes defaultScheme] unresolved:unresolved handler:^UIViewController *(NSURL *url) {
        NSLog(@"%@", url);
        UIViewController *viewController = [DemoViewController new];
        viewController.view.backgroundColor = [UIColor redColor];
        return viewController;
    }];

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIRoutes openURL:[NSURL URLWithString:@"myapp://push/user/16"]];

        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIRoutes openURL:[NSURL URLWithString:@"myapp://push/profile/16"]];
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIRoutes pop];
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [UIRoutes pop];
                    double delayInSeconds = 2.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [UIRoutes openURL:[NSURL URLWithString:@"myapp://teszt"]];
                    });
                });
            });
        });
    });
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([UIRoutes canOpenURL:url]) {
        [UIRoutes openURL:url];
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
