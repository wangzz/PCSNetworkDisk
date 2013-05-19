//
//  PCSNetDiskViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSNetDiskViewController.h"
#import "PCSFileInfoItem.h"
#import "PCSPreviewController.h"
#import "MDAudioFile.h"
#import "MDAudioPlayerController.h"
#import "PCSVideoPlayerController.h"
#import "AppDelegate.h"


@interface PCSNetDiskViewController ()
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, retain) NSMutableArray    *photos;
@property (nonatomic, retain) UITableView   *mTableView;
@property (nonatomic, retain) NSIndexPath *selectCellIndexPath;

@end

#define PCS_TABLEVIEW_CELL_HEIGHT       55.0f
#define PCS_TAG_FILE_TYPE_IMAGEVIEW     10001
#define PCS_TAG_FILE_NAME_LABLE         10002
#define PCS_TAG_FILE_SIZE_LABLE         10003
#define PCS_TAG_FILE_DETAIL_LABLE       10007
#define PCS_TAG_EXPAND_FAVORIT_BUTTON   10004
#define PCS_TAG_EXPAND_MOVE_BUTTON      10005
#define PCS_TAG_EXPAND_DELETE_BUTTON    10006
#define PCS_TAG_ALERTVIEW_TEXTFIELD     10007
#define PCS_TAG_CREAT_FOLDER_ALERTVIEW  10008
#define PCS_TAG_TABLEVIEW_EXPAND_BUTTON 10009
#define PCS_TAG_PREVIEW_LABLE           10010
#define PCS_TAG_FAVOURITE_LABLE         10011
#define PCS_TAG_DELETE_LABLE            10012


@implementation PCSNetDiskViewController
@synthesize path;
@synthesize files;
@synthesize photos = _photos;
@synthesize mTableView;
@synthesize selectCellIndexPath;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"我的云盘";
        [self registerNetDiskLocalNotification];
    }
    
    return self;
}

- (void)registerNetDiskLocalNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFileInfoIncrement)
                                                 name:PCS_NOTIFICATION_INCREMENT_UPDATE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableViewDataSource)
                                                 name:PCS_NOTIFICATION_RELOAD_NETDISK_DATA
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(alterViewFrameWithoutADBanner)
                                                 name:PCS_NOTIFICATION_SHOW_WITHOUT_AD_BANNER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(alterViewFrameWithADBanner)
                                                 name:PCS_NOTIFICATION_SHOW_WITH_AD_BANNER
                                               object:nil];
}

- (void)removeNetDiskLocalNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                              name:PCS_NOTIFICATION_INCREMENT_UPDATE
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                              name:PCS_NOTIFICATION_RELOAD_NETDISK_DATA
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCS_NOTIFICATION_SHOW_WITHOUT_AD_BANNER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCS_NOTIFICATION_SHOW_WITH_AD_BANNER
                                                  object:nil];
}

- (void)dealloc
{
    [path release];
    [self removeNetDiskLocalNotification];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    UIImage *image = nil;
    if (iPhone5) {
        image = [UIImage imageNamed:@"background_iphone5.jpg"];
    } else {
        image = [UIImage imageNamed:@"background_iphone.jpg"];
    }
    imageView.image = image;
    [self.view addSubview:imageView];
    PCS_FUNC_SAFELY_RELEASE(imageView);
    
    mTableView = [[UITableView alloc] init];
    if (PCS_APP_DELEGATE.isADBannerShow) {
        mTableView.frame = frameWithADBanner;
    } else {
        mTableView.frame = frameWithoutADBanner;
    }
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.backgroundColor = [UIColor clearColor];
    
    UIButton  *footViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [footViewButton addTarget:self
                       action:@selector(onCreatFolderButtonAction)
             forControlEvents:UIControlEventTouchUpInside];
    [footViewButton setTitle:@"新建文件夹" forState:UIControlStateNormal];
    footViewButton.backgroundColor = [UIColor grayColor];
    mTableView.tableFooterView = footViewButton;
    PCS_FUNC_SAFELY_RELEASE(footViewButton);
    
    [self.view addSubview:mTableView];
    [mTableView release];
    
    self.files = [[PCSDBOperater shareInstance] getSubFolderFileListFromDB:self.path];
    
//    [self loadFileListFromServer];
//    [self creatNavigationBar];
    
}

- (void)alterViewFrameWithADBanner
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75f];
    self.mTableView.frame = frameWithADBanner;
    [UIView commitAnimations];
}

- (void)alterViewFrameWithoutADBanner
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75f];
    self.mTableView.frame = frameWithoutADBanner;
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateFileInfoIncrement];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    PCSLog(@"memory warning!");
}

- (void)reloadTableViewDataSource
{
    PCSLog(@"table view data source reload success.");
    self.files = [[PCSDBOperater shareInstance] getSubFolderFileListFromDB:self.path];
    self.selectCellIndexPath = nil;
    [self.mTableView reloadData];
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

#pragma mark - 增量更新界面数据
- (void)updateFileInfoIncrement
{
    dispatch_queue_t queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        NSString    *cursor = nil;
        cursor = [[NSUserDefaults standardUserDefaults] stringForKey:PCS_STRING_CURSOR];
        BOOL    needReload = NO;
        needReload = [self getIncrementUpdateFromServer:cursor];
        if (needReload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新界面数据
                [self reloadTableViewDataSource];
            });
        }
    });
}

/*!
 @method
 @abstract 从服务端获取文件增量更新数据
 @param 上次从服务端获取的更新标识
 @return 是否获取到了新的数据，用于确定是否需要更新界面
 */
-(BOOL)getIncrementUpdateFromServer:(NSString *)cursor
{
    PCSDiffResponse *response = [PCS_APP_DELEGATE.pcsClient diff:cursor];
    if(response){
        PCSSimplefiedResponse   *status = response.status;
        if (status.errorCode != 0) {
            PCSLog(@"get diff err,%@",status.message);
            return NO;
        }
        PCSLog(@"upload new file count:%d.",response.entries.count);
        
        for(int i = 0; i < [response.entries count]; ++i){
            PCSDifferEntryInfo *info = [response.entries objectAtIndex:i];
            PCSCommonFileInfo   *tmp = info.commonFileInfo;
            NSArray *array = [tmp.path componentsSeparatedByString:@"/"];
            NSMutableString    *parentPathString = [NSMutableString string];;
            for (NSInteger i = 0;i < array.count;i++) {
                NSString    *string = [array objectAtIndex:i];
                if (i < (array.count - 1)) {
                    [parentPathString appendFormat:@"%@/",string];
                }
            }
            
            if (array != nil) {
                NSString    *fileName = [array objectAtIndex:(array.count - 1)];
                PCSFileInfoItem *item = [[PCSFileInfoItem alloc] init];
                item.name = fileName;
                item.size = tmp.size;
                item.hasSubFolder = tmp.hasSubFolder;
                item.serverPath = tmp.path;
                item.ctime = tmp.cTime;
                item.mtime = tmp.mTime;
                item.parentPath = parentPathString;
                if (tmp.isDir) {
                    item.format = PCSFileFormatFolder;
                } else {
                    item.format = [[PCSDBOperater shareInstance] getFileTypeWith:fileName];
                }
                
                if (info.isDeleted) {
                    item.property = PCSFilePropertyDelete;
                    //被删除的文件，从本地彻底清空数据入库
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [[PCSDBOperater shareInstance] deleteAllFileInfoFromLocal:item];
                        //通知离线列表界面数据更新
                        [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_RELOAD_OFFLINE_DATA
                                                                            object:nil];
                    });
                } else {
                    item.property = PCSFilePropertyDownLoad;
                    //新下载的文件数据入库
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [[PCSDBOperater shareInstance] saveFileInfoItemToDB:item];
                    });
                }
                
                
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:response.cursor
                                                 forKey:PCS_STRING_CURSOR];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            //如果有未执行的延迟执行操作，则将其取消掉，防止增量更新操作被恶性循环的调用导致队列阻塞，及流量耗损
            [PCSNetDiskViewController cancelPreviousPerformRequestsWithTarget:self
                                                                     selector:@selector(updateFileInfoIncrement)
                                                                       object:nil];
            //重新发起请求的操作要放在主线程中，因为子线程的runloop并未启动，定时器是不会起作用的
            if (response.hasMore) {
                //服务端的数据未下载完全，5秒后再次发起请求
                [self performSelector:@selector(updateFileInfoIncrement)
                           withObject:nil
                           afterDelay:5.0f];
            } else {
                //数据已经更新完毕，10分钟后再次发起请求
                [self performSelector:@selector(updateFileInfoIncrement)
                           withObject:nil
                           afterDelay:10*60.0f];
            }
        });
        if (response.entries.count > 0) {
            return YES;
        }
    }
    return NO;
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
        case PCSFileFormatExcel:
            image = [UIImage imageNamed:@"netdisk_type_excel"];
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
        case PCSFileFormatPpt:
            image = [UIImage imageNamed:@"netdisk_type_ppt"];
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
                    item.format = [[PCSDBOperater shareInstance] getFileTypeWith:fileName];
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

- (void)creatFolderFromServer:(NSString  *)filePath
{
    dispatch_queue_t queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        NSString *folderPath = [[NSString alloc] initWithFormat:@"%@%@" , self.path, filePath];
        PCSFileInfoResponse *response = [PCS_APP_DELEGATE.pcsClient makeDir:folderPath];
        if(response){
            dispatch_sync(dispatch_get_main_queue(), ^{
                PCSSimplefiedResponse *status = response.status;
                if (status.errorCode == 0) {
                    PCSLog(@"creat folder %@ success.",filePath);
                    //增量更新界面数据,服务端返回的结果一般都会有延时
                    [self updateFileInfoIncrement];
                } else {
                    PCSLog(@"creat folder %@ err.%@",filePath,status.message);
                }
            });
            
            
        }
        PCS_FUNC_SAFELY_RELEASE(folderPath);
    });
}

#pragma mark - 按钮响应事件
- (void)onExpandButtonAction:(id)sender event:(id)event
{
    UIButton    *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.mTableView];
    NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint: currentTouchPosition];
    NSArray *indexArray = nil;
    if([self.selectCellIndexPath isEqual:indexPath])
    {
        //两次点的是相同的Cell，因此只需要重新加载当前Cell
        indexArray = [[NSArray alloc] initWithObjects:indexPath,nil];
        self.selectCellIndexPath =nil;
    } else {
        //两次点的是不同的Cell，因此需要重新加载上次，和本次点击的两个Cell
        indexArray = [[NSArray alloc] initWithObjects:indexPath,self.selectCellIndexPath,nil];
        self.selectCellIndexPath = indexPath;
    }
    //实现动态加载
    [self.mTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
    PCS_FUNC_SAFELY_RELEASE(indexArray);
    [mTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)onCreatFolderButtonAction
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入文件夹名：               "
                                                    message:@" "
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"新建", nil];
    [alert setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];
    alert.tag = PCS_TAG_CREAT_FOLDER_ALERTVIEW;
    
    UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(30, alert.center.y+45, 225, 30)];
    inputField.delegate = self;
    inputField.backgroundColor = [UIColor clearColor];
    inputField.tag = PCS_TAG_ALERTVIEW_TEXTFIELD;
    inputField.borderStyle = UITextBorderStyleRoundedRect;
    inputField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    inputField.returnKeyType = UIReturnKeyDone;
    [alert addSubview:inputField];
    [alert show];
    PCS_FUNC_SAFELY_RELEASE(alert);
    PCS_FUNC_SAFELY_RELEASE(inputField);
}

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
    PCSFileInfoItem *item = [self.files objectAtIndex:self.selectCellIndexPath.row];
    if (item.property == PCSFilePropertyOffLineSuccess ||
        item.property == PCSFilePropertyOffLineWaiting ||
        item.property == PCSFilePropertyOffLining) {
        //将文件的状态由离线状态置为正常的下载状态
        result = [[PCSDBOperater shareInstance] updateFile:item.fid property:PCSFilePropertyDownLoad];
        if (result) {
            item.property = PCSFilePropertyDownLoad;
        }
        
    } else if (item.property == PCSFilePropertyDownLoad ||
               item.property == PCSFilePropertyOffLineFailed) {
        PCSFileProperty nextProperty = PCSFilePropertyNull;
        BOOL    hasOffLiningFile = [[PCSDBOperater shareInstance] hasOffliningFile];
        if (hasOffLiningFile) {
            //有正在等待离线下载的文件，则将该文件状态置为等待下载
            nextProperty = PCSFilePropertyOffLineWaiting;
        } else {
            //没有等待离线下载的文件，则将文件状态置位下载中，并随后开始下载
            nextProperty = PCSFilePropertyOffLining;
        }
        result = [[PCSDBOperater shareInstance] updateFile:item.fid property:nextProperty];
        if (result) {
            item.property = nextProperty;
        }
    }

    if (result) {
        //通知离线列表界面数据更新
        [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_UPDATE_OFFLINE_FILE
                                                            object:item];
        //更新当前界面数据
        [self.mTableView reloadData];
    }
}

- (void)onPreviewButtonAction
{
    PCSFileInfoItem *item = [self.files objectAtIndex:self.selectCellIndexPath.row];
    if (item.format == PCSFileFormatFolder) {
        PCSNetDiskViewController *detailViewController = [[PCSNetDiskViewController alloc] init];
        detailViewController.path = [item.serverPath stringByAppendingString:@"/"];
        [[self navigationController] pushViewController:detailViewController animated:YES];
        [detailViewController release];
    } else {
        //进入文件预览界面
        switch (item.format) {
            case PCSFileFormatJpg:
                [self showPhotoPreviewController:item.serverPath];
                break;
            case PCSFileFormatAudio:
                [self showAudioPlayerController:item];
                break;
            case PCSFileFormatVideo:
                [self showVideoPlayerController:item];
                break;
            case PCSFileFormatPdf:
            case PCSFileFormatDoc:
            case PCSFileFormatExcel:
            case PCSFileFormatTxt:
            case PCSFileFormatPpt:
            default:
                [self showDocumentPreviewController:item];
                break;
        }
    }
}

- (void)onDeleteButtonAction:(id)sender
{
    UIButton    *button = (UIButton *)sender;
    button.userInteractionEnabled = NO;
    dispatch_queue_t    queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        PCSFileInfoItem *item = [self.files objectAtIndex:self.selectCellIndexPath.row];
        PCSSimplefiedResponse   *response = [PCS_APP_DELEGATE.pcsClient deleteFile:item.serverPath];
        if (response.errorCode == 0) {
            //从服务端删除成功，开始从本地数据库删除，并置位，更新界面数据
            dispatch_sync(dispatch_get_main_queue(), ^{
                BOOL result = NO;
                //删除每条文件记录在本地的全部信息
                result = [[PCSDBOperater shareInstance] deleteAllFileInfoFromLocal:item];
                if (result) {
                    [self reloadTableViewDataSource];
                    //通知离线列表界面数据更新
                    [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_RELOAD_OFFLINE_DATA
                                                                        object:nil];
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

#pragma mark - UIAlertView 委托方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == PCS_TAG_CREAT_FOLDER_ALERTVIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            
        } else {
            UITextField *textField = (UITextField *)[alertView viewWithTag:PCS_TAG_ALERTVIEW_TEXTFIELD];
            if (textField.text == nil || textField.text.length == 0) {
                PCSLog(@"creat folder failed,folder name is nil.");
            } else {
                [self creatFolderFromServer:textField.text];
            }
        }
    }
}

#pragma mark - UITextField 委托方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == PCS_TAG_ALERTVIEW_TEXTFIELD) {
        [textField resignFirstResponder];
        [textField.superview resignFirstResponder];
    }
    return YES;
}

#define TABLEVIEW_NORMAL_CELL   @"NormalCell"
#define TABLEVIEW_EXPAND_CELL   @"ExpandCell"

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([self.selectCellIndexPath isEqual:indexPath]) {
        return (PCS_TABLEVIEW_CELL_HEIGHT + 60.0f);
        
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
    if ([self.selectCellIndexPath isEqual:indexPath]) {
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
        
        UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 2, 170, 30)];
        nameLable.tag = PCS_TAG_FILE_NAME_LABLE;
        nameLable.lineBreakMode = UILineBreakModeMiddleTruncation;
        nameLable.font = PCS_MAIN_FONT;
        nameLable.textColor = PCS_MAIN_TEXT_COLOR;
        nameLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLable];
        PCS_FUNC_SAFELY_RELEASE(nameLable);
        
        UILabel *detailLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 27, 170, 25)];
        detailLable.tag = PCS_TAG_FILE_DETAIL_LABLE;
        detailLable.font = PCS_DETAIL_FONT;
        detailLable.textColor = PCS_DETAIL_TEXT_COLOR;
        detailLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:detailLable];
        PCS_FUNC_SAFELY_RELEASE(detailLable);
        
        UILabel *sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(200, 24, 75, 30)];
        sizeLable.tag = PCS_TAG_FILE_SIZE_LABLE;
        sizeLable.textAlignment = UITextAlignmentRight;
        sizeLable.font = [UIFont systemFontOfSize:14.0f];
        sizeLable.textColor = PCS_DETAIL_TEXT_COLOR;
        sizeLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:sizeLable];
        PCS_FUNC_SAFELY_RELEASE(sizeLable);
        
        UIButton    *expandButton = [[UIButton alloc] initWithFrame:CGRectMake(275, 0, 45, PCS_TABLEVIEW_CELL_HEIGHT)];
        expandButton.tag = PCS_TAG_TABLEVIEW_EXPAND_BUTTON;
        [expandButton setImage:[UIImage imageNamed:@"netdisk_arrow_normal"]
                      forState:UIControlStateNormal];
        [expandButton setImage:[UIImage imageNamed:@"netdisk_arrow_pack_up"]
                      forState:UIControlStateSelected];
        [expandButton addTarget:self
                         action:@selector(onExpandButtonAction:event:)
               forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:expandButton];
        PCS_FUNC_SAFELY_RELEASE(expandButton);
        
        if ([CellIdentifier isEqualToString:TABLEVIEW_EXPAND_CELL]) {
            UIImageView  *mainView = [[UIImageView alloc] initWithFrame:CGRectMake(0, PCS_TABLEVIEW_CELL_HEIGHT-13, 320, 73)];
            mainView.image = [UIImage imageNamed:@"netdisk_expand_cell_bg"];
            [cell.contentView addSubview:mainView];
            PCS_FUNC_SAFELY_RELEASE(mainView);

            UIButton    *favoritButton = [[UIButton alloc] initWithFrame:CGRectMake(15, PCS_TABLEVIEW_CELL_HEIGHT+3, 90, 40)];
            [favoritButton addTarget:self
                              action:@selector(onPreviewButtonAction)
                    forControlEvents:UIControlEventTouchUpInside];
            favoritButton.tag = PCS_TAG_EXPAND_FAVORIT_BUTTON;
            [favoritButton setImageEdgeInsets:UIEdgeInsetsMake(1, 11, 1, 11)];
            [cell.contentView addSubview:favoritButton];
            PCS_FUNC_SAFELY_RELEASE(favoritButton);
            
            UILabel *previewLable = [[UILabel alloc] initWithFrame:CGRectMake(15, PCS_TABLEVIEW_CELL_HEIGHT+40, 90, 20)];
            previewLable.font = [UIFont systemFontOfSize:12.0f];
            previewLable.textColor = [UIColor whiteColor];
            previewLable.backgroundColor = [UIColor clearColor];
            previewLable.tag = PCS_TAG_PREVIEW_LABLE;
            previewLable.textAlignment = UITextAlignmentCenter;
            [cell.contentView addSubview:previewLable];
            PCS_FUNC_SAFELY_RELEASE(previewLable);
            
            UIButton    *moveButton = [[UIButton alloc] initWithFrame:CGRectMake(115, PCS_TABLEVIEW_CELL_HEIGHT+3, 90, 40)];
            [moveButton addTarget:self
                           action:@selector(onFavoritButtonAction)
                 forControlEvents:UIControlEventTouchUpInside];
            moveButton.tag = PCS_TAG_EXPAND_MOVE_BUTTON;
            [moveButton setImageEdgeInsets:UIEdgeInsetsMake(1, 11, 1, 11)];
            [cell.contentView addSubview:moveButton];
            PCS_FUNC_SAFELY_RELEASE(moveButton);
            
            UIImageView *downImage = [[UIImageView alloc] initWithFrame:CGRectMake(170, PCS_TABLEVIEW_CELL_HEIGHT+20, 25, 25)];
            downImage.image = [UIImage imageNamed:@"netdisk_file_down"];
            [cell.contentView addSubview:downImage];
            PCS_FUNC_SAFELY_RELEASE(downImage);
            
            UILabel *favLable = [[UILabel alloc] initWithFrame:CGRectMake(115, PCS_TABLEVIEW_CELL_HEIGHT+40, 90, 20)];
            favLable.font = [UIFont systemFontOfSize:12.0f];
            favLable.backgroundColor = [UIColor clearColor];
            favLable.textColor = [UIColor whiteColor];
            favLable.tag = PCS_TAG_FAVOURITE_LABLE;
            favLable.textAlignment = UITextAlignmentCenter;
            [cell.contentView addSubview:favLable];
            PCS_FUNC_SAFELY_RELEASE(favLable);
            
            UIButton    *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(215, PCS_TABLEVIEW_CELL_HEIGHT+3, 90, 40)];
            [deleteButton addTarget:self
                             action:@selector(onDeleteButtonAction:)
                   forControlEvents:UIControlEventTouchUpInside];
            deleteButton.tag = PCS_TAG_EXPAND_DELETE_BUTTON;
            [deleteButton setImage:[UIImage imageNamed:@"netdisk_expand_deleted"] forState:UIControlStateNormal];
            [deleteButton setImage:[UIImage imageNamed:@"netdisk_expand_deleted"] forState:UIControlStateHighlighted];
            [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(1, 11, 1, 11)];
            [cell.contentView addSubview:deleteButton];
            PCS_FUNC_SAFELY_RELEASE(deleteButton);
            
            UILabel *deleteLable = [[UILabel alloc] initWithFrame:CGRectMake(215, PCS_TABLEVIEW_CELL_HEIGHT+40, 90, 20)];
            deleteLable.font = [UIFont systemFontOfSize:12.0f];
            deleteLable.backgroundColor = [UIColor clearColor];
            deleteLable.textColor = [UIColor whiteColor];
            deleteLable.text = @"删除";
            deleteLable.textAlignment = UITextAlignmentCenter;
            [cell.contentView addSubview:deleteLable];
            PCS_FUNC_SAFELY_RELEASE(deleteLable);
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
    } else {
        float   fileSize = (float)item.size/1024;
        if (fileSize < 1024) {
            sizeLable.text = [NSString stringWithFormat:@"%.2fKB",fileSize];
        } else {
            sizeLable.text = [NSString stringWithFormat:@"%.2fMB",fileSize/1024];
        }
    }
    
    if ([CellIdentifier isEqualToString:TABLEVIEW_EXPAND_CELL]) {
        UIButton    *favoritButton = (UIButton *)[cell.contentView viewWithTag:PCS_TAG_EXPAND_MOVE_BUTTON];
        UILabel *favLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_FAVOURITE_LABLE];
        if (item.property == PCSFilePropertyDownLoad ||
            item.property == PCSFilePropertyOffLineFailed) {
            favLable.text = @"收藏";
            [favoritButton setImage:[UIImage imageNamed:@"netdisk_expand_favorited"] forState:UIControlStateNormal];
            [favoritButton setImage:[UIImage imageNamed:@"netdisk_expand_favorited"] forState:UIControlStateHighlighted];
        } else if (item.property == PCSFilePropertyOffLineSuccess ||
                   item.property == PCSFilePropertyOffLineWaiting ||
                   item.property == PCSFilePropertyOffLining) {
            favLable.text = @"取消收藏";
            [favoritButton setImage:[UIImage imageNamed:@"netdisk_expand_favorited"] forState:UIControlStateNormal];
            [favoritButton setImage:[UIImage imageNamed:@"netdisk_expand_favorited"] forState:UIControlStateHighlighted];
        }

        UIButton    *checkButton = (UIButton *)[cell.contentView viewWithTag:PCS_TAG_EXPAND_FAVORIT_BUTTON];
        UILabel *checkLable = (UILabel *)[cell.contentView viewWithTag:PCS_TAG_PREVIEW_LABLE];
        if (item.format == PCSFileFormatFolder) {
            [checkButton setImage:[UIImage imageNamed:@"netdisk_expand_move"] forState:UIControlStateNormal];
            [checkButton setImage:[UIImage imageNamed:@"netdisk_expand_moved"] forState:UIControlStateHighlighted];
            checkLable.text = @"打开";
        } else {
            [checkButton setImage:[UIImage imageNamed:@"netdisk_expand_move"] forState:UIControlStateNormal];
            [checkButton setImage:[UIImage imageNamed:@"netdisk_expand_moved"] forState:UIControlStateHighlighted];
            checkLable.text = @"预览";
        }
    }
    
    //展开按钮的处理逻辑
    UIButton    *expandButton = (UIButton *)[cell.contentView viewWithTag:PCS_TAG_TABLEVIEW_EXPAND_BUTTON];
    if ([self.selectCellIndexPath isEqual:indexPath]) {
        expandButton.selected = YES;
    } else {
        expandButton.selected = NO;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectCellIndexPath]) {
        return;
    }
    
    PCSFileInfoItem *item = [self.files objectAtIndex:[indexPath row]];
    
    if (item.format == PCSFileFormatFolder) {
        PCSNetDiskViewController *detailViewController = [[PCSNetDiskViewController alloc] init];
        detailViewController.path = [item.serverPath stringByAppendingString:@"/"];
        [[self navigationController] pushViewController:detailViewController animated:YES];
        [detailViewController release];
    } else {
        //进入文件预览界面
        switch (item.format) {
            case PCSFileFormatJpg:
                [self showPhotoPreviewController:item.serverPath];
                break;
            case PCSFileFormatAudio:
                [self showAudioPlayerController:item];
                break;
            case PCSFileFormatVideo:
                [self showVideoPlayerController:item];
                break;
            case PCSFileFormatPdf:
            case PCSFileFormatDoc:
            case PCSFileFormatExcel:
            case PCSFileFormatTxt:
            case PCSFileFormatPpt:
            default:
                [self showDocumentPreviewController:item];
                break;
        }
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
                                                                                    folderType:PCSFolderTypeNetDisk];
    audioPlayer.title = item.name;
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:audioPlayer];
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
    previewController.folderType = PCSFolderTypeNetDisk;
    previewController.title = item.name;

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:previewController];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nc.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentModalViewController:nc animated:YES];
    PCS_FUNC_SAFELY_RELEASE(nc);
    PCS_FUNC_SAFELY_RELEASE(previewController);
}

- (void)showPhotoPreviewController:(NSString *)currentServerPath
{
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    NSInteger   pageIndex = 0;
    NSInteger   jpgCount = 0;
    for (NSInteger count = 0; count < self.files.count; count++) {
        PCSFileInfoItem *item = [self.files objectAtIndex:count];
        if (item.format == PCSFileFormatJpg) {
            photo = [MWPhoto photoWithServerPath:item.serverPath];
            if (photo != nil) {
                photo.folderType = PCSFolderTypeNetDisk;
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

- (void)downloadFileFromServer:(NSString *)serverPath Block:(void (^)())action
{
    dispatch_queue_t queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        NSData *data = nil;
        PCSSimplefiedResponse *response = [PCS_APP_DELEGATE.pcsClient downloadFile:serverPath:&data:self];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (response.errorCode == 0) {
                PCSLog(@"download file :%@ from server success.",serverPath);
                [[PCSDBOperater shareInstance] saveFileToNetCache:data name:serverPath];
            } else {
                PCSLog(@"download file :%@ from server failed.",serverPath);
            }
            
          action();
            
        });
    });
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

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes :(long)total
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
        
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
