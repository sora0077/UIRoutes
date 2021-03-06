//
//  UIPushElseModalSegue.m
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/16.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "UIPushElseModalSegue.h"

@implementation UIPushElseModalSegue

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        self.animated = YES;
    }
    return self;
}

- (void)perform
{
    [self performWithCompletion:nil];
}

- (void)performWithCompletion:(void (^)())completion
{
    UINavigationController *navController = [self.sourceViewController navigationController] ?: self.sourceViewController;
    if ([navController respondsToSelector:@selector(pushViewController:animated:)]) {
        [super performWithCompletion:completion];
    } else {
        [navController presentViewController:self.destinationViewController animated:self.animated completion:completion];
    }
}

@end

@implementation UIPushElseModalUnwindSegue

- (void)perform
{
    [self performWithCompletion:nil];
}

- (void)performWithCompletion:(void (^)())completion
{
    UINavigationController *navController = [self.sourceViewController navigationController] ?: self.sourceViewController;
    if ([navController respondsToSelector:@selector(popViewControllerAnimated:)]) {
        [super performWithCompletion:completion];
    } else {
        [self.sourceViewController dismissViewControllerAnimated:self.animated completion:completion];
    }
}

@end
