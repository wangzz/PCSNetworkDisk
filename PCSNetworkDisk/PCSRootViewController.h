//
//  PCSRootViewController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduOAuth.h"
#import "KKPasscodeViewController.h"

typedef enum
{
    PCSControllerStateNil,
    PCSControllerStateLogin,
    PCSControllerStateMain,
    PCSControllerStateHelp,
    PCSControllerStateResetPwd,
    PCSControllerStatePasscode
}PCSControllerState;


@interface PCSRootViewController : UINavigationController<BaiduOAuthDelegate,KKPasscodeViewControllerDelegate>

@property (nonatomic,assign) PCSControllerState  currentControllerState;

+(PCSRootViewController *)shareInstance;
- (void)showViewControllerWith:(PCSControllerState)nextControllerState;

@end
