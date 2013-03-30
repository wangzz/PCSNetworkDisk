//
//  PCSMoreViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSMoreViewController.h"
#import "PCSRootViewController.h"

@interface PCSMoreViewController ()
@property(nonatomic,retain) IBOutlet    UITableView *mTableView;
@end

@implementation PCSMoreViewController
@synthesize mTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"更多";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton    *logoffButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    logoffButton.backgroundColor = [UIColor redColor];
    [logoffButton setTitle:@"注销登录" forState:UIControlStateNormal];
    [logoffButton addTarget:self
                     action:@selector(onLogoffButtonAction)
           forControlEvents:UIControlEventTouchUpInside];
    self.mTableView.tableFooterView = logoffButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - 按钮响应事件
- (void)onLogoffButtonAction
{
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewController showViewControllerWith:PCSControllerStateLogin];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PCS_STRING_IS_LOGIN];
}

#pragma mark- UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger) tableView:(UITableView *)tableView
indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"MoreViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self goToAppStoreGiveAMark];
}

-(void)goToAppStoreGiveAMark
{
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",547203890];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}


@end
