//
//  PCSFileInfoItem.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-13.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSFileInfoItem.h"

@implementation PCSFileInfoItem
@synthesize sid;
@synthesize name;
@synthesize serverPath;
@synthesize localPath;
@synthesize size;
@synthesize type;
@synthesize hasSubFolder;
@synthesize deleted;
@synthesize ctime;
@synthesize mtime;
@synthesize hasCache;

- (NSString *)description
{
    NSString *des = [NSString stringWithFormat:@"sid:%d,name:%@,serverPath:%@,localPath:%@,size:%d,type:%d,hasSubFolder:%d,deleted:%d,ctime:%d,mtime:%d,hasCache:%d",self.sid,self.name,self.serverPath,self.localPath,self.size,self.type,self.hasSubFolder,self.deleted,self.ctime,self.mtime,self.hasCache];
    return des;
}

@end
