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

#pragma mark - 屏幕旋转控制
///iOS6.0之前
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationMaskPortrait);
}

///iOS6.0
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
        case PCSControllerStatePasscode:
            [self showPasscodeViewController];
            break;
        default:
            break;
    }
    self.currentControllerState = nextControllerState;
}

- (void)showLoginViewController
{
    BaiduOAuth *loginController = [[BaiduOAuth alloc] init];
    loginController.apiKey = PCS_STRING_BAIDU_API_KEY; //此处的api key 对应在百度开发者中心申请的应用对应的api key
    loginController.delegate = self;
    if (self.viewControllers.count == 0) {
        //软件启动直接进tab界面
        [self pushViewController:loginController animated:YES];
    }else if (self.viewControllers.count == 1) {
        //由其他界面进入tab界面
        id object = [self.viewControllers objectAtIndex:0];
        NSArray *arr = [NSArray arrayWithObjects:loginController,object, nil];
        [self setViewControllers:arr animated:NO];
        [self popViewControllerAnimated:NO];
    }
    PCS_FUNC_SAFELY_RELEASE(loginController);
}

- (void)showMainViewController
{
    PCSMainTabBarController  *mainController = [[PCSMainTabBarController alloc] init];
    if (self.viewControllers.count == 0) {
        //软件启动直接进tab界面
        [self pushViewController:mainController animated:YES];        
    }else if (self.viewControllers.count == 1) {
        //由其他界面进入tab界面
        id object = [self.viewControllers objectAtIndex:0];
        NSArray *arr = [NSArray arrayWithObjects:mainController,object, nil];
        [self setViewControllers:arr animated:NO];
        [self popViewControllerAnimated:NO];  
    }
    PCS_FUNC_SAFELY_RELEASE(mainController);
}

- (void)showPasscodeViewController
{
    KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    vc.delegate = self;
    vc.mode = KKPasscodeModeEnter;
    [self pushViewController:vc animated:YES];
    PCS_FUNC_SAFELY_RELEASE(vc);
}

#pragma mark - KKPasscodeViewControllerDelegate
- (void)didPasscodeEnteredCorrectly:(KKPasscodeViewController*)viewController
{
    PCSLog(@"passcode enter correctly.");
    [self showViewControllerWith:PCSControllerStateMain];
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController
{
    PCSLog(@"passcode enter incorrectly.");
}

- (void)shouldEraseApplicationData:(KKPasscodeViewController*)viewController
{
    PCSLog(@"passcode should erase app data.");
}

#pragma mark - Baidu OAuth Response Delegate
// success to get access token
-(void)onSuccess:(BaiduOAuthResponse*)response
{
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance] saveLoginInfoToDB:response];
    if (!result) {
        PCSLog(@"login err,save login info to DB err.");
        return;
    }
    [PCS_APP_DELEGATE.viewController showViewControllerWith:PCSControllerStateMain];
    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:PCS_STRING_IS_LOGIN];
    [[NSUserDefaults standardUserDefaults] setValue:response.accessToken
                                             forKey:PCS_STRING_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setValue:response.userName
                                             forKey:PCS_STRING_USER_NAME];
    PCS_APP_DELEGATE.pcsClient.accessToken = response.accessToken;
    PCSLog(@"%@",[NSString stringWithFormat:@"login success./nAccess Token:%@  User Name:%@  Expres In %@", response.accessToken, response.userName, response.expiresIn]);
}

// fail to get access token
-(void)onError:(NSString*)error
{
    PCSLog(@"%@", error);
}

// cancel
-(void)onCancel
{
    PCSLog(@"onCancel");
}


@end
