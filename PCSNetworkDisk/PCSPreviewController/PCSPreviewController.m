//
//  PCSPreviewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-26.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSPreviewController.h"
#import "PCSPreviewItem.h"

@interface PCSPreviewController ()
@property(nonatomic,retain) NSURL   *fileUrl;
@property(nonatomic,retain) UIProgressView  *progress;

@end


@implementation PCSPreviewController
@synthesize filePath;
@synthesize folderType;
@synthesize fileUrl;
@synthesize progress;
@synthesize title;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(customNavgationBar)
                                                     name:PCS_NOTIFICATION_SHOW_PREVIEW_BUTTON
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCS_NOTIFICATION_SHOW_PREVIEW_BUTTON
                                                  object:nil];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    
    NSString    *absolutePath = [[PCSDBOperater shareInstance] absolutePathBy:self.filePath
                                                                   folderType:self.folderType];
    BOOL    fileExit = NO;
    fileExit = [[NSFileManager defaultManager] fileExistsAtPath:absolutePath];
    if (fileExit) {
        self.currentPreviewItemIndex = 0;
        fileUrl = [NSURL fileURLWithPath:absolutePath];
    } else {
        //文件不存在，则从服务端下载文件
        //同时显示正在下载文件的界面
        [self downloadFileFromServer:self.filePath];
        [self showFileDownloadingView];
    }
}

- (void)setNavBarAppearance:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)showToolBar
{
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem* _shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(onShareButtonAction)];
    _shareButton.title = @"分享";
    UIBarButtonItem* _saveToAlbumButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(onSaveButtonAction)];
    _saveToAlbumButton.title = @"保存";
    UIBarButtonItem* _deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(onDeleteButtonAction)];
    _deleteButton.title = @"删除";
    UIBarButtonItem* _openButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(onOpenButtonAction)];
    _openButton.title = @"打开";
    
    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:flexSpace];
    [items addObject:_openButton];
    [items addObject:flexSpace];
    [items addObject:_shareButton];
    [items addObject:flexSpace];
    [items addObject:_saveToAlbumButton];
    [items addObject:flexSpace];
    [items addObject:_deleteButton];
    self.toolbarItems = items;
    [items release];
    
}

- (void)onShareButtonAction
{
    
}

- (void)onSaveButtonAction
{
    
}

- (void)onDeleteButtonAction
{
    
}

- (void)onOpenButtonAction
{
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavBarAppearance:YES];
    [self customNavgationBar];
}

- (void)customNavgationBar
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(closeQuickLookAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
}

- (void)closeQuickLookAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showFileDownloadingView
{
    progress = [[UIProgressView alloc] initWithFrame:CGRectMake(50, 250, 220, 50)];
    if ([progress respondsToSelector:@selector(progressImage)]) {
        //由于IOS5以下系统不支持自定义背景图片和进度图片，这里做了匹配处理
        progress.progressImage = [[UIImage imageNamed:@"fax_list_progress_image"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
        progress.trackImage = [[UIImage imageNamed:@"fax_list_progress_track_image"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    }
    [self.view addSubview:progress];
    PCS_FUNC_SAFELY_RELEASE(progress);
}

- (void)hideFileDownloadingView
{
    if (self.progress) {
        [self.progress removeFromSuperview];
    }
}

- (void)showFileDownloadFailedView
{
    
}

- (void)downloadFileFromServer:(NSString *)serverPath
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *data = nil;
        PCSSimplefiedResponse *response = [PCS_APP_DELEGATE.pcsClient downloadFile:serverPath:&data:self];
        dispatch_sync(dispatch_get_main_queue(), ^{
            //让文件下载中界面消失
            [self hideFileDownloadingView];
            if (response.errorCode == 0) {
                PCSLog(@"download file :%@ from server success.",serverPath);
                BOOL result = NO;
                switch (self.folderType) {
                    case PCSFolderTypeNetDisk:
                        result = [[PCSDBOperater shareInstance] saveFileToNetCache:data name:serverPath];
                        break;
                    case PCSFolderTypeUpload:
                        result = [[PCSDBOperater shareInstance] saveFileToUploadCache:data name:serverPath];
                        break;
                    case PCSFolderTypeOffline:
                        result = [[PCSDBOperater shareInstance] saveFileToOfflineCache:data name:serverPath];
                        break;
                    default:
                        break;
                }
                
                NSString    *absolutePath = [[PCSDBOperater shareInstance] absolutePathBy:self.filePath
                                                                               folderType:self.folderType];
                if (result) {
                    fileUrl = [NSURL fileURLWithPath:absolutePath];
                    //文件下载成功，重新加载界面数据
                    self.currentPreviewItemIndex = 0;
                    [self reloadData];
                    [self customNavgationBar];
                }
                
            } else {
                //显示文件下载失败界面
                [self showFileDownloadFailedView];
                PCSLog(@"download file :%@ from server failed.",serverPath);
            }
        });
    });
}

#pragma mark QLPreviewControllerDelegate
- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    if (self.fileUrl == nil) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark QLPreviewControllerDataSource
// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}

// returns the item that the preview controller should preview
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    if (self.fileUrl == nil) {
        return nil;
    } else {
        // Do any additional setup after loading the view.
        PCSPreviewItem  *item = [PCSPreviewItem previewItemWithURL:self.fileUrl title:self.title];
        return item;
    }
}

#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes :(long)total
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
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
