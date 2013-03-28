//
//  PCSOfflineViewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSOfflineViewController.h"

@interface PCSOfflineViewController ()
@property(nonatomic,retain) IBOutlet    UITableView *mTableView;
@property(nonatomic,retain) NSDictionary  *offlineFileDictionary;
@property(nonatomic,retain) NSArray *sectionTitleArray;
@property(nonatomic,retain) NSIndexPath *currentOfflineFileIndexPath;

@end

@implementation PCSOfflineViewController
@synthesize mTableView;
@synthesize offlineFileDictionary;
@synthesize sectionTitleArray;
@synthesize currentOfflineFileIndexPath;

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
                                              forKeyPath:PCS_NOTIFICATION_RELOAD_OFFLINE_DATA];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                              forKeyPath:PCS_NOTIFICATION_UPDATE_OFFLINE_FILE];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
                [[PCSDBOperater shareInstance] saveFileToOfflineCache:data name:item.serverPath];
                fileProperty = PCSFilePropertyOffLineSuccess;
                PCSLog(@"download file :%@ from server success.",item.serverPath);
            } else {
                fileProperty = PCSFilePropertyOffLineFailed;
                PCSLog(@"download file :%@ from server failed.",item.serverPath);
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
                [[PCSDBOperater shareInstance] updateFile:item.fid property:PCSFilePropertyOffLining];
            }
            //然后开始下载
            [self downloadFileFromServer:nextOfflineFileItem];
            [self reloadOfflineTableViewData];
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

#define OFFLINE_TABLEVIEW_HEIGHT         50.0f
#define TAG_OFFLINE_FILE_SIZE_LABLE      20001
#define TAG_OFFLINE_PROGRESSVIEW         20002

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return OFFLINE_TABLEVIEW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitleArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
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
    return title;
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
        cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(210, OFFLINE_TABLEVIEW_HEIGHT-23.5f, 90, 20)];
        sizeLable.backgroundColor = [UIColor clearColor];
        sizeLable.textColor = [UIColor grayColor];
        sizeLable.tag = TAG_OFFLINE_FILE_SIZE_LABLE;
        sizeLable.font = [UIFont systemFontOfSize:15.0f];
        [cell.contentView addSubview:sizeLable];
        PCS_FUNC_SAFELY_RELEASE(sizeLable);
        
        UIProgressView  *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 33, 180, 10)];
        progress.backgroundColor = [UIColor clearColor];
        progress.tag = TAG_OFFLINE_PROGRESSVIEW;
        [cell.contentView addSubview:progress];
        PCS_FUNC_SAFELY_RELEASE(progress);
    }
    
    NSArray *sectionArray = [self.offlineFileDictionary objectForKey:[self.sectionTitleArray
                                                                     objectAtIndex:indexPath.section]];
    PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
    cell.textLabel.text = fileItem.name;
    
    UIProgressView  *progress = (UIProgressView *)[cell.contentView viewWithTag:TAG_OFFLINE_PROGRESSVIEW];
    progress.hidden = YES;
    
    if (fileItem.property == PCSFilePropertyOffLineSuccess) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm";
        NSDate  *date = [NSDate dateWithTimeIntervalSince1970:fileItem.mtime];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
        PCS_FUNC_SAFELY_RELEASE(dateFormatter);
    } else if (fileItem.property == PCSFilePropertyOffLineFailed) {
        cell.detailTextLabel.text = @"下载失败，点击重新上传";
    } else if (fileItem.property == PCSFilePropertyOffLineWaiting) {
        cell.detailTextLabel.text = @"等待下载...";
    } else if (fileItem.property == PCSFilePropertyOffLining) {
        progress.hidden = NO;
        cell.detailTextLabel.text = @" ";
        currentOfflineFileIndexPath = indexPath;
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
        
        PCSLog(@"preview file:%@",fileItem);
    } else if (fileItem.property == PCSFilePropertyOffLineFailed) {
        //上传失败的文件，单击后重新上传
        PCSLog(@"redownload file:%@",fileItem);
        [self downloadFileFromServer:fileItem];
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
-(void)onProgress:(long)bytes:(long)total
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
        UITableViewCell *cell = [self.mTableView cellForRowAtIndexPath:currentOfflineFileIndexPath];
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
