//
//  PCSPreviewController.h
//  PCSNetworkDisk
//
//  Created by wangzz on 13-4-26.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <QuickLook/QuickLook.h>

@interface PCSPreviewController : QLPreviewController<BaiduPCSStatusListener,QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property(nonatomic,retain) NSString    *filePath;
@property(nonatomic,retain) NSString    *title;
@property(nonatomic,assign) PCSFolderType  folderType;

@end
