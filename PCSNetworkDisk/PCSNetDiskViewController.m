//
//  PCSNetDiskViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSNetDiskViewController.h"
#import "PCSFileInfoItem.h"

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
//    [self addADBanner];
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
    } else if ([pathExtension isEqualToString:@"jpg"] ||
               [pathExtension isEqualToString:@"jpeg"] ||
               [pathExtension isEqualToString:@"png"] ||
               [pathExtension isEqualToString:@"gif"] ||
               [pathExtension isEqualToString:@"bmp"]) {
        fileType = PCSFileTypeJpg;
    } else if ([pathExtension isEqualToString:@"doc"] ||
               [pathExtension isEqualToString:@"docx"]) {
        fileType = PCSFileTypeDoc;
    } else if ([pathExtension isEqualToString:@"pdf"]) {
        fileType = PCSFileTypePdf;
    } else if ([pathExtension isEqualToString:@"rar"] ||
               [pathExtension isEqualToString:@"zip"] ||
               [pathExtension isEqualToString:@"7z"] ||
               [pathExtension isEqualToString:@"tar"] ||
               [pathExtension isEqualToString:@"tgz"]) {
        fileType = PCSFileTypeZip;
    } else if ([pathExtension isEqualToString:@"mp3"] ||
               [pathExtension isEqualToString:@"pcm"] ||
               [pathExtension isEqualToString:@"wav"] ||
               [pathExtension isEqualToString:@"wma"] ||
               [pathExtension isEqualToString:@"aac"]) {
        fileType = PCSFileTypeMusic;
    } else if ([pathExtension isEqualToString:@"avi"] ||
               [pathExtension isEqualToString:@"wmv"] ||
               [pathExtension isEqualToString:@"mpeg"] ||
               [pathExtension isEqualToString:@"rmvb"] ||
               [pathExtension isEqualToString:@"rm"] ||
               [pathExtension isEqualToString:@"mp4"] ||
               [pathExtension isEqualToString:@"3gp"] ||
               [pathExtension isEqualToString:@"mov"]) {
        fileType = PCSFileTypeVideo;
    } 
    return fileType;
}

- (UIImage *)getThumbnailImageWith:(PCSFileType)type
{
    UIImage *image = nil;
    switch (type) {
        case PCSFileTypeDoc:
            image = [UIImage imageNamed:@"netdisk_type_word"];
            break;
        case PCSFileTypeJpg:
            image = [UIImage imageNamed:@"netdisk_type_picture"];
            break;
        case PCSFileTypeTxt:
            image = [UIImage imageNamed:@"netdisk_type_text"];
            break;
        case PCSFileTypePdf:
            image = [UIImage imageNamed:@"netdisk_type_pdf"];
            break;
        case PCSFileTypeZip:
            image = [UIImage imageNamed:@"netdisk_type_zip"];
            break;
        case PCSFileTypeMusic:
            image = [UIImage imageNamed:@"netdisk_type_music"];
            break;
        case PCSFileTypeVideo:
            image = [UIImage imageNamed:@"netdisk_type_video"];
            break;
        case PCSFileTypeFolder:
            image = [UIImage imageNamed:@"netdisk_type_folder"];
            break;
        case PCSFileTypeUnknown:
        default:
            image = [UIImage imageNamed:@"netdisk_type_default"];
            break;
    }
    return image;
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
            if(nil == tmp){
                continue;
            }
             
            NSArray *array = [tmp.path componentsSeparatedByString:@"/"];
            if (array != nil) {
                /*
                 @synthesize sid;
                 @synthesize name;
                 @synthesize serverPath;
                 @synthesize localPath;
                 @synthesize size;
                 @synthesize type;
                 @synthesize hasSubFolder;
                 @synthesize deleted;
                 @synthesize ctime;
                 @synthesize mtime;
                 @synthesize hasCache;
                */
                
                /*
                @property(strong, nonatomic) NSString *path;
                @property(assign, nonatomic) long mTime;
                @property(assign, nonatomic) long cTime;
                @property(strong, nonatomic) NSString *blockList;
                @property(assign, nonatomic) int size;
                @property(assign, nonatomic) BOOL isDir;
                @property(assign, nonatomic) BOOL hasSubFolder;
                */
                NSString    *fileName = [array objectAtIndex:(array.count - 1)];
                PCSFileInfoItem *item = [[PCSFileInfoItem alloc] init];
                item.name = fileName;
                item.size = tmp.size;
                item.hasSubFolder = tmp.hasSubFolder;
                item.serverPath = tmp.path;
                if (tmp.isDir) {
                    item.type = PCSFileTypeFolder;
                } else {
                    item.type = [self getFileTypeWith:fileName];
                }
                
                [visibleFiles addObject:item];
                PCS_FUNC_SAFELY_RELEASE(item);
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

#define PCS_TABLEVIEW_CELL_HEIGHT       50.0f
#define PCS_TAG_FILE_TYPE_IMAGEVIEW     10001
#define PCS_TAG_FILE_NAME_LABLE         10002
#define PCS_TAG_FILE_SIZE_LABLE         10003

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return PCS_TABLEVIEW_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIImageView *fileTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 9, 32, 32)];
        fileTypeImageView.tag = PCS_TAG_FILE_TYPE_IMAGEVIEW;
        fileTypeImageView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:fileTypeImageView];
        PCS_FUNC_SAFELY_RELEASE(fileTypeImageView);
        
        UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 170, 40)];
        nameLable.tag = PCS_TAG_FILE_NAME_LABLE;
        nameLable.font = [UIFont systemFontOfSize:20.0f];
        nameLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLable];
        PCS_FUNC_SAFELY_RELEASE(nameLable);
        
        UILabel *sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(235, 10, 75, 30)];
        sizeLable.tag = PCS_TAG_FILE_SIZE_LABLE;
        sizeLable.font = [UIFont systemFontOfSize:14.0f];
        sizeLable.backgroundColor = [UIColor clearColor];
        sizeLable.textColor = [UIColor grayColor];
        [cell.contentView addSubview:sizeLable];
        PCS_FUNC_SAFELY_RELEASE(sizeLable);
    }
    
    PCSFileInfoItem *item = [self.files objectAtIndex:[indexPath row]];
    NSArray *array = [item.serverPath componentsSeparatedByString:@"/"];
    if (nil == array) {
        return cell;
    }
    UILabel *nameLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_FILE_NAME_LABLE];
    nameLable.text = item.name;
    UILabel *sizeLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_FILE_SIZE_LABLE];
    sizeLable.text = [NSString stringWithFormat:@"%.3fKB",((float)item.size/1024)];
    UIImageView *fileTypeImageView = (UIImageView *)[cell.contentView viewWithTag:PCS_TAG_FILE_TYPE_IMAGEVIEW];
    fileTypeImageView.image = [self getThumbnailImageWith:item.type];
    if (item.type == PCSFileTypeFolder) {
        sizeLable.text = nil;//文件夹不显示大小
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCSFileInfoItem *item = [self.files objectAtIndex:[indexPath row]];
    if (item.type == PCSFileTypeFolder)
        return indexPath;
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCSFileInfoItem *item = [self.files objectAtIndex:[indexPath row]];
    PCSNetDiskViewController *detailViewController = [[PCSNetDiskViewController alloc] init];
    detailViewController.path = [item.serverPath stringByAppendingString:@"/"];
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
