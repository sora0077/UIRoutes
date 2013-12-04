//
//  UIRoutes.m
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/13.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "UIRoutes.h"
#import "UIRoutesSegueProtocol.h"

const NSString *UIStoryAnyPattern = @"__any__";

@interface UIStory () <NSCopying>
@property (nonatomic, copy) UIViewController *(^handler)(NSURL *url, NSDictionary *params);

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) UIViewController *presentedViewController;
@property (nonatomic, weak) UIViewController *presentingViewController;

@property (nonatomic, readonly) NSString *pattern;

- (UIStoryboardSegue<UIRoutesSegueProtocol> *)prepareSegue:(UIViewController *)destination from:(UIViewController *)source;
- (UIStoryboardSegue<UIRoutesSegueProtocol> *)prepareUnwind:(UIViewController *)source to:(UIViewController *)destination;

- (NSDictionary *)parameterForURL:(NSURL *)url;
@end

static UIWindow *_routingWindow;

@implementation UIRoutes
{
    NSMutableDictionary *_stories;
    UIStory *_unresolvedStory;

    BOOL (^_resolveURLHandler)(NSURL *url);
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
        _stories = [NSMutableDictionary new];
    }
    return self;
}

- (void)setResolveURLHandler:(BOOL (^)(NSURL *))handler
{
    _resolveURLHandler = [handler copy];
}

- (void)addStory:(UIStory *)story handler:(UIViewController *(^)(NSURL *, NSDictionary *))handler
{
    if (story.handler == nil && handler) {
        story.handler = handler;
    }
    NSArray *patternComponents = [story.pattern componentsSeparatedByString:@"/"];
    NSMutableDictionary *parent = [_stories objectForKey:@(patternComponents.count)];
    if (parent == nil) {
        parent = [NSMutableDictionary new];
        [_stories setObject:parent forKey:@(patternComponents.count)];
    }
    for (id obj in patternComponents) {
        const NSString *pattern = obj;
        if ([pattern hasPrefix:@":"]) {
            pattern = UIStoryAnyPattern;
        }
        NSParameterAssert([parent isKindOfClass:[NSDictionary class]]);
        NSMutableDictionary *tree = [parent objectForKey:pattern];

        if (obj == patternComponents.lastObject) {
            [parent setObject:story forKey:pattern];
        } else if (tree == nil) {
            tree = [NSMutableDictionary new];
            [parent setObject:tree forKey:pattern];
        }

        parent = tree;
    }
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

+ (NSURL *)topURL
{
    UIStory *story = [self topStory];
    return story.url;
}

+ (BOOL)hasStacked:(NSURL *)url
{
    [self topStory];
    NSArray *urls = [[self stacks] valueForKeyPath:@"url"];

    for (NSURL *stackedURL in [urls reverseObjectEnumerator]) {
        if ([url.scheme isEqualToString:stackedURL.scheme]
            && [url.host isEqualToString:stackedURL.host]
            && [url.path isEqualToString:stackedURL.path]) {
            return YES;
        }
    }
    return NO;
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

+ (void)openURL:(NSURL *)url wake:(void (^)(UIStoryboardSegue<UIRoutesSegueProtocol> *))wake
{
    [self openURL:url wake:wake completion:nil];
}

+ (void)openURL:(NSURL *)url completion:(void (^)())completion
{
    [self openURL:url wake:nil completion:completion];
}

+ (void)openURL:(NSURL *)url wake:(void (^)(UIStoryboardSegue<UIRoutesSegueProtocol> *))wake completion:(void (^)())completion
{
    UIRoutes *route = [[self class] routes][url.scheme];

    if (route->_resolveURLHandler) {
        BOOL ret = route->_resolveURLHandler(url);
        if (ret == NO) return;
    }
    [route openURL:url wake:wake completion:completion];
}

+ (void)pop
{
    [self popOnWake:nil];
}

+ (void)popOnWake:(void (^)(UIStoryboardSegue<UIRoutesSegueProtocol> *))wake
{
    [self popOnWake:wake completion:nil];
}

+ (void)popOnCompletion:(void (^)())completion
{
    [self popOnWake:nil completion:completion];
}

+ (void)popOnWake:(void (^)(UIStoryboardSegue<UIRoutesSegueProtocol> *))wake completion:(void (^)())completion
{
    UIStory *story = [self topStory];
    if (story) {
        UIViewController *source = story.presentedViewController;
        UIViewController *destination = story.presentingViewController;
        UIStoryboardSegue<UIRoutesSegueProtocol> *unwind = [story prepareUnwind:source to:destination];
        if (wake) {
            wake(unwind);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [unwind performWithCompletion:completion];
        });

        [[self stacks] removeObject:story];
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
    UIStory *story = [self topStory];
    if (story) {
        return story.presentedViewController;
    }
    return _routingWindow.rootViewController;
}

+ (void)routingOnWindow:(UIWindow *)window
{
    _routingWindow = window;
}

+ (UIStory *)topStory
{
    if ([self stacks].count) {
        UIStory *story = [self stacks].lastObject;
        UIViewController *source = story.presentedViewController;
        UIViewController *destination = story.presentingViewController;
        BOOL isVisible = source.isViewLoaded && source.view.window;
        if (source && destination && isVisible) {
            return story;
        } else {
            [[self stacks] removeObject:story];
            return [self topStory];
        }
    }
    return nil;
}

- (BOOL)canOpenURL:(NSURL *)url
{
    UIStory *story = [self storyForURL:url];
    if (story) {
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
    [self openURL:url wake:wake completion:nil];
}

- (void)openURL:(NSURL *)url wake:(void (^)(UIStoryboardSegue *))wake completion:(void (^)())completion
{
    UIStory *story = [self storyForURL:url];
    NSDictionary *params = [story parameterForURL:url];
    if (params) {
        [self performSegueWithStory:story url:url parameter:params wake:wake completion:completion];
        return;
    }
    if (_unresolvedStory) {
        [self performSegueWithStory:_unresolvedStory url:url parameter:nil wake:wake completion:completion];
    }
}


- (BOOL)performSegueWithStory:(UIStory *)story url:(NSURL *)url parameter:(NSDictionary *)params wake:(void (^)(UIStoryboardSegue *))wake completion:(void (^)())completion
{
    UIViewController *destination = story.handler(url, params);
    if (destination) {
        UIViewController *source = [[self class] stackedController];
        UIStoryboardSegue<UIRoutesSegueProtocol> *segue = [story prepareSegue:destination from:source];
        if (wake) {
            wake(segue);
        }
        UIStory *stack = [story copy];
        stack.url = url;
        stack.presentedViewController = destination;
        stack.presentingViewController = source;
        dispatch_async(dispatch_get_main_queue(), ^{
            [segue performWithCompletion:completion];
        });
        [[[self class] stacks] addObject:stack];
        return YES;
    }
    return NO;
}

- (UIStory *)storyForURL:(NSURL *)url
{
    NSArray *patternComponents = [[url.host stringByAppendingPathComponent:url.path] componentsSeparatedByString:@"/"];
    NSDictionary *parent = [_stories objectForKey:@(patternComponents.count)];
    if (parent == nil) {
        return nil;
    }

    for (NSString *pattern in patternComponents) {
        NSParameterAssert([parent isKindOfClass:[NSDictionary class]]);
        id tree = [parent objectForKey:pattern];
        if (tree == nil) {
            tree = [parent objectForKey:UIStoryAnyPattern];
            if (tree == nil) {
                return tree;
            }
        }
        if (pattern == patternComponents.lastObject) {
            return tree;
        } else if ([tree isKindOfClass:[UIStory class]]) {
            return nil;
        }

        parent = tree;
    }
    return nil;
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
        NSAssert(segue == nil || [segue conformsToProtocol:@protocol(UIRoutesSegueProtocol)], @"");
        NSAssert(unwind == nil || [unwind conformsToProtocol:@protocol(UIRoutesSegueProtocol)], @"");
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

- (UIStoryboardSegue<UIRoutesSegueProtocol> *)prepareSegue:(UIViewController *)destination from:(UIViewController *)source
{
    UIStoryboardSegue<UIRoutesSegueProtocol> *segue = [[_segue alloc] initWithIdentifier:_pattern source:source destination:destination];
    return segue;
}

- (UIStoryboardSegue<UIRoutesSegueProtocol> *)prepareUnwind:(UIViewController *)source to:(UIViewController *)destination
{
    UIStoryboardSegue<UIRoutesSegueProtocol> *unwind = [[_unwind alloc] initWithIdentifier:_pattern source:source destination:destination];
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

#pragma mark -

@implementation UIApi

+ (instancetype)apiWithPattern:(NSString *)pattern
{
    UIApi *api = [super storyWithPattern:pattern
                                   segue:nil
                                  unwind:nil];
    return api;
}

@end
