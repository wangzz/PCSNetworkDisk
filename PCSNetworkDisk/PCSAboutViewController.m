//
//  PCSAboutViewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSAboutViewController.h"

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
    [self createAboutNavigationBar];
}

- (void)createAboutNavigationBar
{
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(onLeftBarButtonAction)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    PCS_FUNC_SAFELY_RELEASE(leftBarButton);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - On UIButton Action
- (void)onLeftBarButtonAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
