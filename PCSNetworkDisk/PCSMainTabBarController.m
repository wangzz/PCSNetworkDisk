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

@interface PCSMainTabBarController ()

@end

@implementation PCSMainTabBarController
@synthesize netDiskNavController;
@synthesize uploadNavController;
@synthesize offlineNavController;
@synthesize moreNavController;

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createTabBarControllers
{
    UIViewController *netDiskViewController = [[PCSNetDiskViewController alloc] init];
    netDiskNavController = [[UINavigationController alloc]initWithRootViewController:netDiskViewController];
    netDiskNavController.tabBarItem.title = @"云盘";
    PCS_FUNC_SAFELY_RELEASE(netDiskViewController);
    
    UIViewController *uploadViewController = [[PCSUploadViewController alloc] init];
    uploadNavController = [[UINavigationController alloc] initWithRootViewController:uploadViewController];
    uploadNavController.tabBarItem.title = @"上传";
    PCS_FUNC_SAFELY_RELEASE(uploadViewController);
    
    UIViewController *offlineViewController = [[PCSOfflineViewController alloc] init] ;
    offlineNavController = [[UINavigationController alloc] initWithRootViewController:offlineViewController];
    offlineNavController.tabBarItem.title = @"离线";
    PCS_FUNC_SAFELY_RELEASE(offlineViewController);
    
    UIViewController *moreViewController = [[PCSMoreViewController alloc] init];
    moreNavController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
    moreNavController.tabBarItem.title = @"更多";
    PCS_FUNC_SAFELY_RELEASE(moreViewController);
    
    NSArray   *controllers = [NSArray arrayWithObjects:
                              netDiskNavController,uploadNavController,offlineNavController,moreNavController, nil];
    
    self.viewControllers = controllers;
}


@end
