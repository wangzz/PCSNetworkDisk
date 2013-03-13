//
//  PCSFileInfoItem.h
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-13.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCSFileInfoItem : NSObject

@property (nonatomic, assign) NSInteger  sid;//服务器返回的id
@property (nonatomic, retain) NSString  *name;//文件、文件夹的名字
@property (nonatomic, retain) NSString  *serverPath;//文件、文件夹在服务器上的路径
@property (nonatomic, retain) NSString  *localPath;//文件在本地缓存的路径，只有islocal字段为真时才有效
@property (nonatomic, assign) NSInteger size;//文件大小（单位字节）
@property (nonatomic, assign) PCSFileType  type;//文件、文件夹类型
@property (nonatomic, assign) BOOL  hasSubFolder;//文件、文件夹是否有子目录
@property (nonatomic, assign) BOOL  deleted;//文件、文件夹是否被删除
@property (nonatomic, assign) NSInteger  ctime;//文件、文件夹创建时间
@property (nonatomic, assign) NSInteger  mtime;//文件、文件夹最近一次修改时间
@property (nonatomic, assign) BOOL hasCache;//文件在本地是否有缓存

@end
