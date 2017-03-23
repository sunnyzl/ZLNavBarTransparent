//
//  UIViewController+ZLNav.h
//  Test
//
//  Created by zhao on 2017/3/23.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ZLNav)

@property (assign, nonatomic) BOOL navigationBarHidden;
@property (assign, nonatomic) CGFloat navBarBgAlpha;
@property (strong, nonatomic) UIColor *navBarTintColor;

@end
