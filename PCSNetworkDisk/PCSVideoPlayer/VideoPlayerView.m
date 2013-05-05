//
//  VideoPlayerView.m
//  VideoStreamer2
//
//  Created by Kyle Powers on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoPlayerView

+ (Class)layerClass {
	return [AVPlayerLayer class];
}

- (AVPlayer*)player {
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player {
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)setPlayerWithPath:(NSString *)path {
    AVPlayer    *videoPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
    [self setPlayer:videoPlayer];
}

- (void)setVideoFillMode:(NSString *)fillMode {
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}

@end
