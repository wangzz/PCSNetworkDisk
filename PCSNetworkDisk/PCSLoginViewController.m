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
#import "BaiduPCSClient.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    BaiduOAuth *oauthViewController = [[BaiduOAuth alloc] init];
    oauthViewController.apiKey = PCS_STRING_BAIDU_API_KEY; //此处的api key 对应在百度开发者中心申请的应用对应的api key
    oauthViewController.delegate = self;
    [self presentViewController:oauthViewController animated:YES completion:nil];
    PCS_FUNC_SAFELY_RELEASE(oauthViewController);
    
    [super viewWillAppear:animated];
}

#pragma - Baidu OAuth Response Delegate
// success to get access token
-(void)onSuccess:(BaiduOAuthResponse*)response
{
    [PCS_APP_DELEGATE.viewController showViewControllerWith:PCSControllerStateMain];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PCS_STRING_IS_LOGIN];
    PCS_APP_DELEGATE.pcsClient.accessToken = response.accessToken;
    PCSLog(@"%@",[NSString stringWithFormat:@"Access Token:%@  User Name:%@  Expres In %@", response.accessToken, response.userName, response.expiresIn]);
}

// fail to get access token
-(void)onError:(NSString*)error
{
    PCSLog(@"%@", error);
}

// cancel
-(void)onCancel
{
    PCSLog(@"onCancel");
}

@end
