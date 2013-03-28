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

#define PCS_TABLEVIEW_CELL_HEIGHT       50.0f
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
                                                 selector:@selector(updateFileInfoIncrement)
                                                     name:PCS_NOTIFICATION_INCREMENT_UPDATE
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
                                              forKeyPath:PCS_NOTIFICATION_INCREMENT_UPDATE];
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
    
    [self creatNavigationBar];
//    [self addADBanner];
//    [self loadFileListFromServer];
    
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
    selectCellIndexPath = nil;
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
            dispatch_async(dispatch_get_main_queue(), ^{
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
    if([selectCellIndexPath isEqual:indexPath])
    {
        //两次点的是相同的Cell，因此只需要重新加载当前Cell
        indexArray = [[NSArray alloc] initWithObjects:indexPath,nil];
        selectCellIndexPath =nil;
    } else {
        //两次点的是不同的Cell，因此需要重新加载上次，和本次点击的两个Cell
        indexArray = [[NSArray alloc] initWithObjects:indexPath,selectCellIndexPath,nil];
        selectCellIndexPath = indexPath;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_UPDATE_OFFLINE_FILE
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
        nameLable.lineBreakMode = UILineBreakModeMiddleTruncation;
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
        
        UIButton    *expandButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 0, 40, PCS_TABLEVIEW_CELL_HEIGHT)];
        expandButton.tag = PCS_TAG_TABLEVIEW_EXPAND_BUTTON;
        expandButton.backgroundColor = [UIColor redColor];
        [expandButton setTitle:@"展开" forState:UIControlStateNormal];
        [expandButton setTitle:@"收缩" forState:UIControlStateSelected];
        [expandButton addTarget:self
                         action:@selector(onExpandButtonAction:event:)
               forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:expandButton];
        PCS_FUNC_SAFELY_RELEASE(expandButton);
        
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
    } else {
        float   fileSize = (float)item.size/1024;
        if (fileSize < 1024) {
            sizeLable.text = [NSString stringWithFormat:@"%.2fKB",fileSize];
        } else {
            sizeLable.text = [NSString stringWithFormat:@"%.2fMB",fileSize/1024];
        }
    }
    
    if ([CellIdentifier isEqualToString:TABLEVIEW_EXPAND_CELL]) {
        UIButton    *favoritButton = (UIButton *)[cell.contentView viewWithTag:PCS_TAG_EXPAND_FAVORIT_BUTTON];
        if (item.property == PCSFilePropertyDownLoad) {
            [favoritButton setTitle:@"收藏" forState:UIControlStateNormal];
        } else if (item.property == PCSFilePropertyOffLine) {
            [favoritButton setTitle:@"取消收藏" forState:UIControlStateNormal];
        }  
    }
    
    //展开按钮的处理逻辑
    UIButton    *expandButton = (UIButton *)[cell.contentView viewWithTag:PCS_TAG_TABLEVIEW_EXPAND_BUTTON];
    if ([selectCellIndexPath isEqual:indexPath]) {
        expandButton.selected = YES;
    } else {
        expandButton.selected = NO;
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
        //进入文件预览界面
        
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
