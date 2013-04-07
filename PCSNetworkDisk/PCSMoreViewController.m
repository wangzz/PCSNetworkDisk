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


@interface PCSMoreViewController ()
@property(nonatomic,retain) IBOutlet    UITableView *mTableView;
@property(nonatomic,assign) long   volumeUsage;
@property(nonatomic,assign) long   volumeTotal;
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
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.volumeUsage = response.used;
                    self.volumeTotal = response.total;
                    NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
                    [self.mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index]
                                           withRowAnimation:UITableViewRowAnimationNone];
                });
            } else {
                PCSLog(@"get quota info failed.%@",response.status.message);
            }
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

- (NSString *)getFormatSizeString:(long)sizeBytes
{
    NSString    *formatString = nil;
    if (sizeBytes <= 1024) {
        formatString = [NSString stringWithFormat:@"%.2ldB",sizeBytes];
    } else if (sizeBytes/1024 <= 1024) {
        formatString = [NSString stringWithFormat:@"%.2ldKB",sizeBytes/1024];
    } else if (sizeBytes/(1024*1024) <= 1024) {
        formatString = [NSString stringWithFormat:@"%.2ldMB",sizeBytes/(1024*1024)];
    } else if (sizeBytes/(1024*1024*1024) <= 1024) {
        formatString = [NSString stringWithFormat:@"%.2ldGB",sizeBytes/(1024*1024*1024)];
    }
    return formatString;
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
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        UIProgressView  *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 27, 250, 7.5f)];
        progress.backgroundColor = [UIColor redColor];
        if ([progress respondsToSelector:@selector(progressImage)]) {
            //由于IOS5以下系统不支持自定义背景图片和进度图片，这里做了匹配处理
            progress.progressImage = [[UIImage imageNamed:@"fax_list_progress_image"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            progress.trackImage = [[UIImage imageNamed:@"fax_list_progress_track_image"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
        }
        progress.tag = PCS_TAG_MORE_PROGRESS;
        [cell.contentView addSubview:progress];
        PCS_FUNC_SAFELY_RELEASE(progress);
        
        UILabel *usageLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 23, 250, 15)];
        usageLable.textAlignment = NSTextAlignmentCenter;
        usageLable.tag = PCS_TAG_MORE_USAGE_LABLE;
        usageLable.font = [UIFont systemFontOfSize:13.5f];
        usageLable.backgroundColor = [UIColor greenColor];
        [cell.contentView addSubview:usageLable];
        PCS_FUNC_SAFELY_RELEASE(usageLable);
        
        UILabel *rightLable = [[UILabel alloc] initWithFrame:CGRectMake(135, 10, 142, 22)];
        rightLable.textAlignment = NSTextAlignmentRight;
        rightLable.lineBreakMode = NSLineBreakByTruncatingMiddle;
        rightLable.tag = PCS_TAG_MORE_RIGHT_LABLE;
        rightLable.font = [UIFont systemFontOfSize:16];
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
            if (self.volumeTotal != 0) {
                progress.progress = (float)(self.volumeUsage/self.volumeTotal);
            }
            
            usageLable.hidden = NO;
            NSString    *usage = [self getFormatSizeString:self.volumeUsage];
            NSString    *total = [self getFormatSizeString:self.volumeTotal];
            usageLable.text = [NSString stringWithFormat:@"%@/%@",usage,total];
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"磁盘清理";
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"密码锁";
        rightLable.hidden = NO;
        BOOL    usePassword = NO;
        usePassword = [[NSUserDefaults standardUserDefaults] boolForKey:PCS_BOOL_USE_PWD_LOCK];
        if (usePassword) {
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
    } else if (indexPath.section == 2) {
        BOOL    usePassword = NO;
        usePassword = [[NSUserDefaults standardUserDefaults] boolForKey:PCS_BOOL_USE_PWD_LOCK];
        if (usePassword) {
            //密码锁开启
        } else {
            //密码锁关闭
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            //给Hi网盘评分
            [self goToAppStoreGiveAMark];
        } else if (indexPath.row == 1) {
            //意见反馈
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setToRecipients:[NSArray arrayWithObject:@"wzzvictory_tjsd@163.com"]];            
            [picker setSubject:@"意见反馈"];
            [picker setMessageBody:@"it is a test." isHTML:NO];
            [self presentModalViewController:picker animated:YES];
            PCS_FUNC_SAFELY_RELEASE(picker);
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

-(void)goToAppStoreGiveAMark
{
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",547203890];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}


@end
