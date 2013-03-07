//
//  PCSLoginViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSLoginViewController.h"
#import "AppDelegate.h"
#import "PCSRootViewController.h"

@interface PCSLoginViewController ()

@end

@implementation PCSLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLoginButtonAction:(id)sender
{
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewController showViewControllerWith:PCSControllerStateMain];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PCS_STRING_IS_LOGIN];
}

@end
