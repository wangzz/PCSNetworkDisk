//
//  PCSMoreViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSMoreViewController.h"
#import "PCSRootViewController.h"
#import "PCSAboutViewController.h"
#import <MessageUI/MessageUI.h>
#import "KKPasscodeLock.h"
#import "PCSClearCacheViewController.h"
#import "AppDelegate.h"


@interface PCSMoreViewController ()
@property(nonatomic,retain) IBOutlet    UITableView *mTableView;
@property(nonatomic,assign) float   volumeUsage;
@property(nonatomic,assign) float   volumeTotal;
@end

@implementation PCSMoreViewController
@synthesize mTableView;
@synthesize volumeUsage;
@synthesize volumeTotal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"更多";
        [self registerLoaclNotification];
    }
    return self;
}

- (void)dealloc
{
    [self removeLocalNotification];
    [super dealloc];
}

- (void)registerLoaclNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(alterViewFrameWithoutADBanner)
                                                 name:PCS_NOTIFICATION_SHOW_WITHOUT_AD_BANNER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(alterViewFrameWithADBanner)
                                                 name:PCS_NOTIFICATION_SHOW_WITH_AD_BANNER
                                               object:nil];
}

- (void)removeLocalNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCS_NOTIFICATION_SHOW_WITHOUT_AD_BANNER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCS_NOTIFICATION_SHOW_WITH_AD_BANNER
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect  rect;
    if (PCS_APP_DELEGATE.isADBannerShow) {
        rect = frameWithADBanner;
    } else {
        rect = frameWithoutADBanner;
    }
    mTableView = [[UITableView alloc] initWithFrame:rect
                                              style:UITableViewStyleGrouped];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mTableView];
    
    UIView  *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
    UIImage *normalImage = [[UIImage imageNamed:@"more_unregist"] stretchableImageWithLeftCapWidth:19 topCapHeight:20];
    UIImage *selectImage = [[UIImage imageNamed:@"more_unregisted"] stretchableImageWithLeftCapWidth:19 topCapHeight:20];
    UIButton    *logoffButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 300, 43)];
    [logoffButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [logoffButton setBackgroundImage:selectImage forState:UIControlStateHighlighted];
    [logoffButton setTitle:@"注销登录" forState:UIControlStateNormal];
    [logoffButton addTarget:self
                     action:@selector(onLogoffButtonAction)
           forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:logoffButton];
    self.mTableView.tableFooterView = footView;
    PCS_FUNC_SAFELY_RELEASE(logoffButton);
    PCS_FUNC_SAFELY_RELEASE(footView);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    UIImage *image = nil;
    if (iPhone5) {
        image = [UIImage imageNamed:@"background_iphone5.jpg"];
    } else {
        image = [UIImage imageNamed:@"background_iphone.jpg"];
    }
    imageView.image = image;
    [self.view insertSubview:imageView belowSubview:self.mTableView];
    PCS_FUNC_SAFELY_RELEASE(imageView);
}

- (void)alterViewFrameWithADBanner
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75f];
    self.mTableView.frame = frameWithADBanner;
    [UIView commitAnimations];
}

- (void)alterViewFrameWithoutADBanner
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75f];
    self.mTableView.frame = frameWithoutADBanner;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getQuotaInfo];
}

-(void)getQuotaInfo
{
    dispatch_queue_t    queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        PCSQuotaResponse *response = [PCS_APP_DELEGATE.pcsClient quotaInfo];
        if(response){
            if (response.status.errorCode == 0) {
                self.volumeUsage = response.used;
                self.volumeTotal = response.total;
                float    value = 10737418240.0;
                self.volumeTotal = value;//测试用
            } else {
                self.volumeTotal = 0;
                self.volumeUsage = 0;
                PCSLog(@"get quota info failed.%@",response.status.message);
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
                [self.mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index]
                                       withRowAnimation:UITableViewRowAnimationNone];
            });

        }
    });
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    } else if (section == 3) {
        return 3;
    } 
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#define PCS_TAG_MORE_PROGRESS       400001
#define PCS_TAG_MORE_USAGE_LABLE    400002
#define PCS_TAG_MORE_RIGHT_LABLE    400003
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"MoreViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = PCS_MAIN_FONT;
        cell.textLabel.textColor = PCS_MAIN_TEXT_COLOR;
        
        UIProgressView  *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(15, 27, 250, 7.5f)];
        progress.backgroundColor = [UIColor clearColor];
        if ([progress respondsToSelector:@selector(progressImage)]) {
            //由于IOS5以下系统不支持自定义背景图片和进度图片，这里做了匹配处理
            progress.progressImage = [[UIImage imageNamed:@"fax_list_progress_image"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            progress.trackImage = [[UIImage imageNamed:@"fax_list_progress_track_image"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
        }
        progress.tag = PCS_TAG_MORE_PROGRESS;
        [cell.contentView addSubview:progress];
        PCS_FUNC_SAFELY_RELEASE(progress);
        
        UILabel *usageLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 23, 250, 15)];
        usageLable.textAlignment = UITextAlignmentCenter;
        usageLable.tag = PCS_TAG_MORE_USAGE_LABLE;
        usageLable.font = PCS_DETAIL_FONT;
        usageLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:usageLable];
        PCS_FUNC_SAFELY_RELEASE(usageLable);
        
        UILabel *rightLable = [[UILabel alloc] initWithFrame:CGRectMake(135, 10, 142, 22)];
        rightLable.textAlignment = UITextAlignmentRight;
        rightLable.lineBreakMode = UILineBreakModeMiddleTruncation;
        rightLable.tag = PCS_TAG_MORE_RIGHT_LABLE;
        rightLable.font = PCS_MAIN_FONT;
        rightLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:rightLable];
        PCS_FUNC_SAFELY_RELEASE(rightLable);
    }
    
    UIProgressView  *progress = (UIProgressView *)[cell.contentView viewWithTag:PCS_TAG_MORE_PROGRESS];
    progress.progress = 0;
    progress.hidden = YES;
    
    UILabel *usageLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_MORE_USAGE_LABLE];
    usageLable.hidden = YES;
    
    UILabel *rightLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_MORE_RIGHT_LABLE];
    rightLable.textColor = [UIColor grayColor];
    rightLable.hidden = YES;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = nil;
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"登陆账号";
            rightLable.hidden = NO;
            rightLable.textColor = [UIColor greenColor];
            rightLable.text = [[NSUserDefaults standardUserDefaults] stringForKey:PCS_STRING_USER_NAME];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"容量";
            cell.detailTextLabel.text = @" ";
            progress.hidden = NO;
            usageLable.hidden = NO;
            if (self.volumeTotal != 0) {
                progress.progress = self.volumeUsage/self.volumeTotal;
                
                NSString    *usage = [[PCSDBOperater shareInstance] getFormatSizeString:self.volumeUsage];
                NSString    *total = [[PCSDBOperater shareInstance] getFormatSizeString:self.volumeTotal];
                usageLable.text = [NSString stringWithFormat:@"%@/%@",usage,total];
                usageLable.textColor = [UIColor lightGrayColor];
            } else {
                usageLable.text = @"获取容量数据失败";
                usageLable.textColor = [UIColor redColor];
            }
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"磁盘清理";
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"密码锁";
        rightLable.hidden = NO;
        if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
            rightLable.text = @"开启";
        } else {
            rightLable.text = @"关闭";
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"给Hi网盘评分！";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"意见反馈";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"关于";
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            rightLable.hidden = NO;
            rightLable.text = [NSString stringWithFormat:@"V%@",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        //临时文件清理
        PCSClearCacheViewController *clearCache = [[PCSClearCacheViewController alloc] initWithNibName:@"PCSClearCacheViewController"
                                                                                                bundle:nil];
        [self.navigationController pushViewController:clearCache animated:YES];
        PCS_FUNC_SAFELY_RELEASE(clearCache);
    } else if (indexPath.section == 2) {
        KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        PCS_FUNC_SAFELY_RELEASE(vc);
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            //给Hi网盘评分
            [self goToAppStoreGiveAMark];
        } else if (indexPath.row == 1) {
            //意见反馈
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                [picker setToRecipients:[NSArray arrayWithObject:@"wzzvictory_tjsd@163.com"]];
                [picker setSubject:@"意见反馈"];
                [picker setMessageBody:@"it is a test." isHTML:NO];
                
                //自定义做导航按钮
                UIButton *navButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 32)];
                navButton.backgroundColor  = [UIColor clearColor];
                UIColor *color = [UIColor colorWithRed:0.896f
                                                 green:0.948f
                                                  blue:1.0f
                                                 alpha:1.0f];
                [navButton setTitleColor:color forState:UIControlStateNormal];
                navButton.titleLabel.font = [UIFont systemFontOfSize:13.5f];
                [navButton setTitle:@"返回" forState:UIControlStateNormal];
                [navButton setBackgroundImage:[UIImage imageNamed:@"nav_button"]
                                     forState:UIControlStateNormal];
                [navButton setBackgroundImage:[UIImage imageNamed:@"nav_buttoned"]
                                     forState:UIControlStateHighlighted];
                [navButton addTarget:self
                              action:@selector(onNavBackButtonAction)
                    forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *navMenuBtn = [[UIBarButtonItem alloc] initWithCustomView:navButton];
                
                [[[[picker viewControllers] lastObject] navigationItem] setLeftBarButtonItem:navMenuBtn];
                PCS_FUNC_SAFELY_RELEASE(navMenuBtn);
                PCS_FUNC_SAFELY_RELEASE(navButton);
                
                picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:picker animated:YES];
                PCS_FUNC_SAFELY_RELEASE(picker);
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"您的手机不支持邮件发送，请到邮件设置中添加邮箱账号"
                                                               delegate:nil
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
                [alert show];
                PCS_FUNC_SAFELY_RELEASE(alert);
            }
        } else if (indexPath.row == 2) {
            //关于
            PCSAboutViewController  *about = [[PCSAboutViewController alloc] init];
            [self.navigationController pushViewController:about animated:YES];
            PCS_FUNC_SAFELY_RELEASE(about);
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result==MFMailComposeResultCancelled){
        PCSLog(@"Cancel!");
    }else if(result==MFMailComposeResultSent){
        PCSLog(@"OK!");
    }else if(result==MFMailComposeResultFailed){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"AAMFeedbackMailDidFinishWithError"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)onNavBackButtonAction
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)goToAppStoreGiveAMark
{
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",547203890];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)didSettingsChanged:(KKPasscodeSettingsViewController*)viewController
{
    [self.mTableView reloadData];
}

@end
