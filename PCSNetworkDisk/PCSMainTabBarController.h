//
//  PCSMainTabBarController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    HSBarImageTypeNormal,
    HSBarImageTypeSelect,
}HSBarImageType;//用于IOS5以下系统中

typedef enum
{
    HSNavgationTypeContact,
    HSNavgationTypeRecord,
    HSNavgationTypeConf,
    HSNavgationTypeMore,
    HSNavgationTypeError
}HSNavgationType;//用于IOS5以下系统中

@interface PCSMainTabBarController : UITabBarController<BaiduMobAdViewDelegate>
{
    BaiduMobAdView* sharedAdView;
    UIViewController    *oldController;//用于IOS5以下系统中
}

@property (nonatomic,assign) BOOL   isDeleteButtonCreated;
@property (nonatomic,retain) UINavigationController     *netDiskNavController;
@property (nonatomic,retain) UINavigationController     *uploadNavController;
@property (nonatomic,retain) UINavigationController     *offlineNavController;
@property (nonatomic,retain) UINavigationController     *moreNavController;


@end
