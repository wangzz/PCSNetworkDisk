//
//  PCSPreviewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-26.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSPreviewController.h"

@interface PCSPreviewController ()
@property(nonatomic,retain) NSURL   *fileUrl;

@end


@implementation PCSPreviewController
@synthesize filePath;
@synthesize folderType;
@synthesize fileUrl;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    if (fileUrl != nil) {
        [fileUrl release];
        fileUrl = nil;
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customNavgationBar];

	// Do any additional setup after loading the view.
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

- (void)customNavgationBar
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"返回"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(closeQuickLookAction:)];
    self.navigationController.navigationItem.leftBarButtonItem = backButton;
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
    
}

- (void)hideFileDownloadingView
{
    
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
                    case PCSFolderTypeTypeOffline:
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
                    [self refreshCurrentPreviewItem];
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
    if (self.fileUrl != nil) {
        return 1;
    } else {
        return 0;
    }
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)index
{
    return self.fileUrl;
}

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
