//
//  PCSMainTabBarController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSMainTabBarController.h"
#import "PCSNetDiskViewController.h"
#import "PCSOfflineViewController.h"
#import "PCSUploadViewController.h"
#import "PCSMoreViewController.h"
#import "PCSFileInfoItem.h"

@interface PCSMainTabBarController ()

@end

@implementation PCSMainTabBarController
@synthesize netDiskNavController;
@synthesize uploadNavController;
@synthesize offlineNavController;
@synthesize moreNavController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    PCS_FUNC_SAFELY_RELEASE(netDiskNavController);
    PCS_FUNC_SAFELY_RELEASE(uploadNavController);
    PCS_FUNC_SAFELY_RELEASE(offlineNavController);
    PCS_FUNC_SAFELY_RELEASE(moreNavController);

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self createTabBarControllers];
    [self updateFileInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createTabBarControllers
{
    PCSNetDiskViewController *netDiskViewController = [[PCSNetDiskViewController alloc] init];
    netDiskViewController.path = PCS_STRING_DEFAULT_PATH;
    netDiskNavController = [[UINavigationController alloc]initWithRootViewController:netDiskViewController];
    netDiskNavController.tabBarItem.title = @"云盘";
    netDiskViewController.tabBarItem.image = [UIImage imageNamed:@"tab_vdisk"];
    PCS_FUNC_SAFELY_RELEASE(netDiskViewController);
    
    UIViewController *uploadViewController = [[PCSUploadViewController alloc] init];
    uploadNavController = [[UINavigationController alloc] initWithRootViewController:uploadViewController];
    uploadNavController.tabBarItem.title = @"上传";
    uploadNavController.tabBarItem.image = [UIImage imageNamed:@"tab_upload"];
    PCS_FUNC_SAFELY_RELEASE(uploadViewController);
    
    UIViewController *offlineViewController = [[PCSOfflineViewController alloc] init] ;
    offlineNavController = [[UINavigationController alloc] initWithRootViewController:offlineViewController];
    offlineNavController.tabBarItem.title = @"离线";
    offlineNavController.tabBarItem.image = [UIImage imageNamed:@"tab_shares"];
    PCS_FUNC_SAFELY_RELEASE(offlineViewController);
    
    UIViewController *moreViewController = [[PCSMoreViewController alloc] init];
    moreNavController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
    moreNavController.tabBarItem.title = @"更多";
    moreNavController.tabBarItem.image = [UIImage imageNamed:@"tab_more"];
    PCS_FUNC_SAFELY_RELEASE(moreViewController);
    
    NSArray   *controllers = [NSArray arrayWithObjects:
                              netDiskNavController,uploadNavController,offlineNavController,moreNavController, nil];
    
    self.viewControllers = controllers;
}

#pragma mark - 增量更新界面数据
- (void)updateFileInfo
{
    dispatch_queue_t queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        NSString    *cursor = nil;
        cursor = [[NSUserDefaults standardUserDefaults] stringForKey:PCS_STRING_CURSOR];
        BOOL    needReload = NO;
        needReload = [self getIncrementUpdateFromServer:cursor];
        if (needReload) {
            //重新获取界面数据源
            [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_RELOAD_DATA
                                                                object:nil];
        }
    });
}

- (PCSFileFormat)getFileTypeWith:(NSString *)name
{
    PCSFileFormat fileType = PCSFileFormatUnknown;
    NSString    *pathExtension = [name pathExtension];
    if ([pathExtension isEqualToString:@"txt"]) {
        fileType = PCSFileFormatTxt;
    } else if ([pathExtension isEqualToString:@"jpg"] ||
               [pathExtension isEqualToString:@"jpeg"] ||
               [pathExtension isEqualToString:@"png"] ||
               [pathExtension isEqualToString:@"gif"] ||
               [pathExtension isEqualToString:@"bmp"]) {
        fileType = PCSFileFormatJpg;
    } else if ([pathExtension isEqualToString:@"doc"] ||
               [pathExtension isEqualToString:@"docx"]) {
        fileType = PCSFileFormatDoc;
    } else if ([pathExtension isEqualToString:@"pdf"]) {
        fileType = PCSFileFormatPdf;
    } else if ([pathExtension isEqualToString:@"rar"] ||
               [pathExtension isEqualToString:@"zip"] ||
               [pathExtension isEqualToString:@"7z"] ||
               [pathExtension isEqualToString:@"tar"] ||
               [pathExtension isEqualToString:@"tgz"]) {
        fileType = PCSFileFormatZip;
    } else if ([pathExtension isEqualToString:@"mp3"] ||
               [pathExtension isEqualToString:@"pcm"] ||
               [pathExtension isEqualToString:@"wav"] ||
               [pathExtension isEqualToString:@"wma"] ||
               [pathExtension isEqualToString:@"aac"]) {
        fileType = PCSFileFormatAudio;
    } else if ([pathExtension isEqualToString:@"avi"] ||
               [pathExtension isEqualToString:@"wmv"] ||
               [pathExtension isEqualToString:@"mpeg"] ||
               [pathExtension isEqualToString:@"rmvb"] ||
               [pathExtension isEqualToString:@"rm"] ||
               [pathExtension isEqualToString:@"mp4"] ||
               [pathExtension isEqualToString:@"3gp"] ||
               [pathExtension isEqualToString:@"mov"]) {
        fileType = PCSFileFormatVideo;
    }
    return fileType;
}

/*!
 @method
 @abstract 从服务端获取文件增量更新数据
 @param 上次从服务端获取的更新标识
 @return 是否获取到了新的数据，用于确定是否需要更新界面
 */
-(BOOL)getIncrementUpdateFromServer:(NSString *)cursor
{
    PCSDiffResponse *response = [PCS_APP_DELEGATE.pcsClient diff:cursor];
    if(response){
        PCSSimplefiedResponse   *status = response.status;
        if (status.errorCode != 0) {
            PCSLog(@"get diff err,%@",status.message);
            return NO;
        }
        
        for(int i = 0; i < [response.entries count]; ++i){
            PCSDifferEntryInfo *info = [response.entries objectAtIndex:i];
            
            PCSCommonFileInfo   *tmp = info.commonFileInfo;
            NSArray *array = [tmp.path componentsSeparatedByString:@"/"];
            NSMutableString    *parentPathString = [NSMutableString string];;
            for (NSInteger i = 0;i < array.count;i++) {
                NSString    *string = [array objectAtIndex:i];
                if (i < (array.count - 1)) {
                    [parentPathString appendFormat:@"%@/",string];
                }
            }
            
            if (array != nil) {
                NSString    *fileName = [array objectAtIndex:(array.count - 1)];
                PCSFileInfoItem *item = [[PCSFileInfoItem alloc] init];
                item.name = fileName;
                item.size = tmp.size;
                item.hasSubFolder = tmp.hasSubFolder;
                item.serverPath = tmp.path;
                item.ctime = tmp.cTime;
                item.mtime = tmp.mTime;
                item.parentPath = parentPathString;
                if (tmp.isDir) {
                    item.format = PCSFileFormatFolder;
                } else {
                    item.format = [self getFileTypeWith:fileName];
                }
                
                if (info.isDeleted) {
                    item.property = PCSFilePropertyDelete;
                } else {
                    item.property = PCSFilePropertyDownLoad;
                }
                
                //文件数据入库
                [[PCSDBOperater shareInstance] saveFileInfoItemToDB:item];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:response.cursor
                                                 forKey:PCS_STRING_CURSOR];
        if (response.hasMore) {
            //服务端的数据未下载完全，需要再次发起请求
            //
            //
        }
        if (response.entries.count > 0) {
            return YES;
        }
    }
    return NO;
}

@end
