//
//  PCSClearCacheViewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-8.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSClearCacheViewController.h"

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"MoreViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"清空离线文件本地缓存";
        
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"清空其他文件本地缓存";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        
    }
}

@end
