//
//  PCSNetDiskViewController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser/MWPhotoBrowser.h"

@interface PCSNetDiskViewController : UIViewController<MobWinBannerViewDelegate,MWPhotoBrowserDelegate,BaiduPCSStatusListener,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    MobWinBannerView *adBanner;
}

@property (nonatomic, copy) NSString    *path;

- (void)downloadFileFromServer:(NSString *)serverPath Block:(void (^)())action;

@end