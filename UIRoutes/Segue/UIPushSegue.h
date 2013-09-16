//
//  UIPushSegue.h
//  UIRoutesDemo
//
//  Created by 林 達也 on 2013/09/16.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPushSegue : UIStoryboardSegue
@property (nonatomic, assign) BOOL animated;
@end

@interface UIPushUnwindSegue : UIPushSegue
@end
