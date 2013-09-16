//
//  UIRoutes.h
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/13.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UIStory;
@interface UIRoutes : NSObject
+ (void)routingOnWindow:(UIWindow *)window;
+ (instancetype)defaultScheme;
+ (instancetype)forScheme:(NSString *)scheme;

+ (BOOL)canOpenURL:(NSURL *)url;
+ (void)openURL:(NSURL *)url;
+ (void)openURL:(NSURL *)url wake:(void (^)(UIStoryboardSegue *segue))wake;

+ (void)pop;
+ (void)popOnWake:(void (^)(UIStoryboardSegue *segue))wake;

- (void)addStory:(UIStory *)story handler:(UIViewController *(^)(NSURL *url, NSDictionary *params))handler;
- (void)unresolved:(UIStory *)storyy handler:(UIViewController *(^)(NSURL *url))handler;
@end


@interface UIStory : NSObject
+ (instancetype)storyWithPattern:(NSString *)pattern segue:(Class)segueClass unwind:(Class)unwindClass;

+ (instancetype)unresolvedStoryWithSegue:(Class)segueClass unwind:(Class)unwindClass;

@end
