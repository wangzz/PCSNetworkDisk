//
//  PCSVideoPlayerController.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-5-4.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSVideoPlayerController.h"
#import "VideoPlayerView.h"
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAnimation.h>
#import "MBProgressHUD.h"
#import "UIViewController+NavAddition.h"

@interface PCSVideoPlayerController ()
@property (nonatomic,retain) MBProgressHUD  *HUD;
@end

@implementation PCSVideoPlayerController

@synthesize videoPlayer  = _videoPlayer;
@synthesize playbackButton = _playbackButton;
@synthesize path    = _path;
@synthesize folderType = _folderType;
@synthesize HUD = _HUD;

- (id)init
{
    if(self = [super init])
    {
        _isPlaying = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
    }
    return self;
}

- (id)initWithPath:(NSString *)filePath type:(PCSFolderType)fileType
{
    if (self = [self init]) {
        _path = filePath;
        _folderType = fileType;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    [super dealloc];
}

- (void)setNavBarAppearance:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
        [self customNavgationBar];
    } else {
        [self createNavBackButtonWithTitle:@"返回"];
    }
}

- (void)onNavBackButtonAction
{
    [self dismissVideoPlayer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavBarAppearance:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_videoPlayer.player pause];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSString    *absolutePath = [[PCSDBOperater shareInstance] absolutePathBy:_path
                                                                   folderType:_folderType];
    BOOL    fileExit = NO;
    fileExit = [[NSFileManager defaultManager] fileExistsAtPath:absolutePath];
    if (fileExit) {
        //文件存在，直接播放
        [self createVideoPlayerViewWith:absolutePath];
    } else {
        //文件不存在，下载后播放
        [self downloadFileFromServer:_path folderType:_folderType];
    }
}

- (void)customNavgationBar
{
    UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismissVideoPlayer)];
    self.navigationItem.leftBarButtonItem = returnButton;
}

- (void)dismissVideoPlayer
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)createVideoPlayerViewWith:(NSString *)absolutePath
{
    self.view.backgroundColor = [UIColor blackColor];
    _videoPlayer = [[VideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [_videoPlayer setPlayerWithPath:absolutePath];
    [_videoPlayer setVideoFillMode:AVLayerVideoGravityResizeAspect];
    [self.view addSubview:_videoPlayer];
    
    self.playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playbackButton.frame = CGRectMake(self.view.frame.size.width / 2 - 32, self.view.frame.size.height / 2 - 32, 64, 64);
    [self.playbackButton setBackgroundImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
    [self.playbackButton addTarget:self action:@selector(togglePlayback:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.playbackButton];
}

#pragma mark - PCSMethod
- (void)hideFileDownloadingView
{
    PCSLog(@"dissmiss downloading notice view.");
    [_HUD hide:YES];
    [_HUD release];
}

- (void)showFileDownloadFailedView
{
    PCSLog(@"file download failed.");
    [_HUD hide:YES];
    [_HUD release];
}

- (void)showFileBeginDownloadView
{
    PCSLog(@"file download begin.");
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
    _HUD.mode = MBProgressHUDModeDeterminate;
	_HUD.dimBackground = YES;
	_HUD.labelText = @"下载中...";
    [_HUD show:YES];
}

- (void)downloadFileFromServer:(NSString *)path folderType:(PCSFolderType)type
{
    [self showFileBeginDownloadView];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *data = nil;
        PCSSimplefiedResponse *response = [PCS_APP_DELEGATE.pcsClient downloadFile:path:&data:self];
        dispatch_sync(dispatch_get_main_queue(), ^{
            //让文件下载中界面消失
            [self hideFileDownloadingView];
            if (response.errorCode == 0) {
                PCSLog(@"download file :%@ from server success.",path);
                BOOL result = NO;
                switch (_folderType) {
                    case PCSFolderTypeNetDisk:
                        result = [[PCSDBOperater shareInstance] saveFileToNetCache:data name:path];
                        break;
                    case PCSFolderTypeUpload:
                        result = [[PCSDBOperater shareInstance] saveFileToUploadCache:data name:path];
                        break;
                    case PCSFolderTypeOffline:
                        result = [[PCSDBOperater shareInstance] saveFileToOfflineCache:data name:path];
                        break;
                    default:
                        break;
                }
                
                if (result) {
                    NSString    *absolutePath = [[PCSDBOperater shareInstance] absolutePathBy:path
                                                                                   folderType:type];
                    [self createVideoPlayerViewWith:absolutePath];
                }
            } else {
                //显示文件下载失败界面
                [self showFileDownloadFailedView];
                PCSLog(@"download file :%@ from server failed.",path);
            }
        });
    });
}

#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes :(long)total
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
        float progress = (float)bytes/(float)total;
        _HUD.progress = progress;
        PCSLog(@"current download progress:%f",progress);
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

- (void)togglePlayback:(id)sender
{
    if(!_isPlaying)
    {
        [self play];
    }
    else
    {
        [self pause];
    }
}

- (void) play
{
    [_videoPlayer.player play];
    [_playbackButton setBackgroundImage:[UIImage imageNamed:@"PauseButton.png"] forState:UIControlStateNormal];
    [self hideControls:YES];
    _isPlaying = YES;
}

- (void) pause
{
    [_videoPlayer.player pause];
    [_playbackButton setBackgroundImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
    _isPlaying = NO;
}

- (void)toggleControls
{
    if(_playbackButton.alpha == 0)
    {
        [self showControls:YES];
    }
    else
    {
        [self hideControls:YES];
    }
}

- (void)showControls:(BOOL)animated {
    NSTimeInterval duration = (animated) ? 0.5 : 0;
    
    [UIView animateWithDuration:duration animations:^() {
        _playbackButton.alpha = 1;
    }];
}

- (void)hideControls:(BOOL)animated {
    NSTimeInterval duration = (animated) ? 0.5 : 0;
    
    [UIView animateWithDuration:duration animations:^() {
        _playbackButton.alpha = 0;
    }];
}

- (void)hideSelf:(id)sender {
    NSTimeInterval duration = (sender) ? 0.5 : 0;
    
    [UIView animateWithDuration:duration animations:^ {
        self.view.alpha = 0;
    }];
}

- (void)showSelf:(id)sender {
    NSTimeInterval duration = (sender) ? 0.5 : 0;
    
    [UIView animateWithDuration:duration animations:^ {
        self.view.alpha = 1;
    }];
    
    [self hideControls:NO];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [_videoPlayer.player seekToTime:kCMTimeZero];
    [_playbackButton setBackgroundImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
    _isPlaying = NO;
    
    [self showControls:YES];
}

#pragma mark - touch event
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    if(touch.tapCount == 1)
    {
        [self toggleControls];
        
        // tell the controller
//        if([self.videoDelegate respondsToSelector:@selector(didTapVideoView:)])
//            [self.videoDelegate didTapVideoView:self];
    }
}

@end
