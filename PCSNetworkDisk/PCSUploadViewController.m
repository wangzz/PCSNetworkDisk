//
//  PCSUploadViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSUploadViewController.h"
#import "HSDirectoryNavigationController.h"
#import "AGImagePickerController/AGImagePickerController.h"
#import "AGImagePickerController/AGIPCToolbarItem.h"
#import <AVFoundation/AVFoundation.h>
#import "PCSVideoPlayerController.h"


@interface PCSUploadViewController ()
@property (nonatomic,retain) IBOutlet   UITableView *mTableView;
@property (nonatomic,retain) NSDictionary   *uploadFileDictionary;
@property (nonatomic,retain) NSArray   *sectionTitleArray;
@property (nonatomic,retain) NSIndexPath *currentUploadFileIndexPath;//当前正在上传的文件index
@property (nonatomic,retain) NSMutableArray *selectedPhotos;//保存从相册中选中的图片信息
@property (nonatomic, retain) NSMutableArray    *photos;

@end


#define UPLOAD_TABLEVIEW_HEIGHT         50.0f
#define TAG_UPLOAD_FILE_SIZE_LABLE      20001
#define TAG_UPLOAD_PROGRESSVIEW         20002

@implementation PCSUploadViewController
@synthesize mTableView;
@synthesize uploadFileDictionary;
@synthesize sectionTitleArray;
@synthesize currentUploadFileIndexPath;
@synthesize selectedPhotos;
@synthesize photos = _photos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"上传记录";
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createTableViewHeaderView];
    [self reloadTableDataSource];
    CGRect  rect = self.mTableView.frame;
    self.mTableView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+(iPhone5?88:0));
}

- (void)createTableViewHeaderView
{
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    headerView.userInteractionEnabled = YES;
    headerView.backgroundColor = [UIColor lightGrayColor];
    UIButton    *addPicBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 13, 73, 44)];
    addPicBtn.tag = 1001;
    addPicBtn.titleLabel.font = PCS_MAIN_FONT;
    [addPicBtn setTitle:@"上传图片" forState:UIControlStateNormal];
    addPicBtn.backgroundColor = [UIColor redColor];
    [addPicBtn addTarget:self
                  action:@selector(onButtonAction:)
        forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:addPicBtn];
    
//    UIButton    *addCameraPicBtn = [[UIButton alloc] initWithFrame:CGRectMake(119, 13, 73, 44)];
//    addCameraPicBtn.tag = 1002;
//    addCameraPicBtn.titleLabel.font = PCS_MAIN_FONT;
//    [addCameraPicBtn setTitle:@"拍摄图片" forState:UIControlStateNormal];
//    addCameraPicBtn.backgroundColor = [UIColor redColor];
//    [addCameraPicBtn addTarget:self
//                  action:@selector(onButtonAction:)
//        forControlEvents:UIControlEventTouchUpInside];
//    [headerView addSubview:addCameraPicBtn];
    
    UIButton    *addFileBtn = [[UIButton alloc] initWithFrame:CGRectMake(119, 13, 73, 44)];
    addFileBtn.tag = 1003;
    addFileBtn.titleLabel.font = PCS_MAIN_FONT;
    [addFileBtn setTitle:@"上传视频" forState:UIControlStateNormal];
    addFileBtn.backgroundColor = [UIColor redColor];
    [addFileBtn addTarget:self
                        action:@selector(onButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:addFileBtn];
    
    self.mTableView.tableHeaderView = headerView;
    PCS_FUNC_SAFELY_RELEASE(headerView);
    PCS_FUNC_SAFELY_RELEASE(addFileBtn);
//    PCS_FUNC_SAFELY_RELEASE(addCameraPicBtn);
    PCS_FUNC_SAFELY_RELEASE(addPicBtn);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 构建界面
- (void)getMediaFromSource:(PCSImagePickerType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        
        if (sourceType == PCSImagePickerTypePhoto || sourceType == PCSImagePickerTypeVideo) {
            AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
                NSLog(@"Fail. Error: %@", error);
                
                if (error == nil) {
                    [self.selectedPhotos removeAllObjects];
                    NSLog(@"User has cancelled.");
                    [self dismissModalViewControllerAnimated:YES];
                } else {
                    
                    // We need to wait for the view controller to appear first.
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self dismissModalViewControllerAnimated:YES];
                    });
                }
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault 
                                                            animated:YES];
                
            } andSuccessBlock:^(NSString* path,NSArray *info) {
                [self.selectedPhotos setArray:info];

                [self dismissModalViewControllerAnimated:YES];
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault 
                                                            animated:YES];
                
                [self imagePickerDidFinishWith:path 
                                          info:info 
                                          type:sourceType];
                
            }];
            
            // Show saved photos on top
            imagePickerController.imagePickerType = sourceType;
            imagePickerController.shouldShowSavedPhotosOnTop = YES;
            imagePickerController.selection = self.selectedPhotos;
    
            [self presentModalViewController:imagePickerController animated:YES];
            [imagePickerController release];
        } else if (sourceType == PCSImagePickerTypeCamera) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.videoQuality = UIImagePickerControllerQualityTypeLow;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:picker animated:YES];
            PCS_FUNC_SAFELY_RELEASE(picker);
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您的设备不支持访问多媒体文件目录！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (NSInteger)getRandomNumber
{
    //获得六位随机整数
    NSInteger   random = (arc4random() % 89999) + 100000;
    return random;
}

- (void)imagePickerDidFinishWith:(NSString *)path 
                       info:(NSArray *)info 
                       type:(PCSImagePickerType)type
{
    dispatch_queue_t    queue = dispatch_queue_create("com.wangzz.image", NULL);
    dispatch_async(queue, ^{
        PCSLog(@"upload path:%@",path);
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"yyyy-MM-dd";
        NSString    *fileName = nil;
        NSString    *target = nil;
        NSString    *dateString = nil;
        for (NSInteger index = 0; index < info.count; index++) {
            ALAsset *asset = [info objectAtIndex:index];
            NSString    *urlString = [asset defaultRepresentation].url.absoluteString;
            dateString = [NSString stringWithFormat:@"%@_%d",[dateFormat stringFromDate:[NSDate date]],[self getRandomNumber]];
            if (type == PCSImagePickerTypePhoto) {
                fileName = [NSString stringWithFormat:@"Photo_%@.jpg",dateString];
                target = [NSString stringWithFormat:@"%@%@",path,fileName];
            } else if (type == PCSImagePickerTypeVideo) {
                fileName =[NSString stringWithFormat:@"Video_%@.mov",dateString];
                target = [NSString stringWithFormat:@"%@%@",path,fileName];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uploadNewFileToServer:fileName
                                  localPath:urlString
                                 serverPath:target];

            });
        }
        PCS_FUNC_SAFELY_RELEASE(dateFormat);
    });
    dispatch_release(queue);
}

- (void)saveImageToLocal:(NSString *)urlString serverPath:(NSString *)serverPath
{
    __block ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    NSURL *url = [NSURL URLWithString:urlString];
    __block NSData  *imageData = nil;
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
        UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        imageData = UIImagePNGRepresentation(image);
        PCSLog(@"image url:%@",urlString);
        //保存图片到本地
        [[PCSDBOperater shareInstance] saveFileToUploadCache:imageData name:serverPath];
        //上传图片到服务器
        [self uploadFile:imageData name:serverPath];            PCS_FUNC_SAFELY_RELEASE(assetLibrary);
    }failureBlock:^(NSError *error) {
        PCSLog(@"error=%@",error);
        PCS_FUNC_SAFELY_RELEASE(assetLibrary);
    }];
}

- (void)saveVideoToLocal:(NSString *)urlString serverPath:(NSString *)serverPath
{
    NSURL   *url = [NSURL URLWithString:urlString];
    AVURLAsset * urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:urlAsset
                                                                             presetName:AVAssetExportPresetMediumQuality];
    //其他值可以查看，根据自己的需求确定
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    NSString    *extension = [serverPath pathExtension];
    NSString    *nameString = [[serverPath md5Hash] stringByAppendingFormat:@".%@",PCS_FUNC_SENTENCED_EMPTY(extension)];
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                      stringByAppendingPathComponent:PCS_FOLDER_UPLOAD_CACHE]
                      stringByAppendingPathComponent:nameString];
    exportSession.outputURL = [NSURL fileURLWithPath:path];//输出的保存路径，文件不能已存在
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusUnknown:
                PCSLog(@"exportSession.status AVAssetExportSessionStatusUnknown");
                break;
            case AVAssetExportSessionStatusWaiting:
                PCSLog(@"exportSession Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                PCSLog(@"exportSession Exporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                PCSLog(@"exportSession Completed");
                NSData  *data = [NSData dataWithContentsOfFile:path];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //真正的上传操作
                    [self uploadFile:data name:serverPath];
                });
                break;
            case AVAssetExportSessionStatusFailed:
                PCSLog(@"exportSession Failed");
                PCSLog(@"error:%@",exportSession.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                PCSLog(@"exportSession Cancelled");
                break;
            default:
                break;
        } 
    }];
}

#pragma mark - 数据处理
- (void)uploadTest
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:@"/Cocoa.pdf"];
    NSData  *data = [NSData dataWithContentsOfFile:filePath];
    NSString    *fileName = @"世界真美好.pdf";
    NSString *target = [[NSString alloc] initWithFormat:@"%@%@",PCS_STRING_DEFAULT_PATH,fileName];
    
//    [self uploadNewFileToServer:fileName path:target];
    PCS_FUNC_SAFELY_RELEASE(target);
}

//新选取的文件信息入库，文件缓存等操作，并根据操作结果判断是否需要立马上传服务器
- (void)uploadNewFileToServer:(NSString *)fileName 
                    localPath:(NSString *)localPath 
                   serverPath:(NSString *)serverPath
{
    PCSFileInfoItem *fileItem = [[PCSFileInfoItem alloc] init];
    fileItem.name = fileName;
    fileItem.parentPath = localPath;
    fileItem.serverPath = serverPath;
    fileItem.size = 0;
    fileItem.format = [[PCSDBOperater shareInstance] getFileTypeWith:fileName];
    fileItem.mtime = [[NSDate date] timeIntervalSince1970];
    
    BOOL    hasUploadingFile = NO;
    //判断是否有正在上传的文件
    hasUploadingFile = [[PCSDBOperater shareInstance] hasUploadingFile];
    if (hasUploadingFile) {
        //如果已经有正在上传的文件，就将本次要上传的文件加入到下载队列中（状态置位等待上传）
        fileItem.property = PCSFileUploadStatusWaiting;
    } else {
        //在此之前没有正在上传的文件，就将文件状态置为上传中，并且开始上传
        fileItem.property = PCSFileUploadStatusUploading;
    }
    
    BOOL result = NO;
    //文件信息入库
    result = [[PCSDBOperater shareInstance] saveUploadFileToDB:fileItem];
    if (result) {
        [self reloadTableDataSource];
        
        if (!hasUploadingFile) {
            //当前没有正在上传的文件时，才立马开始上传，否则只是将文件加入到下载队列中
            [self getFileUploadToServer:fileItem.format
                              localPath:fileItem.parentPath 
                             serverPath:fileItem.serverPath];
        }
    }
    PCS_FUNC_SAFELY_RELEASE(fileItem);
}

//开始下一个等待上传文件的上传操作
- (void)uploadNextWaitingFileToServer
{
    PCSFileInfoItem *item = nil;
    item = [[PCSDBOperater shareInstance] getNextUploadFileInfo];
    if (item != nil) {
        BOOL    result = NO;
        //更新文件状态为上传中
        PCSLog(@"******************update %@ status to uploading",item.serverPath);
        result = [[PCSDBOperater shareInstance] updateUploadFile:item.serverPath
                                                          status:PCSFileUploadStatusUploading];
        if (result) {
            //更新文件状态成功后，更新界面显示，并开始上传操作
            [self getFileUploadToServer:item.format
                              localPath:item.parentPath 
                             serverPath:item.serverPath];
            [self reloadTableDataSource];
        }
    }
}

//将上传失败的文件重新上传
- (void)reuploadFileToServer:(PCSFileInfoItem *)item
{
    BOOL    result = NO;
    //更新文件状态为上传中
    result = [[PCSDBOperater shareInstance] updateUploadFile:item.serverPath
                                                      status:PCSFileUploadStatusUploading];
    if (result) {
        [self getFileUploadToServer:item.format
                          localPath:item.parentPath 
                         serverPath:item.serverPath];
        [self reloadTableDataSource];
    }
}

//进行实际的服务器上传操作
- (void)getFileUploadToServer:(PCSFileFormat)format
                    localPath:(NSString *)localPath
                   serverPath:(NSString *)serverPath
{
    if (nil == localPath || nil == serverPath) {
        PCSLog(@"upload err,the file info is nil.");
        BOOL    result = NO;
        //更新文件状态
        result = [[PCSDBOperater shareInstance] updateUploadFile:serverPath
                                                          status:PCSFileUploadStatusFailed];
        if (result) {
            [self reloadTableDataSource];
            //如果有等待上传的文件，则将其上传
            [self uploadNextWaitingFileToServer];
        }
        return;
    }
    
    UITableViewCell *cell = [self.mTableView cellForRowAtIndexPath:self.currentUploadFileIndexPath];
    UIProgressView  *progress = (UIProgressView *)[cell.contentView viewWithTag:TAG_UPLOAD_PROGRESSVIEW];
    progress.progress = 0;
    
    if (format == PCSFileFormatJpg) {
        [self saveImageToLocal:localPath serverPath:serverPath];
    } else if (format == PCSFileFormatVideo) {
        [self saveVideoToLocal:localPath serverPath:serverPath];
    }
}

- (void)uploadFile:(NSData *)data name:(NSString *)name
{
    dispatch_queue_t queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        PCSFileInfoResponse *response = [PCS_APP_DELEGATE.pcsClient uploadData:data
                                                                              :name
                                                                              :self];
        PCSSimplefiedResponse   *result = response.status;
        PCSFileUploadStatus newStatus = PCSFileUploadStatusNull;
        if (result.errorCode != 0) {
            PCSLog(@"upload file err,errCode:%d,message:%@",response.status.errorCode,response.status.message);
            newStatus = PCSFileUploadStatusFailed;
        } else {
            PCSLog(@"upload file :%@ success",name);
            newStatus = PCSFileUploadStatusSuccess;
        }
        
        PCSCommonFileInfo   *fileInfo = response.commonFileInfo;
        dispatch_sync(dispatch_get_main_queue(), ^{
            BOOL    result = NO;
            
            //更新文件大小
            [[PCSDBOperater shareInstance] updateUploadFile:fileInfo.path
                                                       size:fileInfo.size];
            //更新文件状态
            result = [[PCSDBOperater shareInstance] updateUploadFile:fileInfo.path
                                                              status:newStatus];
            
            if (result) {
                [self reloadTableDataSource];
                //发送开始数据更新操作通知
                [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_INCREMENT_UPDATE
                                                                    object:nil];
                //如果有等待上传的文件，则将其上传
                [self uploadNextWaitingFileToServer];
            }
        });
    });
}

- (void)reloadTableDataSource
{
    self.uploadFileDictionary = [[PCSDBOperater shareInstance] getUploadFileFromDB];
    self.sectionTitleArray = [self.uploadFileDictionary allKeys];
    [self.mTableView reloadData];
}

#pragma mark - 按钮响应事件
- (void)onButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1001) {
        [self getMediaFromSource:PCSImagePickerTypePhoto];
    } else if (button.tag == 1002) {
        [self getMediaFromSource:PCSImagePickerTypeCamera];
    } else if (button.tag == 1003) {
        [self getMediaFromSource:PCSImagePickerTypeVideo];
    } else {
        [self uploadTest];
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return UPLOAD_TABLEVIEW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitleArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString    *title = nil;
    NSString    *uploading = [NSString stringWithFormat:@"%d",PCSFileUploadStatusUploading];
    NSString    *uploadSuccess = [NSString stringWithFormat:@"%d",PCSFileUploadStatusSuccess];
    NSString    *typeString = [self.sectionTitleArray objectAtIndex:section];
    if ([typeString isEqualToString:uploading]) {
        NSArray *uploadingArray = [self.uploadFileDictionary objectForKey:uploading];
        if (uploadingArray.count > 0) {
            title = [NSString stringWithFormat:@"上传中（%d）",uploadingArray.count];
        } else {
            title = @"上传中";
        }
    } else if ([typeString isEqualToString:uploadSuccess]) {
        NSArray *uploadSucessArray = [self.uploadFileDictionary objectForKey:uploadSuccess];
        if (uploadSucessArray.count > 0) {
            title = [NSString stringWithFormat:@"上传成功（%d）",uploadSucessArray.count];
        } else {
            title = @"上传成功";
        }
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self.uploadFileDictionary objectForKey:[self.sectionTitleArray
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
        cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = PCS_MAIN_FONT;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(210, UPLOAD_TABLEVIEW_HEIGHT-23.5f, 90, 20)];
        sizeLable.backgroundColor = [UIColor clearColor];
        sizeLable.textColor = [UIColor grayColor];
        sizeLable.tag = TAG_UPLOAD_FILE_SIZE_LABLE;
        sizeLable.font = [UIFont systemFontOfSize:15.0f];
        [cell.contentView addSubview:sizeLable];
        PCS_FUNC_SAFELY_RELEASE(sizeLable);
        
        UIProgressView  *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 33, 180, 10)];
        progress.backgroundColor = [UIColor clearColor];
        progress.tag = TAG_UPLOAD_PROGRESSVIEW;
        [cell.contentView addSubview:progress];
        PCS_FUNC_SAFELY_RELEASE(progress);
    }
    
    NSArray *sectionArray = [self.uploadFileDictionary objectForKey:[self.sectionTitleArray
                                                                     objectAtIndex:indexPath.section]];
    PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
    cell.textLabel.text = fileItem.name;
    
    UIProgressView  *progress = (UIProgressView *)[cell.contentView viewWithTag:TAG_UPLOAD_PROGRESSVIEW];
    progress.hidden = YES;
    
    UILabel *sizeLable = (UILabel *)[cell.contentView viewWithTag:TAG_UPLOAD_FILE_SIZE_LABLE];
    sizeLable.hidden = YES;
    
    if (fileItem.property == PCSFileUploadStatusSuccess) {
        sizeLable.hidden = NO;
        float   fileSize = (float)fileItem.size/1024;
        if (fileSize < 1024) {
            sizeLable.text = [NSString stringWithFormat:@"%.2fKB",fileSize];
        } else {
            sizeLable.text = [NSString stringWithFormat:@"%.2fMB",fileSize/1024];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm";
        NSDate  *date = [NSDate dateWithTimeIntervalSince1970:fileItem.mtime];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
        PCS_FUNC_SAFELY_RELEASE(dateFormatter);
    } else if (fileItem.property == PCSFileUploadStatusFailed) {
        cell.detailTextLabel.text = @"上传失败，点击重新上传";
    } else if (fileItem.property == PCSFileUploadStatusWaiting) {
        cell.detailTextLabel.text = @"等待上传...";
    } else if (fileItem.property == PCSFileUploadStatusUploading) {
        progress.hidden = NO;
        cell.detailTextLabel.text = @" ";
        self.currentUploadFileIndexPath = indexPath;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArray = [self.uploadFileDictionary objectForKey:[self.sectionTitleArray
                                                                     objectAtIndex:indexPath.section]];
    PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
    if (fileItem.property == PCSFileUploadStatusSuccess) {
        //上传成功的文件点击进入文件预览
        //从cache中获取文件数据失败时，可以从服务端直接下载
        switch (fileItem.format) {
            case PCSFileFormatJpg:
                [self showPhotoPreviewController:sectionArray
                               currentServerPath:fileItem.serverPath];
                break;
            case PCSFileFormatVideo:
                [self showVideoPlayerController:fileItem];
                break;
            default:
                break;
        }
    } else if (fileItem.property == PCSFileUploadStatusFailed) {
        //上传失败的文件，单击后重新上传
        PCSLog(@"reupload file:%@",fileItem);
        [self reuploadFileToServer:fileItem];
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
                photo.folderType = PCSFolderTypeUpload;
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

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *sectionArray = [self.uploadFileDictionary objectForKey:[self.sectionTitleArray
                                                                         objectAtIndex:indexPath.section]];
        PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
        //删除本地uploadCache文件夹中的缓存
        [[PCSDBOperater shareInstance] deleteFileFromUploadCache:fileItem.serverPath];
        //从uploadfilelist表删除记录
        BOOL    result = NO;
        result = [[PCSDBOperater shareInstance] deleteFromUploadFileList:fileItem.fid];         
        if (result) {
            if ([self.currentUploadFileIndexPath isEqual:indexPath]) {
                //当前是上传中的文件，且如果有处于等待上传状态的，则继续上传
                [self uploadNextWaitingFileToServer];
            }
            [self reloadTableDataSource];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    NSString    *fileName =[NSString stringWithFormat:@"Photo_%@.jpg",[dateFormat stringFromDate:[NSDate date]]];
    NSString *target = [[NSString alloc] initWithFormat:@"%@test/%@",PCS_STRING_DEFAULT_PATH,fileName];
    NSData  *data = UIImagePNGRepresentation(image);
//    [self uploadNewFileToServer:fileName path:target];
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes:(long)total
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
        UITableViewCell *cell = [self.mTableView cellForRowAtIndexPath:self.currentUploadFileIndexPath];
        UIProgressView  *progress = (UIProgressView *)[cell.contentView viewWithTag:TAG_UPLOAD_PROGRESSVIEW];
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
