//
//  PCSOfflineViewController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSOfflineViewController.h"

@interface PCSOfflineViewController ()

@end

@implementation PCSOfflineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"离线文件";
        progressView = [[UIProgressView alloc] init];
        [self registerLoaclNotification];
    }
    return self;
}

- (void)dealloc
{
    [self removeLocalNotification];
    [progressView release];
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
    progressView.frame = CGRectMake(50, 200, 220, 10);
    [self.view addSubview:progressView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateOfflineFile:(NSNotification *)notification
{
    PCSFileInfoItem    *item = notification.object;
    if (item.property == PCSFilePropertyDownLoad) {
        //将本地保存的文件从缓存中删除
        [[PCSDBOperater shareInstance] deleteFileFromOfflineCache:item.serverPath];
    } else if (item.property == PCSFilePropertyOffLine) {
        //执行文件下载操作
        dispatch_queue_t queue = PCS_APP_DELEGATE.gcdQueue;
        dispatch_async(queue, ^{
            NSData  *data = [self downLoadFileFromServer:item.serverPath];
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[PCSDBOperater shareInstance] saveFileToOfflineCache:data name:item.serverPath];
                });
            }
        });
    }
    //重新加载界面数据
    [self reloadOfflineTableViewData];
}

- (NSData *)downLoadFileFromServer:(NSString *)path
{
    NSData *data = nil;
    PCSSimplefiedResponse *response = [PCS_APP_DELEGATE.pcsClient downloadFile:path:&data:self];
    if (response.errorCode != 0) {
        PCSLog(@"download file :%@ from server err.%@",path,response.message);
    } else {
        PCSLog(@"download file :%@ from server success.",path);
    }
    
    return data;
}

- (void)reloadOfflineTableViewData
{
    
}

#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes:(long)total
{
    progressView.progress = (float)bytes/(float)total;
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
