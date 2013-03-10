//
//  PCSNetDiskViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSNetDiskViewController.h"
#import <objc/runtime.h>

@implementation PCSCommonFileInfo(PCSCommonFileInfo)

- (NSString *)description
{
    NSString *des = [NSString stringWithFormat:@"path:%@,size:%d,isDir:%d,hasSubFolder:%d",
                     self.path,self.size,self.isDir,self.hasSubFolder];
    return des;
}

@end


@interface PCSNetDiskViewController ()
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, retain) UITableView   *mTableView;
@end

@implementation PCSNetDiskViewController
@synthesize path;
@synthesize files;
@synthesize mTableView;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"我的云盘";
    }
    
    return self;
}

- (void)dealloc
{
    //
	// 腾讯MobWIN提示：开发者必须调用
	// 可在viewDidUnload调用或者在应用页面返回时调用或者在dealloc中调用
	// 目前已在viewWillDisappear中调用
	//
	[adBanner stopRequest];
	[adBanner removeFromSuperview];
    [path release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 342)];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    [self.view addSubview:mTableView];
    [mTableView release];
    
    [self creatNavigationBar];
    [self addADBanner];
    [self loadFileListFromServer];
    
    // Set the prompt text
    //    [[self navigationItem] setPrompt:@"just for directory test"];
}

#pragma mark - 构建界面方法
- (void)creatNavigationBar
{    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"管理"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self action:@selector(onRightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    PCS_FUNC_SAFELY_RELEASE(rightBarButton);
}

- (void)addADBanner
{
    adBanner = [[MobWinBannerView alloc] initMobWinBannerSizeIdentifier:MobWINBannerSizeIdentifier320x50];
	adBanner.rootViewController = self;
    adBanner.frame = CGRectMake(0, 317, 320, 10);
	[adBanner setAdUnitID:PCS_STRING_MOBWIN_UNIT_ID];
	[self.view addSubview:adBanner];
    
    //
	// 腾讯MobWIN提示：开发者可选调用
	// 获取MobWinBannerViewDelegate回调消息
	//
    adBanner.delegate = self;
    //
	// 腾讯MobWIN提示：开发者可选调用
	//
	adBanner.adGpsMode = NO;
	// adBanner.adTextColor = [UIColor whiteColor];
	// adBanner.adSubtextColor = [UIColor colorWithRed:255.0/255.0 green:162.0/255.0 blue:0.0/255.0 alpha:1];
	// adBanner.adBackgroundColor = [UIColor colorWithRed:2.0/255.0 green:12.0/255.0 blue:15.0/255.0 alpha:1];
	//
	
	//
	// 腾讯MobWIN提示：开发者必须调用
	//
	// 发起广告请求方法
	//
	[adBanner startRequest];
	[adBanner release];
}

#pragma mark - 数据处理方法
- (BOOL)isFileVaild:(NSString *)fileName
{
    if ([fileName hasPrefix:@"."]) {
        return NO;
    }
    
    if ([fileName hasSuffix:@".doc"]) {
        return NO;
    }
    return YES;
}

- (PCSFileType)getFileTypeWith:(NSString *)name
{
    PCSFileType fileType = PCSFileTypeUnknown;
    NSString    *pathExtension = [name pathExtension];
    if ([pathExtension isEqualToString:@"txt"]) {
        fileType = PCSFileTypeTxt;
    } else if ([pathExtension isEqualToString:@"jpg"]) {
        fileType = PCSFileTypeJpg;
    } else if ([pathExtension isEqualToString:@"doc"] || [pathExtension isEqualToString:@"docx"]) {
        fileType = PCSFileTypeDoc;
    }
    
    return fileType;
}

- (void)loadFileListFromServer
{
    PCSListInfoResponse *response = [PCS_APP_DELEGATE.pcsClient list:self.path:@"name":@"asc"];
    if(response){
        PCSLog(@"error code: %d\nmessage: %@\nitem_num: %d\n", response.status.errorCode, response.status.message, [response.list count]);
        
        NSMutableArray *visibleFiles = [[NSMutableArray alloc] init];
        for(int i = 0; i < [response.list count]; ++i){
            PCSCommonFileInfo *tmp = [response.list objectAtIndex:i];
            PCSLog(@"tmp:%@",tmp);
            if(tmp){
                [visibleFiles addObject:tmp];
            }
        }
        self.files = visibleFiles;
        PCS_FUNC_SAFELY_RELEASE(visibleFiles);
        PCSLog(@"message list:%@",response.list);
    }
}

#pragma mark - 按钮响应事件
- (void)onRightBarButtonAction:(id)sender
{
    UIBarButtonItem *barItem = nil;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        barItem = (UIBarButtonItem *)sender;
    }
    
    if (barItem != nil) {
        static  NSInteger   isSelect = 0;
        if (isSelect == 0) {
            barItem.title = @"完成";
            isSelect = 1;
        } else {
            barItem.title = @"管理";
            isSelect = 0;
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

#define PCS_TAG_FILE_TYPE_IMAGEVIEW     10001

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UIImageView *fileTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 14, 32, 32)];
        fileTypeImageView.tag = PCS_TAG_FILE_TYPE_IMAGEVIEW;
        [cell.contentView addSubview:fileTypeImageView];
        PCS_FUNC_SAFELY_RELEASE(fileTypeImageView);
    }
    
    PCSCommonFileInfo *item = [self.files objectAtIndex:[indexPath row]];
    NSArray *array = [item.path componentsSeparatedByString:@"/"];
    if (array != nil) {
        NSString    *fileName = [array objectAtIndex:(array.count - 1)];
        [[cell textLabel] setText:fileName];
    }

    if (item.isDir)
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    else
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [[cell textLabel] setEnabled:item.isDir];
    
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCSCommonFileInfo *item = [self.files objectAtIndex:[indexPath row]];
    if (item.isDir)
        return indexPath;
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCSCommonFileInfo *item = [self.files objectAtIndex:[indexPath row]];
    PCSNetDiskViewController *detailViewController = [[PCSNetDiskViewController alloc] init];
    detailViewController.path = item.path;
    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

#pragma mark - MobBanner View Delegate
- (void)bannerViewDidReceived {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

- (void)bannerViewFailToReceived {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

- (void)bannerViewDidPresentScreen {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

- (void)bannerViewDidDismissScreen {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

- (void)bannerViewWillLeaveApplication {
    NSLog(@"MobWIN %s", __FUNCTION__);
}

@end
