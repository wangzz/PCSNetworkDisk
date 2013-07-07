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
@property(nonatomic,retain) UIView  *customTabBar;//用于IOS5以下系统中
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
    if (PCS_APP_DELEGATE.isADBannerShow) {
        [sharedAdView close];
        [sharedAdView removeFromSuperview];
        sharedAdView = nil;
    }
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
#define TAG_TABBAR_BACKGROUND_VIEW          11101
#define TAG_FAX_TABLEBAR_ITEM_CONTACT       11102
#define TAG_FAX_TABLEBAR_ITEM_CALL_RECORD   11103
#define TAG_FAX_TABLEBAR_ITEM_CONFERENCE    11104
#define TAG_FAX_TABLEBAR_ITEM_MORE          11105
        
        self.customTabBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 49)];
        self.customTabBar.tag = TAG_TABBAR_BACKGROUND_VIEW;
        UIImageView *contactImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 49)];
        [contactImage setContentMode:UIViewContentModeCenter];
        contactImage.image = [UIImage imageNamed:@"tab_netdisked"];
        contactImage.tag = TAG_FAX_TABLEBAR_ITEM_CONTACT;
        [self.customTabBar addSubview:contactImage];
        PCS_FUNC_SAFELY_RELEASE(contactImage);
        
        UIImageView *callImage = [[UIImageView alloc] initWithFrame:CGRectMake(80, 0, 80, 49)];
        callImage.image = [UIImage imageNamed:@"tab_upload"];
        [callImage setContentMode:UIViewContentModeCenter];
        callImage.tag = TAG_FAX_TABLEBAR_ITEM_CALL_RECORD;
        [self.customTabBar addSubview:callImage];
        PCS_FUNC_SAFELY_RELEASE(callImage);
        
        UIImageView *confImage = [[UIImageView alloc] initWithFrame:CGRectMake(160, 0, 80, 49)];
        confImage.image = [UIImage imageNamed:@"tab_offline"];
        [confImage setContentMode:UIViewContentModeCenter];
        confImage.tag = TAG_FAX_TABLEBAR_ITEM_CONFERENCE;
        [self.customTabBar addSubview:confImage];
        PCS_FUNC_SAFELY_RELEASE(confImage);
        
        UIImageView *moreImage = [[UIImageView alloc] initWithFrame:CGRectMake(240, 0, 80, 49)];
        moreImage.image = [UIImage imageNamed:@"tab_more"];
        [moreImage setContentMode:UIViewContentModeCenter];
        moreImage.tag = TAG_FAX_TABLEBAR_ITEM_MORE;
        [self.customTabBar addSubview:moreImage];
        PCS_FUNC_SAFELY_RELEASE(moreImage);
        
        [self.tabBar addSubview:self.customTabBar];
    }

    NSArray   *controllers = [NSArray arrayWithObjects:
                              netDiskNavController,uploadNavController,offlineNavController,moreNavController, nil];
    
    self.viewControllers = controllers;
}

#pragma mark Custom TabBar Method For IOS4
//用于IOS4及以下系统
- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    [super setSelectedViewController:selectedViewController];
    if (![self.tabBarItem respondsToSelector:@selector(setFinishedSelectedImage:withFinishedUnselectedImage:)]) {
//        [self setNoHighlightTabBar];
        [self changeBarItemImage:selectedViewController];
        oldController = selectedViewController;
    }
}

//移除系统tabBar上的白色选中框
- (void)setNoHighlightTabBar
{
    int tabCount = [self.viewControllers count] > 5 ? 5 : [self.viewControllers count];
    NSArray * tabBarSubviews = [self.tabBar subviews];
    for(int i = [tabBarSubviews count] - 1; i > [tabBarSubviews count] - tabCount - 1; i--)
    {
        for(UIView * v in [[tabBarSubviews objectAtIndex:i] subviews])
        {
            if(v && [NSStringFromClass([v class]) isEqualToString:@"UITabBarSelectionIndicatorView"])
            {
                [v removeFromSuperview];
                break;
            }
        }
    }
}

- (void)changeBarItemImage:(UIViewController *)newController
{
    HSNavgationType viewType = [self controllerType:newController];
    UIImageView *newImageView = [self imageViewOnBar:viewType];
    if (nil == newController) {
        return;
    }
    HSNavgationType oldType = [self controllerType:oldController];
    UIImageView *oldImageView = [self imageViewOnBar:oldType];
    
    if (oldController != nil) {
        oldImageView.image = [self imageWithImageType:HSBarImageTypeNormal ControllerType:oldType];
    }
    newImageView.image = [self imageWithImageType:HSBarImageTypeSelect ControllerType:viewType];
}

- (UIImageView *)imageViewOnBar:(HSNavgationType)type
{
    UIImageView *imageView = nil;
    switch (type) {
        case HSNavgationTypeContact:
            imageView = (UIImageView *)[self.customTabBar viewWithTag:
                                        TAG_FAX_TABLEBAR_ITEM_CONTACT];
            break;
        case HSNavgationTypeRecord:
            imageView = (UIImageView *)[self.customTabBar viewWithTag:
                                        TAG_FAX_TABLEBAR_ITEM_CALL_RECORD];
            break;
        case HSNavgationTypeConf:
            imageView = (UIImageView *)[self.customTabBar viewWithTag:
                                        TAG_FAX_TABLEBAR_ITEM_CONFERENCE];
            break;
        case HSNavgationTypeMore:
            imageView = (UIImageView *)[self.customTabBar viewWithTag:
                                        TAG_FAX_TABLEBAR_ITEM_MORE];
            break;
        default:
            break;
    }
    return imageView;
}

- (HSNavgationType)controllerType:(UIViewController *)controller
{
    if ([controller isEqual:netDiskNavController]) {
        return HSNavgationTypeContact;
    }else if ([controller isEqual:uploadNavController]) {
        return HSNavgationTypeRecord;
    }else if ([controller isEqual:offlineNavController]) {
        return HSNavgationTypeConf;
    }else if ([controller isEqual:moreNavController]) {
        return HSNavgationTypeMore;
    }
    return HSNavgationTypeError;
}

- (UIImage  *)imageWithImageType:(HSBarImageType)imageType ControllerType:(HSNavgationType)controllerType
{
    UIImage *image = nil;
    switch (controllerType) {
        case HSNavgationTypeContact:
            if (imageType == HSBarImageTypeNormal) {
                image = [UIImage imageNamed:@"tab_netdisk"];
            }else if (imageType == HSBarImageTypeSelect) {
                image = [UIImage imageNamed:@"tab_netdisked"];
            }
            break;
        case HSNavgationTypeRecord:
            if (imageType == HSBarImageTypeNormal) {
                image = [UIImage imageNamed:@"tab_upload"];
            }else if (imageType == HSBarImageTypeSelect) {
                image = [UIImage imageNamed:@"tab_uploaded"];
            }
            break;
        case HSNavgationTypeConf:
            if (imageType == HSBarImageTypeNormal) {
                image = [UIImage imageNamed:@"tab_offline"];
            }else if (imageType == HSBarImageTypeSelect) {
                image = [UIImage imageNamed:@"tab_offlined"];
            }
            break;
        case HSNavgationTypeMore:
            if (imageType == HSBarImageTypeNormal) {
                image = [UIImage imageNamed:@"tab_more"];
            }else if (imageType == HSBarImageTypeSelect) {
                image = [UIImage imageNamed:@"tab_mored"];
            }
            break;
        default:
            break;
    }
    return image;
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
    sharedAdView.delegate = nil;
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
        UIButton    *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(2.5f, 2.5f, 15, 15)];
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
