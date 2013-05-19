//
//  PCSClearCacheViewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-8.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSClearCacheViewController.h"
#import "UIAlertView-Blocks/UIAlertView+Blocks.h"

@interface PCSClearCacheViewController ()
@property(nonatomic,retain) IBOutlet    UITableView *mTableView;

@end

@implementation PCSClearCacheViewController
@synthesize mTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"磁盘清理";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @"离线可用文件是保存到本地的文件，可以在离线环境下查看。";
    } else if (section == 1) {
        return @"其它缓存是指文件上传，或者在线查看文件过程中产生的本地文件。";
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"MoreViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellid];
        cell.textLabel.font = PCS_MAIN_FONT;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *offlinePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_FOLDER_OFFLINE_CACHE];
            NSString    *unitString = [[PCSDBOperater shareInstance] getFormatSizeString:
                                       [[PCSDBOperater shareInstance] folderSizeAtPath:offlinePath]];
            cell.textLabel.text = [NSString stringWithFormat:@"离线可用(已使用%@)",unitString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"                 清空离线可用文件";
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *netPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_FOLDER_NET_CACHE];
            
            NSString *uploadPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_FOLDER_UPLOAD_CACHE];
            
            long long size = [[PCSDBOperater shareInstance] folderSizeAtPath:netPath] + [[PCSDBOperater shareInstance] folderSizeAtPath:uploadPath];
            
            NSString    *unitString = [[PCSDBOperater shareInstance] getFormatSizeString:size];
            cell.textLabel.text = [NSString stringWithFormat:@"其它缓存(已使用%@)",unitString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"              清空其他文件本地缓存";
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        void (^clearAction)();
        NSString    *message = nil;
        if (indexPath.section == 0) {
            message = @"确定清空离线可用文件？";
            clearAction = ^{
                NSString *offlinePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_FOLDER_OFFLINE_CACHE];
                BOOL    result = NO;
                result = [[PCSDBOperater shareInstance] clearDataAtPath:offlinePath];
                if (result) {
                    [self.mTableView reloadData];
                }
                
                result = [[PCSDBOperater shareInstance] resetOfflineSuccessFileStatus];
                if (result) {
                    //更新我的云盘和离线两个界面数据
                    [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_RELOAD_OFFLINE_DATA
                                                                        object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_RELOAD_NETDISK_DATA
                                                                        object:nil];
                }
            };
        } else if (indexPath.section == 1) {
            message = @"确定清空其它缓存文件？";
            clearAction = ^{
                NSString *netPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_FOLDER_NET_CACHE];
                
                NSString *uploadPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_FOLDER_UPLOAD_CACHE];
                BOOL    clearNetPathResult = NO;
                BOOL    clearUploadPathResult = NO;
                clearNetPathResult = [[PCSDBOperater shareInstance] clearDataAtPath:netPath];
                clearUploadPathResult = [[PCSDBOperater shareInstance] clearDataAtPath:uploadPath];
                if (clearNetPathResult || clearUploadPathResult) {
                    [self.mTableView reloadData];
                }
            };
        }
        RIButtonItem *cancelItem = [RIButtonItem item];
        cancelItem.label = @"取消";

        RIButtonItem *doItem = [RIButtonItem item];
        doItem.label = @"清空";
        doItem.action = clearAction;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                        message:message
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:doItem, nil];
        [alert show];
        PCS_FUNC_SAFELY_RELEASE(alert);
    }
}

@end
