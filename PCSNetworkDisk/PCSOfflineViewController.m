//
//  PCSOfflineViewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSOfflineViewController.h"
#import "PCSPreviewController.h"
#import "MDAudioFile.h"
#import "MDAudioPlayerController.h"
#import "PCSVideoPlayerController.h"

@interface PCSOfflineViewController ()
@property(nonatomic,retain) IBOutlet    UITableView *mTableView;
@property(nonatomic,retain) NSDictionary  *offlineFileDictionary;
@property(nonatomic,retain) NSArray *sectionTitleArray;
@property(nonatomic,retain) NSIndexPath *currentOfflineFileIndexPath;
@property (nonatomic, retain) NSMutableArray    *photos;

@end

@implementation PCSOfflineViewController
@synthesize mTableView;
@synthesize offlineFileDictionary;
@synthesize sectionTitleArray;
@synthesize currentOfflineFileIndexPath;
@synthesize photos = _photos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"离线文件";
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
                                             selector:@selector(reloadOfflineTableViewData)
                                                 name:PCS_NOTIFICATION_RELOAD_OFFLINE_DATA
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateOfflineFile:)
                                                 name:PCS_NOTIFICATION_UPDATE_OFFLINE_FILE
                                               object:nil];
}

- (void)removeLocalNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCS_NOTIFICATION_RELOAD_OFFLINE_DATA
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCS_NOTIFICATION_UPDATE_OFFLINE_FILE
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect  rect = self.mTableView.frame;
    self.mTableView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+(iPhone5?88:0));

    [self reloadOfflineTableViewData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateOfflineFile:(NSNotification *)notification
{
    [self reloadOfflineTableViewData];
    PCSFileInfoItem    *item = notification.object;
    if (item.property == PCSFilePropertyDownLoad) {
        //将本地保存的文件从缓存中删除
        [[PCSDBOperater shareInstance] deleteFileFromOfflineCache:item.serverPath];
        //重新加载界面数据
    } else if (item.property == PCSFilePropertyOffLining) {
        //执行文件下载操作
        [self downloadFileFromServer:item];      
    }
}

- (void)downloadFileFromServer:(PCSFileInfoItem *)item
{
    if (item == nil) {
        return;
    }
    
    dispatch_queue_t queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        NSData *data = nil;
        PCSSimplefiedResponse *response = [PCS_APP_DELEGATE.pcsClient downloadFile:item.serverPath:&data:self];
        dispatch_sync(dispatch_get_main_queue(), ^{
            PCSFileProperty fileProperty = PCSFilePropertyNull;
            if (response.errorCode == 0) {
                PCSLog(@"download file :%@ from server success.",item.serverPath);
                [[PCSDBOperater shareInstance] saveFileToOfflineCache:data name:item.serverPath];
                fileProperty = PCSFilePropertyOffLineSuccess;   
            } else {
                PCSLog(@"download file :%@ from server failed.",item.serverPath);
                fileProperty = PCSFilePropertyOffLineFailed;
            }
            [[PCSDBOperater shareInstance] updateFile:item.fid property:fileProperty];
            //文件状态改变时，需要我的云盘界面数据
            [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_RELOAD_NETDISK_DATA
                                                                object:nil];
            //如果有处于等待下载中的离线文件，则将其下载
            PCSFileInfoItem    *nextOfflineFileItem = nil;
            nextOfflineFileItem = [[PCSDBOperater shareInstance] getNextOfflineFileItem];
            if (nextOfflineFileItem != nil) {
                //将等待状态的文件状态置为下载中
                [[PCSDBOperater shareInstance] updateFile:nextOfflineFileItem.fid property:PCSFilePropertyOffLining];
            }
            [self reloadOfflineTableViewData];
            //然后开始下载
            [self performSelector:@selector(downloadFileFromServer:)
                       withObject:nextOfflineFileItem
                       afterDelay:0.0f];
        });
    });
}

- (void)reloadOfflineTableViewData
{
    self.offlineFileDictionary = [[PCSDBOperater shareInstance] getOfflineFileFromDB];
    self.sectionTitleArray = [self creatSectionTitleArraryAsc];
    [self.mTableView reloadData];
}

- (NSArray *)creatSectionTitleArraryAsc
{
    NSArray *sorteArray = [[self.offlineFileDictionary allKeys] sortedArrayUsingComparator:^(id obj1, id obj2){
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sorteArray;
}

#pragma mark - Table view data source

#define OFFLINE_TABLEVIEW_HEIGHT         55.0f
#define TAG_OFFLINE_FILE_SIZE_LABLE      30001
#define TAG_OFFLINE_PROGRESSVIEW         30002
#define TAG_OFFLINE_MAIN_LABLE           30003
#define TAG_OFFLINE_DETAIL_LABLE         30004


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return OFFLINE_TABLEVIEW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString    *title = nil;
    NSString    *offlining = [NSString stringWithFormat:@"%d",PCSFilePropertyOffLining];
    NSString    *offlineSuccess = [NSString stringWithFormat:@"%d",PCSFilePropertyOffLineSuccess];
    NSString    *typeString = [self.sectionTitleArray objectAtIndex:section];
    if ([typeString isEqualToString:offlining]) {
        NSArray *offliningArray = [self.offlineFileDictionary objectForKey:offlining];
        if (offliningArray.count > 0) {
            title = [NSString stringWithFormat:@"下载中（%d）",offliningArray.count];
        }
    } else if ([typeString isEqualToString:offlineSuccess]) {
        NSArray *offlineSucessArray = [self.offlineFileDictionary objectForKey:offlineSuccess];
        if (offlineSucessArray.count > 0) {
            title = [NSString stringWithFormat:@"下载成功（%d）",offlineSucessArray.count];
        }
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    UIImage *image = [[UIImage imageNamed:@"upload_head_background"] stretchableImageWithLeftCapWidth:3 topCapHeight:6];
    imageView.image = image;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, 25)];
    titleLable.font = [UIFont systemFontOfSize:13.0f];
    titleLable.text = title;
    titleLable.backgroundColor = [UIColor clearColor];
    [imageView addSubview:titleLable];
    PCS_FUNC_SAFELY_RELEASE(titleLable);
    
    return [imageView autorelease];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self.offlineFileDictionary objectForKey:[self.sectionTitleArray
                                                                     objectAtIndex:section]];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
        UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 300, 30)];
        nameLable.backgroundColor = [UIColor clearColor];
        nameLable.lineBreakMode = UILineBreakModeMiddleTruncation;
        nameLable.font = PCS_MAIN_FONT;
        nameLable.textColor = PCS_MAIN_TEXT_COLOR;
        nameLable.tag = TAG_OFFLINE_MAIN_LABLE;
        [cell.contentView addSubview:nameLable];
        PCS_FUNC_SAFELY_RELEASE(nameLable);
        
        UILabel *detailLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 27, 200, 25)];
        detailLable.backgroundColor = [UIColor clearColor];
        detailLable.font = PCS_DETAIL_FONT;
        detailLable.textColor = PCS_DETAIL_TEXT_COLOR;
        detailLable.tag = TAG_OFFLINE_DETAIL_LABLE;
        [cell.contentView addSubview:detailLable];
        PCS_FUNC_SAFELY_RELEASE(detailLable);
        
        UILabel *sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(210, OFFLINE_TABLEVIEW_HEIGHT-27.0f, 90, 20)];
        sizeLable.backgroundColor = [UIColor clearColor];
        sizeLable.textColor = PCS_DETAIL_TEXT_COLOR;
        sizeLable.tag = TAG_OFFLINE_FILE_SIZE_LABLE;
        sizeLable.font = [UIFont systemFontOfSize:14.0f];
        [cell.contentView addSubview:sizeLable];
        PCS_FUNC_SAFELY_RELEASE(sizeLable);
        
        UIProgressView  *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 35, 180, 10)];
        progress.backgroundColor = [UIColor clearColor];
        if ([progress respondsToSelector:@selector(progressImage)]) {
            //由于IOS5以下系统不支持自定义背景图片和进度图片，这里做了匹配处理
            progress.progressImage = [[UIImage imageNamed:@"fax_list_progress_image"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            progress.trackImage = [[UIImage imageNamed:@"fax_list_progress_track_image"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
        }
        progress.tag = TAG_OFFLINE_PROGRESSVIEW;
        [cell.contentView addSubview:progress];
        PCS_FUNC_SAFELY_RELEASE(progress);
    }
    
    NSArray *sectionArray = [self.offlineFileDictionary objectForKey:[self.sectionTitleArray
                                                                     objectAtIndex:indexPath.section]];
    PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
    UILabel *mainLable = (UILabel *)[cell.contentView viewWithTag:TAG_OFFLINE_MAIN_LABLE];
    mainLable.text = fileItem.name;
    
    UIProgressView  *progress = (UIProgressView *)[cell.contentView viewWithTag:TAG_OFFLINE_PROGRESSVIEW];
    progress.hidden = YES;
    
    UILabel *detailLable = (UILabel *)[cell.contentView viewWithTag:TAG_OFFLINE_DETAIL_LABLE];
    if (fileItem.property == PCSFilePropertyOffLineSuccess) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm";
        NSDate  *date = [NSDate dateWithTimeIntervalSince1970:fileItem.mtime];
        detailLable.text = [dateFormatter stringFromDate:date];
        PCS_FUNC_SAFELY_RELEASE(dateFormatter);
    } else if (fileItem.property == PCSFilePropertyOffLineFailed) {
        detailLable.text = @"下载失败，点击重新下载";
    } else if (fileItem.property == PCSFilePropertyOffLineWaiting) {
        detailLable.text = @"等待下载...";
    } else if (fileItem.property == PCSFilePropertyOffLining) {
        progress.hidden = NO;
        detailLable.text = @" ";
        self.currentOfflineFileIndexPath = indexPath;
    }
    
    UILabel *sizeLable = (UILabel *)[cell.contentView viewWithTag:TAG_OFFLINE_FILE_SIZE_LABLE];
    float   fileSize = (float)fileItem.size/1024;
    if (fileSize < 1024) {
        sizeLable.text = [NSString stringWithFormat:@"%.2fKB",fileSize];
    } else {
        sizeLable.text = [NSString stringWithFormat:@"%.2fMB",fileSize/1024];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArray = [self.offlineFileDictionary objectForKey:[self.sectionTitleArray
                                                                     objectAtIndex:indexPath.section]];
    PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
    if (fileItem.property == PCSFilePropertyOffLineSuccess) {
        //上传成功的文件点击进入文件预览
        //从cache中获取文件数据失败时，可以从服务端直接下载
        switch (fileItem.format) {
            case PCSFileFormatJpg:
                [self showPhotoPreviewController:sectionArray
                               currentServerPath:fileItem.serverPath];
                break;
            case PCSFileFormatAudio:
                [self showAudioPlayerController:fileItem];
                break;
            case PCSFileFormatVideo:
                [self showVideoPlayerController:fileItem];
                break;
            case PCSFileFormatPdf:
            case PCSFileFormatDoc:
            case PCSFileFormatExcel:
            case PCSFileFormatTxt:
            case PCSFileFormatPpt:
            default:
                [self showDocumentPreviewController:fileItem];
                break;
        }
    } else if (fileItem.property == PCSFilePropertyOffLineFailed) {
        //下载失败的文件，单击后重新下载
        PCSLog(@"redownload file:%@",fileItem);
        [self downloadFileFromServer:fileItem];
    }
}

- (void)showVideoPlayerController:(PCSFileInfoItem *)item
{
    PCSVideoPlayerController    *videoPlayer = [[PCSVideoPlayerController alloc] initWithPath:item.serverPath type:PCSFolderTypeNetDisk];
    videoPlayer.title = item.name;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:videoPlayer];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nc.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentModalViewController:nc animated:YES];
    PCS_FUNC_SAFELY_RELEASE(nc);
    PCS_FUNC_SAFELY_RELEASE(videoPlayer);
}

- (void)showAudioPlayerController:(PCSFileInfoItem *)item
{
    MDAudioPlayerController *audioPlayer = [[MDAudioPlayerController alloc] initWithServerPath:item.serverPath
                                                                                    folderType:PCSFolderTypeOffline];
    audioPlayer.title = item.name;
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:audioPlayer];;
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nc.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentModalViewController:nc animated:YES];
    PCS_FUNC_SAFELY_RELEASE(nc);
    PCS_FUNC_SAFELY_RELEASE(audioPlayer);
}

- (void)showDocumentPreviewController:(PCSFileInfoItem *)item
{
    PCSPreviewController *previewController = [[PCSPreviewController alloc] init];
    previewController.filePath = item.serverPath;
    previewController.folderType = PCSFolderTypeOffline;
    previewController.title = item.name;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:previewController];;
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nc.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentModalViewController:nc animated:YES];
    PCS_FUNC_SAFELY_RELEASE(nc);
    PCS_FUNC_SAFELY_RELEASE(previewController);
}

- (void)showPhotoPreviewController:(NSArray *)files
                 currentServerPath:(NSString *)currentServerPath
{
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    NSInteger   pageIndex = 0;
    NSInteger   jpgCount = 0;
    for (NSInteger count = 0; count < files.count; count++) {
        PCSFileInfoItem *item = [files objectAtIndex:count];
        if (item.format == PCSFileFormatJpg) {
            photo = [MWPhoto photoWithServerPath:item.serverPath];
            if (photo != nil) {
                photo.folderType = PCSFolderTypeOffline;
                [photoArray addObject:photo];
                photo.caption = item.name;
                if ([item.serverPath isEqualToString:currentServerPath]) {
                    pageIndex = jpgCount;
                }
                jpgCount++;
            }
        }
    }
    
    self.photos = photoArray;
	
	// Create browser
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    //browser.wantsFullScreenLayout = NO;
    [browser setInitialPageIndex:pageIndex];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    
    PCS_FUNC_SAFELY_RELEASE(nc);
    PCS_FUNC_SAFELY_RELEASE(browser);
    PCS_FUNC_SAFELY_RELEASE(photoArray);
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

#pragma mark QLPreviewControllerDataSource
// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)index
{
    NSArray *sectionArray = [self.offlineFileDictionary objectForKey:[self.sectionTitleArray
                                                                      objectAtIndex:0]];
    PCSFileInfoItem *item = [sectionArray objectAtIndex:index];
    NSString    *extension = [item.serverPath pathExtension];
    NSString    *nameString = [[item.serverPath md5Hash] stringByAppendingFormat:@".%@",PCS_FUNC_SENTENCED_EMPTY(extension)];
    NSString *filePath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                           stringByAppendingPathComponent:PCS_FOLDER_OFFLINE_CACHE]
                          stringByAppendingPathComponent:nameString];
    NSURL   *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *sectionArray = [self.offlineFileDictionary objectForKey:[self.sectionTitleArray
                                                                         objectAtIndex:indexPath.section]];
        PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
        BOOL    result = NO;
        //先将文件从本地offlineCache文件夹中删除，再将文件的属性设置为下载状态
        [[PCSDBOperater shareInstance] deleteFileFromOfflineCache:fileItem.serverPath];
        result = [[PCSDBOperater shareInstance] updateFile:fileItem.fid property:PCSFilePropertyDownLoad];
        if (result) {
            [self reloadOfflineTableViewData];
            //文件状态改变时，我的云盘界面数据需要更新
            [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_RELOAD_NETDISK_DATA
                                                                object:nil];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes :(long)total
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
        UITableViewCell *cell = [self.mTableView cellForRowAtIndexPath:self.currentOfflineFileIndexPath];
        UIProgressView  *progress = (UIProgressView *)[cell.contentView viewWithTag:TAG_OFFLINE_PROGRESSVIEW];
        progress.progress = (float)bytes/(float)total;
    });
}

-(long)progressInterval
{
    return 1.0f;
}

-(BOOL)toContinue
{
    return YES;
}

@end
