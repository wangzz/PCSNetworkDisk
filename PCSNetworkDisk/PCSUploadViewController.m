//
//  PCSUploadViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSUploadViewController.h"

@interface PCSUploadViewController ()

@property (nonatomic,retain) IBOutlet   UITableView *mTableView;
@property (nonatomic,retain) NSDictionary   *uploadFileDictionary;
@property (nonatomic,retain) NSArray   *sectionTitleArray;

@end

@implementation PCSUploadViewController
@synthesize mTableView;
@synthesize uploadFileDictionary;
@synthesize sectionTitleArray;


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
    
    [self reloadTableDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 构建界面
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = sourceType;
        [self presentModalViewController:picker animated:YES];
        PCS_FUNC_SAFELY_RELEASE(picker);
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您的设备不支持访问多媒体文件目录"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - 数据处理
- (void)uploadTest
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:@"/Cocoa.pdf"];
    NSData  *data = [NSData dataWithContentsOfFile:filePath];
    NSString    *fileName = @"面朝大海，春暖花开，我有一所房子909.pdf";
    NSString *target = [[NSString alloc] initWithFormat:@"%@%@",PCS_STRING_DEFAULT_PATH,fileName];
    
    [self uploadNewFileToServer:data name:fileName path:target];
}

//新选取的文件信息入库，文件缓存等操作，并根据操作结果判断是否需要立马上传服务器
- (void)uploadNewFileToServer:(NSData *)data name:(NSString *)fileName path:(NSString *)filePath
{
    //先将文件保存到缓存中
    [[PCSDBOperater shareInstance] saveFile:data name:filePath];
    
    PCSFileInfoItem *fileItem = [[PCSFileInfoItem alloc] init];
    fileItem.name = fileName;
    fileItem.serverPath = filePath;
    fileItem.size = data.length;
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
            [self uploadFile:data name:filePath];
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
        result = [[PCSDBOperater shareInstance] updateUploadFile:item.serverPath
                                                          status:PCSFileUploadStatusUploading];
        if (result) {
            //更新文件状态成功后，更新界面显示，并开始上传操作
            [self reloadTableDataSource];
            NSData  *data = [[PCSDBOperater shareInstance] getFileWith:item.serverPath];
            [self uploadFile:data name:item.serverPath];
        }
    }
}

//将上传失败的文件重新上传
- (void)reuploadFileToServer:(PCSFileInfoItem *)item
{
    NSData  *data = [[PCSDBOperater shareInstance] getFileWith:item.serverPath];
    
    BOOL    result = NO;
    //更新文件状态为上传中
    result = [[PCSDBOperater shareInstance] updateUploadFile:item.serverPath
                                                      status:PCSFileUploadStatusUploading];
    if (result) {
        [self reloadTableDataSource];
        [self uploadFile:data name:item.serverPath];
    }
}

//进行实际的服务器上传操作
- (void)uploadFile:(NSData *)data name:(NSString *)name
{
    if (nil == data || nil == name) {
        PCSLog(@"upload err,the data or name is nil.");
        return;
    }
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL    result = NO;
            //更新文件状态
            result = [[PCSDBOperater shareInstance] updateUploadFile:name
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
- (IBAction)onButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1001) {
        [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (button.tag == 1002) {
        [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
    } else if (button.tag == 1003) {
        [self uploadTest];
    }
}

#pragma mark - Table view data source

#define UPLOAD_TABLEVIEW_HEIGHT         50.0f
#define TAG_UPLOAD_FILE_SIZE_LABLE      20001
#define TAG_UPLOAD_PROGRESSVIEW         20002

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
    
    if (fileItem.property == PCSFileUploadStatusSuccess) {
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
        currentUploadFileIndexPath = indexPath;
    }
    
    UILabel *sizeLable = (UILabel *)[cell.contentView viewWithTag:TAG_UPLOAD_FILE_SIZE_LABLE];
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
    NSArray *sectionArray = [self.uploadFileDictionary objectForKey:[self.sectionTitleArray
                                                                     objectAtIndex:indexPath.section]];
    PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
    if (fileItem.property == PCSFileUploadStatusSuccess) {
        //上传成功的文件点击进入文件预览
        //从cache中获取文件数据失败时，可以从服务端直接下载
        
        PCSLog(@"preview file:%@",fileItem);
    } else if (fileItem.property == PCSFileUploadStatusFailed) {
        //上传失败的文件，单击后重新上传
        PCSLog(@"reupload file:%@",fileItem);
        [self reuploadFileToServer:fileItem];
    }
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
        BOOL    result = NO;
        result = [[PCSDBOperater shareInstance] deleteFromUploadFileList:fileItem.fid];
        if (result) {
            [self reloadTableDataSource];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes:(long)total
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
        UITableViewCell *cell = [self.mTableView cellForRowAtIndexPath:currentUploadFileIndexPath];
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
