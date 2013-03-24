//
//  PCSUploadViewController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PCSUploadViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,BaiduPCSStatusListener>
{
    NSIndexPath *currentUploadFileIndexPath;//当前正在上传的文件index
}
@end
