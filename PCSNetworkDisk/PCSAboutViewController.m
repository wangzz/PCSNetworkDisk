//
//  PCSAboutViewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSAboutViewController.h"
#import "UIViewController+NavAddition.h"

@interface PCSAboutViewController ()
@property(nonatomic,retain) IBOutlet    UILabel *versionLable;

@end

@implementation PCSAboutViewController
@synthesize versionLable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"关于";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionLable.text = [NSString stringWithFormat:@"版本V%@",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    [self createNavBackButtonWithTitle:@"返回"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - On UIButton Action


@end
