//
//  PCSUploadViewController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSDirectoryDelegate.h"

@interface PCSUploadViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,BaiduPCSStatusListener,HSDirectoryDelegate>

@end
