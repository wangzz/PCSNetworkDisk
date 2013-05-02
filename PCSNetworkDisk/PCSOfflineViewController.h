//
//  PCSOfflineViewController.h
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "MWPhotoBrowser/MWPhotoBrowser.h"

@interface PCSOfflineViewController : UIViewController<BaiduPCSStatusListener,QLPreviewControllerDelegate,QLPreviewControllerDataSource,MWPhotoBrowserDelegate>

@end
