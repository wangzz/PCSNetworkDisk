//
//  PCSNetDiskViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSNetDiskViewController.h"

@interface PCSNetDiskViewController ()

@end

@implementation PCSNetDiskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	//
	// 腾讯MobWIN提示：开发者必须调用
	// 可在viewDidUnload调用或者在应用页面返回时调用或者在dealloc中调用
	// 目前已在viewWillDisappear中调用
	//
	[adBanner stopRequest];
	[adBanner removeFromSuperview];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self addADBanner];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addADBanner
{
    adBanner = [[MobWinBannerView alloc] initMobWinBannerSizeIdentifier:MobWINBannerSizeIdentifier320x50];
	adBanner.rootViewController = self;
    adBanner.frame = CGRectMake(0, 317, 320, 10);
	[adBanner setAdUnitID:PCS_STRING_MOBWIN_UNIT_ID];
	[self.view addSubview:adBanner];
    
    //
	// 腾讯MobWIN提示：开发者可选调用
	// 获取MobWinBannerViewDelegate回调消息
	//
    adBanner.delegate = self;
    //
	// 腾讯MobWIN提示：开发者可选调用
	//
	adBanner.adGpsMode = NO;
	// adBanner.adTextColor = [UIColor whiteColor];
	// adBanner.adSubtextColor = [UIColor colorWithRed:255.0/255.0 green:162.0/255.0 blue:0.0/255.0 alpha:1];
	// adBanner.adBackgroundColor = [UIColor colorWithRed:2.0/255.0 green:12.0/255.0 blue:15.0/255.0 alpha:1];
	//
	
	//
	// 腾讯MobWIN提示：开发者必须调用
	//
	// 发起广告请求方法
	//
	[adBanner startRequest];
	[adBanner release];
}

#pragma - MobBanner View Delegate

- (void)bannerViewDidReceived {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

- (void)bannerViewFailToReceived {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

- (void)bannerViewDidPresentScreen {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

- (void)bannerViewDidDismissScreen {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

- (void)bannerViewWillLeaveApplication {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

@end
