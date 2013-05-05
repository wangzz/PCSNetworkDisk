//
//  VideoPlayerView.h
//  VideoStreamer2
//
//  Created by Kyle Powers on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface VideoPlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setPlayerWithPath:(NSString *)path;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
