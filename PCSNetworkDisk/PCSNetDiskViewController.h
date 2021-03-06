//
//  PCSNetDiskViewController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser/MWPhotoBrowser.h"
#import <QuickLook/QuickLook.h>

@interface PCSNetDiskViewController : UIViewController<MWPhotoBrowserDelegate,BaiduPCSStatusListener,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic, copy) NSString    *path;
@property (nonatomic, assign) BOOL  showNavBackButton;

- (void)downloadFileFromServer:(NSString *)serverPath Block:(void (^)())action;

@end