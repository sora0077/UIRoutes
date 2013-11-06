//
//  UIModalSegue.h
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/15.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIRoutesSegueProtocol.h"

@interface UIModalSegue : UIStoryboardSegue <UIRoutesSegueProtocol>
@property (nonatomic, assign) BOOL animated;
@end

@interface UIModalUnwindSegue : UIModalSegue
@end