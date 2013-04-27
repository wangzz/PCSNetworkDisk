//
//  PCSPreviewItem.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-27.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSPreviewItem.h"

@implementation PCSPreviewItem
@synthesize previewItemTitle;
@synthesize previewItemURL;


+ (PCSPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title
{
    PCSPreviewItem *instance = [[PCSPreviewItem alloc] init];
	instance.previewItemURL = URL;
	instance.previewItemTitle = title;
	return [instance autorelease];
}

@end
