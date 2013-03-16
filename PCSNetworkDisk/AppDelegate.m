//
//  AppDelegate.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "AppDelegate.h"
#import "BaiduPCSClient.h"
#import "PCSRootViewController.h"

@implementation AppDelegate
@synthesize pcsClient;
@synthesize gcdQueue;
- (void)dealloc
{
    dispatch_release(gcdQueue);
    [pcsClient release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    gcdQueue  = dispatch_queue_create("com.wangzz.pcsnetdisk", NULL);
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:PCS_STRING_EVER_LAUNCHED]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:PCS_STRING_EVER_LAUNCHED];
        //firstLaunch实现判断是否首次登陆（该字段暂时没用）
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:PCS_STRING_FIRST_LAUNCH];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO
                                                forKey:PCS_STRING_FIRST_LAUNCH];
    }
    
    pcsClient = [[BaiduPCSClient alloc] init];
    
    self.viewController = [PCSRootViewController shareInstance];
    PCSControllerState   controllerState;
    BOOL    hasLogin = NO;
    hasLogin = [[NSUserDefaults standardUserDefaults]
                     boolForKey:PCS_STRING_IS_LOGIN];
    if (hasLogin) {
        controllerState = PCSControllerStateMain;
        NSString    *mpToken = [[NSUserDefaults standardUserDefaults]
                                    stringForKey:PCS_STRING_ACCESS_TOKEN];
        pcsClient.accessToken = mpToken;
    } else {
        controllerState = PCSControllerStateLogin;
    }
    [self.viewController showViewControllerWith:controllerState];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
