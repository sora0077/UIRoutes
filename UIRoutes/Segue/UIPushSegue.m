//
//  UIPushSegue.m
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/16.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "UIPushSegue.h"

@implementation UIPushSegue

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
    [navController pushViewController:self.destinationViewController animated:self.animated];

    if (completion) {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            completion();
        });
    }
}

@end

@implementation UIPushUnwindSegue

- (void)perform
{
    [self performWithCompletion:nil];
}

- (void)performWithCompletion:(void (^)())completion
{
    [[self.sourceViewController navigationController] popViewControllerAnimated:self.animated];

    if (completion) {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            completion();
        });
    }
}

@end

