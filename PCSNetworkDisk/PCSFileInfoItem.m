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
@synthesize localPath;
@synthesize size;
@synthesize format;
@synthesize hasSubFolder;
@synthesize hasCache;
@synthesize property;
@synthesize ctime;
@synthesize mtime;


- (NSString *)description
{
    NSString *des = [NSString stringWithFormat:@"fid:%d,name:%@,serverPath:%@,localPath:%@,size:%d,format:%d,hasSubFolder:%d,hasCache:%d,property:%d,ctime:%d,mtime:%d,",self.fid,self.name,self.serverPath,self.localPath,self.size,self.format,self.hasSubFolder,self.hasCache,self.property,self.ctime,self.mtime];
    return des;
}

@end
