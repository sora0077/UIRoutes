//
//  UIRoutes.h
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/13.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIRoutesSegueProtocol;
@class UIStory;
@interface UIRoutes : NSObject
+ (void)routingOnWindow:(UIWindow *)window;
+ (instancetype)defaultScheme;
+ (instancetype)forScheme:(NSString *)scheme;

+ (NSURL *)topURL;
+ (BOOL)hasStacked:(NSURL *)url;

+ (BOOL)canOpenURL:(NSURL *)url;
+ (void)openURL:(NSURL *)url;
+ (void)openURL:(NSURL *)url wake:(void (^)(UIStoryboardSegue<UIRoutesSegueProtocol> *segue))wake;
+ (void)openURL:(NSURL *)url wake:(void (^)(UIStoryboardSegue<UIRoutesSegueProtocol> *segue))wake completion:(void (^)())completion;
+ (void)openURL:(NSURL *)url completion:(void (^)())completion;


+ (void)pop;
+ (void)popOnWake:(void (^)(UIStoryboardSegue<UIRoutesSegueProtocol> *segue))wake;
+ (void)popOnWake:(void (^)(UIStoryboardSegue<UIRoutesSegueProtocol> *segue))wake completion:(void (^)())completion;
+ (void)popOnCompletion:(void (^)())completion;

+ (void)clear;
+ (void)clearAniamted:(BOOL)animated;
+ (void)clearAniamted:(BOOL)animated dismiss:(void (^)(UIViewController *viewController))dismiss;

- (void)setResolveURLHandler:(BOOL (^)(NSURL *))handler;
- (void)addStory:(UIStory *)story handler:(UIViewController *(^)(NSURL *url, NSDictionary *params))handler;
- (void)unresolved:(UIStory *)story handler:(UIViewController *(^)(NSURL *url))handler;
@end

#pragma mark -
@interface UIStory : NSObject
+ (instancetype)storyWithPattern:(NSString *)pattern segue:(Class)segueClass unwind:(Class)unwindClass;

+ (instancetype)unresolvedStoryWithSegue:(Class)segueClass unwind:(Class)unwindClass;

@end

#pragma mark -
@interface UIApi : UIStory
+ (instancetype)apiWithPattern:(NSString *)pattern;
@end
