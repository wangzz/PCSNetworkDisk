//
//  PCSRootViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSRootViewController.h"
#import "PCSLoginViewController.h"
#import "PCSMainTabBarController.h"

@interface PCSRootViewController ()

@end

@implementation PCSRootViewController
@synthesize currentControllerState;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationBarHidden = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(PCSRootViewController *)shareInstance
{
    static dispatch_once_t once;
    static PCSRootViewController *instance;
    dispatch_once(&once, ^{
        instance = [[PCSRootViewController alloc] init];
    });
    return instance;
}

- (void)showViewControllerWith:(PCSControllerState)nextControllerState
{
    switch (nextControllerState) {
        case PCSControllerStateLogin:
            [self showLoginViewController];
            break;
        case PCSControllerStateHelp:
            break;
        case PCSControllerStateMain:
            [self showMainViewController];
            break;
        case PCSControllerStateResetPwd:
            break;
        default:
            break;
    }
    self.currentControllerState = nextControllerState;
}

- (void)showLoginViewController
{
    if (self.viewControllers.count == 0) {
        //软件启动直接进tab界面
        PCSLoginViewController  *loginController = [[PCSLoginViewController alloc] init];
        [self pushViewController:loginController animated:YES];
        PCS_FUNC_SAFELY_RELEASE(loginController);
        
    }else if (self.viewControllers.count == 1) {
        //由其他界面进入tab界面
        PCSLoginViewController  *loginController = [[PCSLoginViewController alloc] init];
        id object = [self.viewControllers objectAtIndex:0];
        NSArray *arr = [NSArray arrayWithObjects:loginController,object, nil];
        [self setViewControllers:arr animated:NO];
        [self popViewControllerAnimated:NO];
        PCS_FUNC_SAFELY_RELEASE(loginController);
    }
}


- (void)showMainViewController
{
    if (self.viewControllers.count == 0) {
        //软件启动直接进tab界面
        PCSMainTabBarController  *mainController = [[PCSMainTabBarController alloc] init];
        [self pushViewController:mainController animated:YES];
        PCS_FUNC_SAFELY_RELEASE(mainController);
        
    }else if (self.viewControllers.count == 1) {
        //由其他界面进入tab界面
        PCSMainTabBarController  *mainController = [[PCSMainTabBarController alloc] init];
        id object = [self.viewControllers objectAtIndex:0];
        NSArray *arr = [NSArray arrayWithObjects:mainController,object, nil];
        [self setViewControllers:arr animated:NO];
        [self popViewControllerAnimated:NO];
        PCS_FUNC_SAFELY_RELEASE(mainController);
    }
}


@end
