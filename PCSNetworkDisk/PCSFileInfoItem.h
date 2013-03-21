//
//  PCSFileInfoItem.h
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-13.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCSFileInfoItem : NSObject

@property (nonatomic, assign) NSInteger  fid;//文件入库时保存生成的id
@property (nonatomic, retain) NSString  *name;//文件、文件夹的名字
@property (nonatomic, retain) NSString  *serverPath;//文件、文件夹在服务器上的路径，同时被作为文件在本地缓存的文件名
@property (nonatomic, retain) NSString  *parentPath;//上层文件夹目录
@property (nonatomic, retain) NSString  *thumbnailPath;//图片文件的缩略图在本地缓存的路径，只对图片文件有效
@property (nonatomic, assign) NSInteger size;//文件大小（单位字节）
@property (nonatomic, assign) PCSFileFormat  format;//文件类型（文件夹，视频，图片等）
@property (nonatomic, assign) PCSFileProperty   property;//文件属性（删除，上传等）
@property (nonatomic, assign) BOOL  hasSubFolder;//文件、文件夹是否有子目录
@property (nonatomic, assign) BOOL  hasCache;//是否有缓存文件
@property (nonatomic, assign) NSInteger  ctime;//文件、文件夹创建时间
@property (nonatomic, assign) NSInteger  mtime;//文件、文件夹最近一次修改时间

@end
