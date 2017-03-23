//
//  SecondViewController.m
//  ZLNavBarTransparentDemo
//
//  Created by zhao on 2017/3/23.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "SecondViewController.h"
#import "UIViewController+ZLNav.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navBarBgAlpha = 0.f;
    self.navBarTintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
