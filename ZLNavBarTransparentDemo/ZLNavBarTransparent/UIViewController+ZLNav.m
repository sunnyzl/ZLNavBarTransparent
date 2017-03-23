//
//  UIViewController+ZLNav.m
//  Test
//
//  Created by zhao on 2017/3/23.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "UIViewController+ZLNav.h"
#import <objc/runtime.h>

@interface UIViewController ()
<
UINavigationControllerDelegate
>

@end

static const char navigationBarHiddenKey;
static const char navBarBgAlphaKey;
static const char navBarTintColorKey;

@implementation UIViewController (ZLNav)

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    objc_setAssociatedObject(self, (void *)&navigationBarHiddenKey, @(navigationBarHidden), OBJC_ASSOCIATION_ASSIGN);
    if (navigationBarHidden) {
        self.navigationController.delegate = self;
    }
}

- (BOOL)navigationBarHidden {
    NSNumber *barHiddenNum = objc_getAssociatedObject(self, (void *)&navigationBarHiddenKey);
    if (barHiddenNum == nil) {
        return NO;
    }
    return [objc_getAssociatedObject(self, (void *)&navigationBarHiddenKey) boolValue];
}

- (void)setNavBarBgAlpha:(CGFloat)navBarBgAlpha {
    CGFloat newAlpha = MAX(MIN(navBarBgAlpha, 1.f), 0.f);
    objc_setAssociatedObject(self, (void *)&navBarBgAlphaKey, @(newAlpha), OBJC_ASSOCIATION_ASSIGN);
    [self setNeedsNavigationBackground:navBarBgAlpha];
}

- (CGFloat)navBarBgAlpha {
    
    NSNumber *alphaNum = objc_getAssociatedObject(self, (void *)&navBarBgAlphaKey);
    if (alphaNum == nil) {
        return 1.f;
    }
    return alphaNum.floatValue;
}

- (void)setNavBarTintColor:(UIColor *)navBarTintColor {
    self.navigationController.navigationBar.tintColor = navBarTintColor;
    objc_setAssociatedObject(self, (void *)&navBarTintColorKey, navBarTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)navBarTintColor {
    UIColor *color = objc_getAssociatedObject(self, (void *)&navBarTintColorKey);
    if (color == nil) {
        return [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1];
//        return [UIColor orangeColor];
    }
    return color;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navigationBarHidden) {
        BOOL isShowPage = [viewController isKindOfClass:[self class]];
        [self.navigationController setNavigationBarHidden:isShowPage animated:YES];
    }
}

- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    UIView *barBackgroundView = self.navigationController.navigationBar.subviews.firstObject;
    UIView *shadowView = [barBackgroundView valueForKey:@"_shadowView"];
    if (shadowView) {
        shadowView.alpha = alpha;
    }
    
    if (self.navigationController.navigationBar.isTranslucent) {
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 10.0) {
            UIVisualEffectView *backgroundEffectView = [barBackgroundView valueForKey:@"_backgroundEffectView"];
            
            if (backgroundEffectView && [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] == nil) {
                backgroundEffectView.alpha = alpha;
                return;
            }
        } else {
            UIView *adaptiveBackdrop = [barBackgroundView valueForKey:@"_adaptiveBackdrop"];
            UIView *backdropEffectView = [adaptiveBackdrop valueForKey:@"_backdropEffectView"];
            if (adaptiveBackdrop && backdropEffectView) {
                backdropEffectView.alpha = alpha;
                return;
            }
        }
    }
    
    barBackgroundView.alpha = alpha;
}


@end
