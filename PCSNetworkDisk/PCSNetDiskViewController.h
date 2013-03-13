//
//  PCSNetDiskViewController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCSNetDiskViewController : UIViewController<MobWinBannerViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    MobWinBannerView *adBanner;
}

@property (nonatomic, copy) NSString    *path;

@end