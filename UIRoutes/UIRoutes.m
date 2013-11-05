//
//  UIRoutes.m
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/13.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "UIRoutes.h"

@interface UIStory () <NSCopying>
@property (nonatomic, copy) UIViewController *(^handler)(NSURL *url, NSDictionary *params);

@property (nonatomic, weak) UIViewController *presentedViewController;
@property (nonatomic, weak) UIViewController *presentingViewController;

- (UIStoryboardSegue *)prepareSegue:(UIViewController *)destination from:(UIViewController *)source;
- (UIStoryboardSegue *)prepareUnwind:(UIViewController *)source to:(UIViewController *)destination;

- (NSDictionary *)parameterForURL:(NSURL *)url;
@end

static UIWindow *_routingWindow;

@implementation UIRoutes
{
    NSMutableArray *_stories;
    UIStory *_unresolvedStory;
}

+ (NSMutableArray *)stacks
{
    static NSMutableArray *stacks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stacks = [NSMutableArray new];
    });
    return stacks;
}

+ (NSMutableDictionary *)routes
{
    static NSMutableDictionary *routes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routes = [NSMutableDictionary new];
    });
    return routes;
}

+ (instancetype)defaultScheme
{
    static UIRoutes *route;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *scheme = [NSBundle mainBundle].infoDictionary[@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
        route = [self forScheme:scheme];
    });
    return route;
}

+ (instancetype)forScheme:(NSString *)scheme
{
    UIRoutes *route = [self routes][scheme];
    if (route == nil) {
        route = [[self alloc] initWithScheme:scheme];
        [[self routes] setObject:route forKey:scheme];
    }
    return route;
}

- (id)initWithScheme:(NSString *)scheme
{
    self = [super init];
    if (self) {
        _stories = [NSMutableArray new];
    }
    return self;
}

- (void)addStory:(UIStory *)story handler:(UIViewController *(^)(NSURL *, NSDictionary *))handler
{
    if (story.handler == nil && handler) {
        story.handler = handler;
    }
    [_stories addObject:story];
}

- (void)unresolved:(UIStory *)story handler:(UIViewController *(^)(NSURL *))handler
{
    if (handler) {
        story.handler = ^UIViewController *(NSURL *url, NSDictionary *params) {
            return handler(url);
        };
    }
    _unresolvedStory = story;
}

+ (BOOL)canOpenURL:(NSURL *)url
{
    UIRoutes *route = [[self class] routes][url.scheme];
    return [route canOpenURL:url];
}

+ (void)openURL:(NSURL *)url
{
    [self openURL:url wake:nil];
}

+ (void)openURL:(NSURL *)url wake:(void (^)(UIStoryboardSegue *))wake
{
    UIRoutes *route = [[self class] routes][url.scheme];
    [route openURL:url wake:wake];
}

+ (void)pop
{
    [self popOnWake:nil];
}

+ (void)popOnWake:(void (^)(UIStoryboardSegue *))wake
{
    if ([self stacks].count) {
        UIStory *story = [self stacks].lastObject;
        [[self stacks] removeLastObject];
        UIViewController *source = story.presentedViewController;
        UIViewController *destination = story.presentingViewController;
        BOOL isVisible = source.isViewLoaded && source.view.window;
        if (source && destination && isVisible) {
            UIStoryboardSegue *unwind = [story prepareUnwind:source to:destination];
            if (wake) {
                wake(unwind);
            }

            [unwind perform];
        } else {
            [self popOnWake:wake];
        }
    }
}

+ (void)clear
{
    [self clearAniamted:NO];
}

+ (void)clearAniamted:(BOOL)animated
{
    [self clearAniamted:animated dismiss:nil];
}

+ (void)clearAniamted:(BOOL)animated dismiss:(void (^)(UIViewController *))dismiss
{
//    UIStory *story = [self stacks].lastObject;
//    UIViewController *currentViewController = story.presentedViewController;
    [[self stacks] removeAllObjects];
    UIViewController *topViewController = [self stackedController];
    if (topViewController.presentedViewController) {
        if (dismiss) {
            dismiss(topViewController);
        } else {
            [topViewController dismissViewControllerAnimated:animated completion:nil];
        }
        animated = NO;
    }
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (id)topViewController;
        [navController popToRootViewControllerAnimated:animated];
    }
}

+ (UIViewController *)stackedController
{
    if ([self stacks].count) {
        UIStory *story = [self stacks].lastObject;
        UIViewController *viewController = story.presentedViewController;
        BOOL isVisible = viewController.isViewLoaded && viewController.view.window;
        if (viewController && isVisible) {
            return viewController;
        }
        [[self stacks] removeLastObject];
        return [self stackedController];
    }
    return _routingWindow.rootViewController;
}

+ (void)routingOnWindow:(UIWindow *)window
{
    _routingWindow = window;
}

- (BOOL)canOpenURL:(NSURL *)url
{
    for (UIStory *story in _stories) {
        NSDictionary *params = [story parameterForURL:url];
        if (params) {
            return YES;
        }
    }
    if (_unresolvedStory) {
        return YES;
    }
    return NO;
}

- (void)openURL:(NSURL *)url
{
    [self openURL:url wake:nil];
}

- (void)openURL:(NSURL *)url wake:(void (^)(UIStoryboardSegue *))wake
{
    for (UIStory *story in _stories) {
        NSDictionary *params = [story parameterForURL:url];
        if (params) {
            [self performSegueWithStory:story url:url parameter:params wake:wake];
            return;
        }
    }
    if (_unresolvedStory) {
        [self performSegueWithStory:_unresolvedStory url:url parameter:nil wake:wake];
    }
}

- (BOOL)performSegueWithStory:(UIStory *)story url:(NSURL *)url parameter:(NSDictionary *)params wake:(void (^)(UIStoryboardSegue *))wake
{
    UIViewController *destination = story.handler(url, params);
    if (destination) {
        UIViewController *source = [[self class] stackedController];
        UIStoryboardSegue *segue = [story prepareSegue:destination from:source];
        if (wake) {
            wake(segue);
        }
        UIStory *stack = [story copy];
        stack.presentedViewController = destination;
        stack.presentingViewController = source;
        [segue perform];
        [[[self class] stacks] addObject:stack];
        return YES;
    }
    return NO;
}

@end



@implementation UIStory
{
    NSString *_pattern;
    NSArray *_patternComponents;
    Class _segue, _unwind;
}

+ (instancetype)storyWithPattern:(NSString *)pattern segue:(Class)segueClass unwind:(Class)unwindClass
{
    UIStory *story = [[self alloc] initWithPattern:pattern segue:segueClass unwind:unwindClass];

    return story;
}

+ (instancetype)unresolvedStoryWithSegue:(Class)segueClass unwind:(Class)unwindClass
{
    return [self storyWithPattern:nil segue:segueClass unwind:unwindClass];
}

- (id)initWithPattern:(NSString *)pattern segue:(Class)segue unwind:(Class)unwind;
{
    self = [super init];
    if (self) {
        _pattern = pattern;
        _segue = segue;
        _unwind = unwind;
        _patternComponents = [pattern componentsSeparatedByString:@"/"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone:zone] initWithPattern:_pattern segue:_segue unwind:_unwind];
    return copy;
}

- (UIStoryboardSegue *)prepareSegue:(UIViewController *)destination from:(UIViewController *)source
{
    UIStoryboardSegue *segue = [[_segue alloc] initWithIdentifier:_pattern source:source destination:destination];
    return segue;
}

- (UIStoryboardSegue *)prepareUnwind:(UIViewController *)source to:(UIViewController *)destination
{
    UIStoryboardSegue *unwind = [[_unwind alloc] initWithIdentifier:_pattern source:source destination:destination];
    return unwind;
}

- (NSDictionary *)parameterForURL:(NSURL *)url
{
    NSArray *urlComponents = [[url.host stringByAppendingPathComponent:url.path] componentsSeparatedByString:@"/"];
    if (urlComponents.count != _patternComponents.count) return nil;

    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:urlComponents.count];
    for (int i = 0; i < urlComponents.count; i++) {
        id obj = urlComponents[i];
        NSString *key = _patternComponents[i];
        if ([key hasPrefix:@":"]) {
            [parameter setObject:obj forKey:[key substringFromIndex:1]];
        } else if (![key isEqualToString:obj]) {
            return nil;
        }
    }
    return parameter;
}


@end
