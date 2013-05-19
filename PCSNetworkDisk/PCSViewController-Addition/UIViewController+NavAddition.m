//
//  UIViewController+PCSViewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-5-19.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "UIViewController+NavAddition.h"

@implementation UIViewController (PCSViewController)

- (void)createNavBackButtonWithTitle:(NSString *)title
{
    UIButton *navButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 32)];
    navButton.backgroundColor  = [UIColor clearColor];
    if (title != nil) {
        UIColor *color = [UIColor colorWithRed:0.896f
                                         green:0.948f
                                          blue:1.0f
                                         alpha:1.0f];
        [navButton setTitleColor:color forState:UIControlStateNormal];
        navButton.titleLabel.font = [UIFont systemFontOfSize:13.5f];
        [navButton setTitle:title forState:UIControlStateNormal];
    }
    [navButton setBackgroundImage:[UIImage imageNamed:@"nav_button"]
                         forState:UIControlStateNormal];
    [navButton setBackgroundImage:[UIImage imageNamed:@"nav_buttoned"]
                         forState:UIControlStateHighlighted];
    [navButton addTarget:self
                  action:@selector(onNavBackButtonAction)
        forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *navMenuBtn = [[UIBarButtonItem alloc] initWithCustomView:navButton];
    self.navigationItem.leftBarButtonItem = navMenuBtn;
    [navMenuBtn release];
    [navButton release];
}

- (void)onNavBackButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
