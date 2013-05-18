//
//  AppDelegate.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCSRootViewController;
@class BaiduPCSClient;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PCSRootViewController *viewController;
@property (nonatomic,retain) BaiduPCSClient   *pcsClient;
@property (nonatomic) dispatch_queue_t gcdQueue;
@property (nonatomic,assign) BOOL isADBannerShow;

@end
