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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTableViewDataSource)
                                                     name:PCS_NOTIFICATION_RELOAD_DATA
                                                   object:nil];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                              forKeyPath:PCS_NOTIFICATION_RELOAD_DATA];
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
    
    self.files = [[PCSDBOperater shareInstance] getSubFolderFileListFromDB:self.path];
    
    [self creatNavigationBar];
//    [self addADBanner];
//    [self loadFileListFromServer];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    PCSLog(@"memory warning!");
}

- (void)reloadTableViewDataSource
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PCSLog(@"table view data source reload success.");
        self.files = [[PCSDBOperater shareInstance] getSubFolderFileListFromDB:self.path];
        selectCellIndexPath = nil;
        [self.mTableView reloadData];
    });
}

#pragma mark - 构建界面方法
- (void)creatNavigationBar
{    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"管理"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(onRightBarButtonAction:)];
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

- (PCSFileFormat)getFileTypeWith:(NSString *)name
{
    PCSFileFormat fileType = PCSFileFormatUnknown;
    NSString    *pathExtension = [name pathExtension];
    if ([pathExtension isEqualToString:@"txt"]) {
        fileType = PCSFileFormatTxt;
    } else if ([pathExtension isEqualToString:@"jpg"] ||
               [pathExtension isEqualToString:@"jpeg"] ||
               [pathExtension isEqualToString:@"png"] ||
               [pathExtension isEqualToString:@"gif"] ||
               [pathExtension isEqualToString:@"bmp"]) {
        fileType = PCSFileFormatJpg;
    } else if ([pathExtension isEqualToString:@"doc"] ||
               [pathExtension isEqualToString:@"docx"]) {
        fileType = PCSFileFormatDoc;
    } else if ([pathExtension isEqualToString:@"pdf"]) {
        fileType = PCSFileFormatPdf;
    } else if ([pathExtension isEqualToString:@"rar"] ||
               [pathExtension isEqualToString:@"zip"] ||
               [pathExtension isEqualToString:@"7z"] ||
               [pathExtension isEqualToString:@"tar"] ||
               [pathExtension isEqualToString:@"tgz"]) {
        fileType = PCSFileFormatZip;
    } else if ([pathExtension isEqualToString:@"mp3"] ||
               [pathExtension isEqualToString:@"pcm"] ||
               [pathExtension isEqualToString:@"wav"] ||
               [pathExtension isEqualToString:@"wma"] ||
               [pathExtension isEqualToString:@"aac"]) {
        fileType = PCSFileFormatAudio;
    } else if ([pathExtension isEqualToString:@"avi"] ||
               [pathExtension isEqualToString:@"wmv"] ||
               [pathExtension isEqualToString:@"mpeg"] ||
               [pathExtension isEqualToString:@"rmvb"] ||
               [pathExtension isEqualToString:@"rm"] ||
               [pathExtension isEqualToString:@"mp4"] ||
               [pathExtension isEqualToString:@"3gp"] ||
               [pathExtension isEqualToString:@"mov"]) {
        fileType = PCSFileFormatVideo;
    } 
    return fileType;
}

- (UIImage *)getThumbnailImageWith:(PCSFileFormat)type
{
    UIImage *image = nil;
    switch (type) {
        case PCSFileFormatDoc:
            image = [UIImage imageNamed:@"netdisk_type_word"];
            break;
        case PCSFileFormatJpg:
            image = [UIImage imageNamed:@"netdisk_type_picture"];
            break;
        case PCSFileFormatTxt:
            image = [UIImage imageNamed:@"netdisk_type_text"];
            break;
        case PCSFileFormatPdf:
            image = [UIImage imageNamed:@"netdisk_type_pdf"];
            break;
        case PCSFileFormatZip:
            image = [UIImage imageNamed:@"netdisk_type_zip"];
            break;
        case PCSFileFormatAudio:
            image = [UIImage imageNamed:@"netdisk_type_music"];
            break;
        case PCSFileFormatVideo:
            image = [UIImage imageNamed:@"netdisk_type_video"];
            break;
        case PCSFileFormatFolder:
            image = [UIImage imageNamed:@"netdisk_type_folder"];
            break;
        case PCSFileFormatUnknown:
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
                NSString    *fileName = [array objectAtIndex:(array.count - 1)];
                PCSFileInfoItem *item = [[PCSFileInfoItem alloc] init];
                item.name = fileName;
                item.size = tmp.size;
                item.hasSubFolder = tmp.hasSubFolder;
                item.serverPath = tmp.path;
                if (tmp.isDir) {
                    item.format = PCSFileFormatFolder;
                } else {
                    item.format = [self getFileTypeWith:fileName];
                }
                item.property = PCSFilePropertyDownLoad;
                item.ctime = tmp.cTime;
                item.mtime = tmp.mTime;
                [visibleFiles addObject:item];
                //文件数据入库
                [[PCSDBOperater shareInstance] saveFileInfoItemToDB:item];
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

- (void)onFavoritButtonAction
{
    BOOL result = NO;
    PCSFileInfoItem *item = [self.files objectAtIndex:selectCellIndexPath.row];
    if (item.property == PCSFilePropertyOffLine) { 
        result = [[PCSDBOperater shareInstance] updateFile:item.fid property:PCSFilePropertyDownLoad];
        if (result) {
            item.property = PCSFilePropertyDownLoad;
        }
        
    } else if (item.property == PCSFilePropertyDownLoad) {
        result = [[PCSDBOperater shareInstance] updateFile:item.fid property:PCSFilePropertyOffLine];
        if (result) {
            item.property = PCSFilePropertyOffLine;
        }
    }

    if (result) {
        //通知离线列表界面数据更新
        [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_RELOAD_OFFLINE_DATA
                                                            object:item];
        //更新当前界面数据
        [self.mTableView reloadData];
    }
}

- (void)onMoveButtonAction
{
    
}

- (void)onDeleteButtonAction:(id)sender
{
    UIButton    *button = (UIButton *)sender;
    button.userInteractionEnabled = NO;
    dispatch_queue_t    queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        PCSFileInfoItem *item = [self.files objectAtIndex:selectCellIndexPath.row];
        PCSSimplefiedResponse   *response = [PCS_APP_DELEGATE.pcsClient deleteFile:item.serverPath];
        if (response.errorCode == 0) {
            //从服务端删除成功，开始从本地数据库删除，并置位，更新界面数据
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL result = NO;
                result = [[PCSDBOperater shareInstance] updateFile:item.fid property:PCSFilePropertyDelete];
                if (result) {
                    [self reloadTableViewDataSource];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
            //删除失败，允许重新删除
                button.userInteractionEnabled = YES;
            });
        }
    });
}

#pragma mark - Table view data source

#define TABLEVIEW_NORMAL_CELL   @"NormalCell"
#define TABLEVIEW_EXPAND_CELL   @"ExpandCell"

#define PCS_TABLEVIEW_CELL_HEIGHT       50.0f
#define PCS_TAG_FILE_TYPE_IMAGEVIEW     10001
#define PCS_TAG_FILE_NAME_LABLE         10002
#define PCS_TAG_FILE_SIZE_LABLE         10003
#define PCS_TAG_FILE_DETAIL_LABLE       10007
#define PCS_TAG_EXPAND_FAVORIT_BUTTON   10004
#define PCS_TAG_EXPAND_MOVE_BUTTON      10005
#define PCS_TAG_EXPAND_DELETE_BUTTON    10006

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([selectCellIndexPath isEqual:indexPath]) {
        return (PCS_TABLEVIEW_CELL_HEIGHT + 50.0f);
        
    } else {
        return PCS_TABLEVIEW_CELL_HEIGHT;
    }
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
    static NSString *CellIdentifier = nil;
    if ([selectCellIndexPath isEqual:indexPath]) {
        CellIdentifier = TABLEVIEW_EXPAND_CELL;
    } else {
        CellIdentifier = TABLEVIEW_NORMAL_CELL;
    }
    
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
        
        UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 3, 170, 30)];
        nameLable.tag = PCS_TAG_FILE_NAME_LABLE;
        nameLable.font = [UIFont systemFontOfSize:20.0f];
        nameLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLable];
        PCS_FUNC_SAFELY_RELEASE(nameLable);
        
        UILabel *detailLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 28, 170, 20)];
        detailLable.tag = PCS_TAG_FILE_DETAIL_LABLE;
        detailLable.font = [UIFont systemFontOfSize:13.0f];
        detailLable.textColor = [UIColor lightGrayColor];
        detailLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:detailLable];
        PCS_FUNC_SAFELY_RELEASE(detailLable);
        
        UILabel *sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(235, 10, 75, 30)];
        sizeLable.tag = PCS_TAG_FILE_SIZE_LABLE;
        sizeLable.font = [UIFont systemFontOfSize:14.0f];
        sizeLable.backgroundColor = [UIColor clearColor];
        sizeLable.textColor = [UIColor grayColor];
        [cell.contentView addSubview:sizeLable];
        PCS_FUNC_SAFELY_RELEASE(sizeLable);
        
        if ([CellIdentifier isEqualToString:TABLEVIEW_EXPAND_CELL]) {
            UIView  *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, PCS_TABLEVIEW_CELL_HEIGHT, 320, 50)];
            mainView.backgroundColor = [UIColor grayColor];
            [cell.contentView addSubview:mainView];
            PCS_FUNC_SAFELY_RELEASE(mainView);

            UIButton    *favoritButton = [[UIButton alloc] initWithFrame:CGRectMake(15, PCS_TABLEVIEW_CELL_HEIGHT+5, 90, 40)];
            favoritButton.backgroundColor = [UIColor redColor];
            [favoritButton addTarget:self
                              action:@selector(onFavoritButtonAction)
                    forControlEvents:UIControlEventTouchUpInside];
            favoritButton.tag = PCS_TAG_EXPAND_FAVORIT_BUTTON;
            [cell.contentView addSubview:favoritButton];
            PCS_FUNC_SAFELY_RELEASE(favoritButton);
            
            UIButton    *moveButton = [[UIButton alloc] initWithFrame:CGRectMake(115, PCS_TABLEVIEW_CELL_HEIGHT+5, 90, 40)];
            moveButton.backgroundColor = [UIColor redColor];
            [moveButton addTarget:self
                           action:@selector(onMoveButtonAction)
                 forControlEvents:UIControlEventTouchUpInside];
            moveButton.tag = PCS_TAG_EXPAND_MOVE_BUTTON;
            [moveButton setTitle:@"移动" forState:UIControlStateNormal];
            [cell.contentView addSubview:moveButton];
            PCS_FUNC_SAFELY_RELEASE(moveButton);
            
            UIButton    *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(215, PCS_TABLEVIEW_CELL_HEIGHT+5, 90, 40)];
            deleteButton.backgroundColor = [UIColor redColor];
            [deleteButton addTarget:self
                             action:@selector(onDeleteButtonAction:)
                   forControlEvents:UIControlEventTouchUpInside];
            deleteButton.tag = PCS_TAG_EXPAND_DELETE_BUTTON;
            [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
            [cell.contentView addSubview:deleteButton];
            PCS_FUNC_SAFELY_RELEASE(deleteButton);
        }
    }
    
    PCSFileInfoItem *item = [self.files objectAtIndex:[indexPath row]];
    NSArray *array = [item.serverPath componentsSeparatedByString:@"/"];
    if (nil == array) {
        return cell;
    }
    UILabel *nameLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_FILE_NAME_LABLE];
    nameLable.text = item.name;
    
    UILabel *detailLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_FILE_DETAIL_LABLE];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:MM"];
    NSDate  *date = [NSDate dateWithTimeIntervalSince1970:item.mtime];
    detailLable.text = [dateFormat stringFromDate:date];
    PCS_FUNC_SAFELY_RELEASE(dateFormat);
    
    UIImageView *fileTypeImageView = (UIImageView *)[cell.contentView viewWithTag:PCS_TAG_FILE_TYPE_IMAGEVIEW];
    UILabel *sizeLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_FILE_SIZE_LABLE];
    fileTypeImageView.image = [self getThumbnailImageWith:item.format];
    if (item.format == PCSFileFormatFolder) {
        sizeLable.text = nil;//文件夹不显示大小
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        sizeLable.text = [NSString stringWithFormat:@"%.2fKB",((float)item.size/1024)];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    if ([CellIdentifier isEqualToString:TABLEVIEW_EXPAND_CELL]) {
        UIButton    *favoritButton = (UIButton *)[cell.contentView viewWithTag:PCS_TAG_EXPAND_FAVORIT_BUTTON];
        if (item.property == PCSFilePropertyDownLoad) {
            [favoritButton setTitle:@"收藏" forState:UIControlStateNormal];
        } else if (item.property == PCSFilePropertyOffLine) {
            [favoritButton setTitle:@"取消收藏" forState:UIControlStateNormal];
        }  
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCSFileInfoItem *item = [self.files objectAtIndex:[indexPath row]];
    
    if (item.format == PCSFileFormatFolder) {
        PCSNetDiskViewController *detailViewController = [[PCSNetDiskViewController alloc] init];
        detailViewController.path = [item.serverPath stringByAppendingString:@"/"];
        [[self navigationController] pushViewController:detailViewController animated:YES];
        [detailViewController release];
    } else {
        if([selectCellIndexPath isEqual:indexPath])
        {
            selectCellIndexPath =nil;
        }
        else {
            selectCellIndexPath = indexPath;
        }
        [tableView reloadData];
        [mTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
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
