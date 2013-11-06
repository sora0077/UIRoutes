//
//  UIModalSegue.m
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/15.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "UIModalSegue.h"

@implementation UIModalSegue

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
    [self.sourceViewController presentViewController:self.destinationViewController animated:self.animated completion:completion];
}

@end

@implementation UIModalUnwindSegue

- (void)perform
{
    [self performWithCompletion:nil];
}

- (void)performWithCompletion:(void (^)())completion
{
    [self.sourceViewController dismissViewControllerAnimated:self.animated completion:completion];
}

@end
