//
//  PCSMacroDefine.h
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#ifndef PCSNetDisk_PCSMacroDefine_h
#define PCSNetDisk_PCSMacroDefine_h

//数据类型

//文件格式
typedef enum
{
    PCSFileFormatUnknown = 0,
    PCSFileFormatTxt,
    PCSFileFormatDoc,
    PCSFileFormatPdf,
    PCSFileFormatExcel,
    PCSFileFormatPpt,
    PCSFileFormatJpg,
    PCSFileFormatZip,
    PCSFileFormatVideo,
    PCSFileFormatFolder,
    PCSFileFormatAudio,
    
}PCSFileFormat;


//文件属性
typedef enum
{
    PCSFilePropertyNull = 0,
    PCSFilePropertyDelete,//被删除的文件
    PCSFilePropertyDownLoad,//从服务器下载的文件
    PCSFilePropertyOffLineFailed,//离线下载失败的文件
    PCSFilePropertyOffLineWaiting,//等待进行离线下载的文件
    PCSFilePropertyOffLining,//正在离线下载中的文件
    PCSFilePropertyOffLineSuccess,//离线下载成功的文件
    //正在下载中的
}PCSFileProperty;

typedef enum
{
    PCSFileUploadStatusNull = 0,
    PCSFileUploadStatusFailed,//上传失败的文件
    PCSFileUploadStatusWaiting,//等待上传的文件
    PCSFileUploadStatusUploading,//正在上传的文件
    PCSFileUploadStatusSuccess,//成功上传的文件
}PCSFileUploadStatus;

typedef enum
{
    PCSImagePickerTypeUnknow,
    PCSImagePickerTypePhoto,
    PCSImagePickerTypeVideo,
    PCSImagePickerTypeCamera
}PCSImagePickerType;

typedef enum
{
    PCSFolderTypeUnknow = -1,
    PCSFolderTypeNetDisk,
    PCSFolderTypeUpload,
    PCSFolderTypeOffline
}PCSFolderType;

//文件夹名称
#define PCS_FOLDER_UPLOAD_CACHE             @"uploadCache"  //本地上传的缓存文件保存文件夹
#define PCS_FOLDER_OFFLINE_CACHE            @"offlineCache" //离线文件的缓存文件夹
#define PCS_FOLDER_NET_CACHE                @"netCache" //查看网盘文件时，下载到本地的缓存文件夹

//字符串
#define PCS_STRING_MOBWIN_UNIT_ID           @"A495798C12C030F28E7711F3613DFC1B"

//PCS_test
#define PCS_STRING_BAIDU_API_KEY            @"L6g70tBRRIXLsY0Z3HwKqlRE"
#define PCS_STRING_DEFAULT_PATH             @"/apps/pcstest_oauth/"

//hi网盘
//#define PCS_STRING_BAIDU_API_KEY            @"GLz7bjSGqrxaOpj6Mj7ZOvFv"


#define PCS_STRING_EVER_LAUNCHED            @"everLaunched"
#define PCS_STRING_FIRST_LAUNCH             @"firstLaunch"
#define PCS_STRING_IS_LOGIN                 @"isLogin"
#define PCS_STRING_ACCESS_TOKEN             @"accessToken"
#define PCS_STRING_CURSOR                   @"cursor"
#define PCS_STRING_USER_NAME                @"userName"


#define PCS_INTEGER_ACCOUNT_ID              @"accountID"
#define PCS_BOOL_USE_PWD_LOCK               @"usePasswordLock"

//本地通知名称
#define PCS_NOTIFICATION_INCREMENT_UPDATE       @"incrementUpdate"
#define PCS_NOTIFICATION_RELOAD_NETDISK_DATA    @"reloadNetDiskData"
#define PCS_NOTIFICATION_RELOAD_OFFLINE_DATA    @"reloadOfflineData"
#define PCS_NOTIFICATION_UPDATE_OFFLINE_FILE    @"updateOfflineData"
#define PCS_NOTIFICATION_SHOW_PREVIEW_BUTTON    @"showQLPreviewNavButton"


//字体
#define PCS_MAIN_FONT                   [UIFont systemFontOfSize:16.0f]
#define PCS_DETAIL_FONT                 [UIFont systemFontOfSize:13.5f]

//颜色
#define PCS_MAIN_TEXT_COLOR        [UIColor colorWithRed:48.0f/255 green:78.0f/255 blue:98.0f/255 alpha:1.0f]
#define PCS_DETAIL_TEXT_COLOR      [UIColor colorWithRed:151.0f/255 green:166.0f/255 blue:171.0f/255 alpha:1.0f]

//省略字符串
#define PCS_APP_DELEGATE    ((AppDelegate *)[[UIApplication sharedApplication] delegate])

//方法

//判断是否是iPhone5
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//判断字符串是否为nil
#define PCS_FUNC_SENTENCED_EMPTY(string)    (string = ((string == nil) ? @"":string))

//安全释放Object
#define PCS_FUNC_SAFELY_RELEASE(_POINTER_VAR) {[_POINTER_VAR release];_POINTER_VAR = nil;}

#if DEBUG==1
#define PCSLog(format,...)  NSLog((@"%s [Line %d] " format),__FUNCTION__,__LINE__,##__VA_ARGS__)
#else
#define PCSLog(format,...)
#endif


#endif
