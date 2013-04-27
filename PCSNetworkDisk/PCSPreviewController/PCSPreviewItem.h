//
//  PCSPreviewItem.h
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-27.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface PCSPreviewItem : NSObject<QLPreviewItem>

+ (PCSPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title;

@property (retain) NSURL *previewItemURL;
@property (retain) NSString *previewItemTitle;

@end
