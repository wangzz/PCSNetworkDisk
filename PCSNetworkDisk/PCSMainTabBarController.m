//
//  PCSMainTabBarController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSMainTabBarController.h"
#import "PCSNetDiskViewController.h"
#import "PCSOfflineViewController.h"
#import "PCSUploadViewController.h"
#import "PCSMoreViewController.h"
#import "PCSFileInfoItem.h"
#import "AppDelegate.h"

@interface PCSMainTabBarController ()

@end

@implementation PCSMainTabBarController
@synthesize netDiskNavController;
@synthesize uploadNavController;
@synthesize offlineNavController;
@synthesize moreNavController;
@synthesize isDeleteButtonCreated;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    PCS_FUNC_SAFELY_RELEASE(netDiskNavController);
    PCS_FUNC_SAFELY_RELEASE(uploadNavController);
    PCS_FUNC_SAFELY_RELEASE(offlineNavController);
    PCS_FUNC_SAFELY_RELEASE(moreNavController);
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self createTabBarControllers];
    [self addADBanner];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createTabBarControllers
{
    PCSNetDiskViewController *netDiskViewController = [[PCSNetDiskViewController alloc] init];
    netDiskViewController.path = PCS_STRING_DEFAULT_PATH;
    netDiskNavController = [[UINavigationController alloc]initWithRootViewController:netDiskViewController];
    netDiskNavController.tabBarItem.title = @"";
    PCS_FUNC_SAFELY_RELEASE(netDiskViewController);
    
    UIViewController *uploadViewController = [[PCSUploadViewController alloc] init];
    uploadNavController = [[UINavigationController alloc] initWithRootViewController:uploadViewController];
    uploadNavController.tabBarItem.title = @"";
    PCS_FUNC_SAFELY_RELEASE(uploadViewController);
    
    UIViewController *offlineViewController = [[PCSOfflineViewController alloc] init] ;
    offlineNavController = [[UINavigationController alloc] initWithRootViewController:offlineViewController];
    offlineNavController.tabBarItem.title = @"";
    PCS_FUNC_SAFELY_RELEASE(offlineViewController);
    
    UIViewController *moreViewController = [[PCSMoreViewController alloc] init];
    moreNavController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
    moreNavController.tabBarItem.title = @"";
    PCS_FUNC_SAFELY_RELEASE(moreViewController);
    
    if ([self.tabBarItem respondsToSelector:@selector(setFinishedSelectedImage:withFinishedUnselectedImage:)])
    {
        self.tabBar.backgroundImage = [[UIImage imageNamed:@"tab_background"] stretchableImageWithLeftCapWidth:6 topCapHeight:24];
        UIEdgeInsets imgSet =  UIEdgeInsetsMake(5, 0, -9, 0);
        [netDiskNavController.tabBarItem setImageInsets:imgSet];
        [netDiskNavController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_netdisked"]
                             withFinishedUnselectedImage:[UIImage imageNamed:@"tab_netdisk"]];
        
        [uploadNavController.tabBarItem setImageInsets:imgSet];
        [uploadNavController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_uploaded"]
                          withFinishedUnselectedImage:[UIImage imageNamed:@"tab_upload"]];
        
        [offlineNavController.tabBarItem setImageInsets:imgSet];
        [offlineNavController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_offlined"]
                           withFinishedUnselectedImage:[UIImage imageNamed:@"tab_offline"]];
        
        [moreNavController.tabBarItem setImageInsets:imgSet];
        [moreNavController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_mored"]
                         withFinishedUnselectedImage:[UIImage imageNamed:@"tab_more"]];
    } else {
        netDiskViewController.tabBarItem.image = [UIImage imageNamed:@"tab_netdisk"];
        uploadNavController.tabBarItem.image = [UIImage imageNamed:@"tab_upload"];
        offlineNavController.tabBarItem.image = [UIImage imageNamed:@"tab_offline"];
        moreNavController.tabBarItem.image = [UIImage imageNamed:@"tab_more"];
    }

    NSArray   *controllers = [NSArray arrayWithObjects:
                              netDiskNavController,uploadNavController,offlineNavController,moreNavController, nil];
    
    self.viewControllers = controllers;
}


#pragma mark - 百度广告条
- (void)showAdViewInController:(UIViewController<BaiduMobAdViewDelegate> *)controller withRect:(CGRect) rect
{
    //悬浮广告
    BaiduMobAdView *adView = [[[BaiduMobAdView alloc] init] autorelease];
    adView.AdUnitTag = @"myAdPlaceId1";
    adView.AdType = BaiduMobAdViewTypeBanner;
    adView.frame = rect;
    adView.delegate = controller;
    [controller.view addSubview:adView];
    [adView start];
}

- (void)addADBanner
{
    //CGRectMake(0, 406+(iPhone5?88:0), 320, 10)
    //使用嵌入广告的方法实例。
    sharedAdView = [[BaiduMobAdView alloc] init];
    //sharedAdView.AdUnitTag = @"myAdPlaceId1";
    //此处为广告位id，可以不进行设置，如需设置，在百度移动联盟上设置广告位id，然后将得到的id填写到此处。
    sharedAdView.AdType = BaiduMobAdViewTypeBanner;
    sharedAdView.frame = kAdViewPortraitRect;
    sharedAdView.delegate = self;
    [self.view addSubview:sharedAdView];
    [sharedAdView start];
    
    //使用悬浮广告的方法实例。
    //    [self showAdViewInController:self withRect:kAdViewPortraitRect];
    
}

#pragma mark - 按钮响应事件
- (void)onDeleteButtonAction
{
    [sharedAdView close];
    [sharedAdView removeFromSuperview];
    sharedAdView = nil;
    PCS_APP_DELEGATE.isADBannerShow = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_SHOW_WITHOUT_AD_BANNER
                                                        object:nil];
}

#pragma mark - MobBanner View Delegate
- (NSString *)publisherId
{
    return  PCS_STRING_BAIDU_AD_PUBLISHER_ID; //@"your_own_app_id";
}

- (NSString*) appSpec
{
    //注意：该计费名为测试用途，不会产生计费，请测试广告展示无误以后，替换为您的应用计费名，然后提交AppStore.
    return PCS_STRING_BAIDU_AD_APPSPEC;
}

-(BOOL) enableLocation
{
    //启用location会有一次alert提示
    return NO;
}

-(void) willDisplayAd:(BaiduMobAdView*) adview
{
    //在广告即将展示时，产生一个动画，把广告条加载到视图中
    sharedAdView.hidden = NO;
    CGRect f = sharedAdView.frame;
    f.origin.x = -320;
    sharedAdView.frame = f;
    [UIView beginAnimations:nil context:nil];
    f.origin.x = 0;
    sharedAdView.frame = f;
    [UIView commitAnimations];
    
    if (!isDeleteButtonCreated) {
        UIButton    *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(305, 0, 15, 15)];
        [deleteButton setImage:[UIImage imageNamed:@"ad_close"]
                      forState:UIControlStateNormal];
        [deleteButton addTarget:self
                         action:@selector(onDeleteButtonAction)
               forControlEvents:UIControlEventTouchUpInside];
        [sharedAdView addSubview:deleteButton];
        PCS_FUNC_SAFELY_RELEASE(deleteButton);
        isDeleteButtonCreated = YES;
        PCS_APP_DELEGATE.isADBannerShow = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_SHOW_WITH_AD_BANNER
                                                            object:nil];
    }
    
    PCSLog(@"delegate: will display ad");
}

-(void) failedDisplayAd:(BaiduMobFailReason) reason;
{
    PCSLog(@"delegate: failedDisplayAd %d", reason);
}


////人群属性接口
///**
// *  - 关键词数组
// */
//-(NSArray*) keywords{
//    NSArray* keywords = [NSArray arrayWithObjects:@"测试",@"关键词", nil];
//    return keywords;
//}
//
///**
// *  - 用户性别
// */
//-(BaiduMobAdUserGender) userGender{
//    return BaiduMobAdMale;
//}
//
///**
// *  - 用户生日
// */
//-(NSDate*) userBirthday{
//    NSDate* birthday = [NSDate dateWithTimeIntervalSince1970:0];
//    return birthday;
//}
//
///**
// *  - 用户城市
// */
//-(NSString*) userCity{
//    return @"上海";
//}
//
//
///**
// *  - 用户邮编
// */
//-(NSString*) userPostalCode{
//    return @"435200";
//}
//
//
///**
// *  - 用户职业
// */
//-(NSString*) userWork{
//    return @"程序员";
//}
//
///**
// *  - 用户最高教育学历
// *  - 学历输入数字，范围为0-6
// *  - 0表示小学，1表示初中，2表示中专/高中，3表示专科
// *  - 4表示本科，5表示硕士，6表示博士
// */
//-(NSInteger) userEducation{
//    return  5;
//}
//
///**
// *  - 用户收入
// *  - 收入输入数字,以元为单位
// */
//-(NSInteger) userSalary{
//    return 10000;
//}
//
///**
// *  - 用户爱好
// */
//-(NSArray*) userHobbies{
//    NSArray* hobbies = [NSArray arrayWithObjects:@"测试",@"爱好", nil];
//    return hobbies;
//}
//
///**
// *  - 其他自定义字段
// */
//-(NSDictionary*) userOtherAttributes{
//    NSMutableDictionary* other = [[[NSMutableDictionary alloc] init] autorelease];
//    [other setValue:@"测试" forKey:@"测试"];
//    return other;
//}


@end
