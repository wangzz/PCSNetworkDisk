//
//  PCSFileInfoItem.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-13.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSFileInfoItem.h"


@implementation PCSFileInfoItem
@synthesize fid;
@synthesize name;
@synthesize serverPath;
@synthesize parentPath;
@synthesize thumbnailPath;
@synthesize size;
@synthesize format;
@synthesize hasSubFolder;
@synthesize hasCache;
@synthesize property;
@synthesize ctime;
@synthesize mtime;


- (NSString *)description
{
    NSString *des = [NSString stringWithFormat:@"fid:%d,name:%@,serverPath:%@,parentPath:%@,thumbnailPath:%@,size:%d,format:%d,hasSubFolder:%d,hasCache:%d,property:%d,ctime:%d,mtime:%d,",self.fid,PCS_FUNC_SENTENCED_EMPTY(self.name),PCS_FUNC_SENTENCED_EMPTY(self.serverPath),PCS_FUNC_SENTENCED_EMPTY(self.parentPath),PCS_FUNC_SENTENCED_EMPTY(self.thumbnailPath),self.size,self.format,self.hasSubFolder,self.hasCache,self.property,self.ctime,self.mtime];
    return des;
}

@end
