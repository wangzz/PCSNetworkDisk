//
//  PCSNetDiskViewController.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{   
    PCSFileTypeUnknown = 0,
    PCSFileTypeTxt,
    PCSFileTypeDoc,
    PCSFileTypePdf,
    PCSFileTypeJpg,
    PCSFileTypeZip,
    PCSFileTypeVideo,
    PCSFileTypeFolder,
    PCSFileTypeMusic,
    
}PCSFileType;

@interface PCSFileInfoItem : NSObject
 
@property (nonatomic, retain) NSString  *name;
@property (nonatomic, retain) NSString  *path;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) PCSFileType  type;
@property (nonatomic, assign) BOOL  hasSubFolder;

@end


@interface PCSNetDiskViewController : UIViewController<MobWinBannerViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    MobWinBannerView *adBanner;
}

@property (nonatomic, copy) NSString    *path;

@end