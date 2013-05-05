//
//  PCSVideoPlayerController.h
//  PCSNetworkDisk
//
//  Created by wangzz on 13-5-4.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVPlayer.h"


@class VideoPlayerView;

@interface PCSVideoPlayerController : UIViewController<BaiduPCSStatusListener>
{
    BOOL _isPlaying;
}

@property (nonatomic, retain) UIButton * playbackButton;
@property (nonatomic, retain) VideoPlayerView * videoPlayer;
@property (nonatomic, retain) NSString  *path;
@property (nonatomic, assign) PCSFolderType folderType;

- (id)initWithPath:(NSString *)filePath type:(PCSFolderType)fileType;

- (void)togglePlayback:(id)sender;
- (void)toggleControls;
- (void)showControls:(BOOL)animated;
- (void)hideControls:(BOOL)animated;
- (void)hideSelf:(id)sender;
- (void)showSelf:(id)sender;

- (void)playerItemDidReachEnd:(NSNotification *)notification;

@end
