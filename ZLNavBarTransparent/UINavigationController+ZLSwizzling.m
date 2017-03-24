//
//  UINavigationController+ZLSwizzling.m
//  Test
//
//  Created by zhao on 2017/3/22.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "UINavigationController+ZLSwizzling.h"
#import "ZLSwizzlingDefine.h"
#import "UIViewController+ZLNav.h"


@interface UINavigationController ()
<
UINavigationControllerDelegate,
UINavigationBarDelegate
>

@end

@implementation UINavigationController (ZLSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zl_swizzling_exchangeMethod([UINavigationController class], @selector(pushViewController:animated:), @selector(zl_swizzling_pushViewController:animated:));
        zl_swizzling_exchangeMethod([UINavigationController class], @selector(viewDidLoad), @selector(zl_swizzling_viewDidLoad));
        zl_swizzling_exchangeMethod([UINavigationController class], @selector(preferredStatusBarStyle), @selector(zl_swizzling_preferredStatusBarStyle));
        
        
        zl_swizzling_exchangeMethod([UINavigationController class], NSSelectorFromString(@"_updateInteractiveTransition:"), @selector(zl_swizzling_updateInteractiveTransition:));
        
        zl_swizzling_exchangeMethod([UINavigationController class], @selector(popToViewController:animated:), @selector(zl_swizzling_popToViewController:animated:));
        zl_swizzling_exchangeMethod([UINavigationController class], @selector(popToRootViewControllerAnimated:), @selector(zl_swizzling_popToRootViewControllerAnimated:));
        
    });
}


#pragma mark -- 

- (void)zl_swizzling_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self zl_swizzling_pushViewController:viewController animated:animated];
    
    if ([viewController.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        viewController.navigationController.interactivePopGestureRecognizer.enabled = YES;
        viewController.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)zl_swizzling_viewDidLoad {
    [self zl_swizzling_viewDidLoad];
    self.delegate = self;
}

- (UIStatusBarStyle)zl_swizzling_preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle ? : UIStatusBarStyleDefault;
}

- (void)zl_swizzling_updateInteractiveTransition:(CGFloat)percentComplete {
    
    if (self.topViewController == nil && self.topViewController.transitionCoordinator == nil) {
        [self zl_swizzling_updateInteractiveTransition:percentComplete];
        return;
    }
    
    UIViewController *fromVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //  bg alpha
    CGFloat fromAlpha = fromVC.navBarBgAlpha;
    CGFloat toAlpha = toVC.navBarBgAlpha;
    
    CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete;
    
    [self setNeedsNavigationBackground:nowAlpha];
    
    //  tintColor
    UIColor *fromColor = fromVC.navBarTintColor;
    UIColor *toColor = toVC.navBarTintColor;
    UIColor *nowColor = [self averageColorFormClolor:fromColor toColor:toColor percent:percentComplete];
    
    if (!fromVC.navigationBarHidden) {
        self.navigationBar.tintColor = nowColor;
    }

    [self zl_swizzling_updateInteractiveTransition:percentComplete];
}

- (NSArray<UIViewController *> *)zl_swizzling_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self setNeedsNavigationBackground:viewController.navBarBgAlpha];
    self.navigationBar.tintColor = viewController.navBarTintColor;
    return [self zl_swizzling_popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)zl_swizzling_popToRootViewControllerAnimated:(BOOL)animated {
    [self setNeedsNavigationBackground:self.viewControllers.firstObject.navBarBgAlpha];
    self.navigationBar.tintColor = self.viewControllers.firstObject.navBarTintColor;
    return [self zl_swizzling_popToRootViewControllerAnimated:animated];
}

- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    UIView *barBackgroundView = self.navigationBar.subviews.firstObject;
    UIView *shadowView = [barBackgroundView valueForKey:@"_shadowView"];
    if (shadowView) {
        shadowView.alpha = alpha;
    }
    
    if (self.navigationBar.isTranslucent) {
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 10.0) {
            UIView *backgroundEffectView = [barBackgroundView valueForKey:@"_backgroundEffectView"];
            
            if (backgroundEffectView && [self.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] == nil) {
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

- (UIColor *)averageColorFormClolor:(UIColor *)fromColor toColor:(UIColor *)toColor percent:(CGFloat)percent {
    
    CGFloat fromRed = 0.f;
    CGFloat fromGreen = 0.f;
    CGFloat fromBlue = 0.f;
    CGFloat fromAlpha = 0.f;
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0.f;
    CGFloat toGreen = 0.f;
    CGFloat toBlue = 0.f;
    CGFloat toAlpha = 0.f;
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat nowRed = fromRed + (toRed - fromRed) * percent;
    CGFloat nowGreen = fromGreen + (toGreen - fromGreen) * percent;
    CGFloat nowBlue = fromBlue + (toBlue - fromBlue) * percent;
    CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent;
    return [UIColor colorWithRed:nowRed green:nowGreen blue:nowBlue alpha:nowAlpha];
}


//  delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.topViewController == nil && navigationController.topViewController.transitionCoordinator == nil) {
        return;
    }
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 10.0) {
        [navigationController.topViewController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self dealInteractionChangesWithContext:context];
        }];
    } else {
        [navigationController.topViewController.transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self dealInteractionChangesWithContext:context];
        }];
    }
}

- (void)dealInteractionChangesWithContext:(id <UIViewControllerTransitionCoordinatorContext>)context {
    void (^animations)(UITransitionContextViewControllerKey) = ^(UITransitionContextViewControllerKey key) {
        [self setNeedsNavigationBackground:[context viewControllerForKey:key].navBarBgAlpha];
        self.navigationBar.tintColor = [context viewControllerForKey:key].navBarTintColor;
    };
    
    if ([context isCancelled]) {
        NSTimeInterval cancellDuration = [context transitionDuration] * (double)([context percentComplete]);
        [UIView animateWithDuration:cancellDuration animations:^{
            animations(UITransitionContextFromViewControllerKey);
        }];
    } else {
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        [UIView animateWithDuration:finishDuration animations:^{
            animations(UITransitionContextToViewControllerKey);
        }];
    }
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.topViewController && self.topViewController.transitionCoordinator && [self.topViewController.transitionCoordinator initiallyInteractive]) {
        return YES;
    }
    
    NSInteger itemCount = navigationBar.items.count;
    NSInteger n = self.viewControllers.count >= itemCount ? 2 : 1;
    
    UIViewController *popToVC = self.viewControllers[self.viewControllers.count - n];
    [self popToViewController:popToVC animated:YES];
    return YES;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    
    [self setNeedsNavigationBackground:self.topViewController.navBarBgAlpha];
    navigationBar.tintColor = self.topViewController.navBarTintColor;
    return YES;
}


@end
