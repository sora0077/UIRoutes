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
    UINavigationController *navController = [self.sourceViewController navigationController] ?: self.sourceViewController;
    [navController pushViewController:self.destinationViewController animated:self.animated];
}

@end

@implementation UIPushUnwindSegue

- (void)perform
{
    [[self.sourceViewController navigationController] popViewControllerAnimated:self.animated];
}

@end

