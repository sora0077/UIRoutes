//
//  UIRoutesSegue.h
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/11/06.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIRoutesSegueProtocol <NSObject>

@property (nonatomic, assign) BOOL animated;

- (void)performWithCompletion:(void (^)())completion;

@end
