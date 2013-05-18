//
//  PCSMainTabBarController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCSMainTabBarController : UITabBarController<BaiduMobAdViewDelegate>
{
    BaiduMobAdView* sharedAdView;
}

@property (nonatomic,assign) BOOL   isDeleteButtonCreated;
@property (nonatomic,retain) UINavigationController     *netDiskNavController;
@property (nonatomic,retain) UINavigationController     *uploadNavController;
@property (nonatomic,retain) UINavigationController     *offlineNavController;
@property (nonatomic,retain) UINavigationController     *moreNavController;


@end
