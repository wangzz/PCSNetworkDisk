//
//  PCSDBOperater.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-13.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSDBOperater.h"
#import "PCSFileInfoItem.h"

@implementation PCSDBOperater
@synthesize PCSDB;


+ (PCSDBOperater *)shareInstance
{
    static dispatch_once_t once;
    static PCSDBOperater *instance = nil;
    dispatch_once(&once, ^{
        instance = [[PCSDBOperater alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        NSString *dbPath = [self copyFile2Documents:@"PcsNetDisk.db"];
        PCSLog(@"Databas path is :%@",dbPath);
        PCSDB= [FMDatabase databaseWithPath:dbPath] ;
        if (![self.PCSDB open]) {
            PCSLog(@"open %@ error! error msg is:%@",dbPath,[PCSDB lastErrorMessage]);
        }
    }
    return self;
}

- (NSString*)copyFile2Documents:(NSString*)fileName
{
    NSFileManager*fileManager =[NSFileManager defaultManager];
    NSError*error;
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString*destPath =[documentsDirectory stringByAppendingPathComponent:fileName];
    
    if(![fileManager fileExistsAtPath:destPath]){
        NSString* sourcePath =[[NSBundle mainBundle] pathForResource:@"PcsNetDisk" ofType:@"db"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
    }
    return destPath;
}

/*
 CREATE TABLE "filelist" ("id" integer primary key  autoincrement  not null ,"name" text COLLATE NOCASE, "serverpath" text not null COLLATE NOCASE, "localpath" text COLLATE NOCASE,"size" integer, "property" integer, "hassubfolder" bool, "format" integer,"ctime" datetime, "mtime" datetime, "hasCache" bool default 0,timestamp TimeStamp NOT NULL DEFAULT (datetime('now','localtime')));
 */

- (BOOL)saveFileInfoItemToDB:(PCSFileInfoItem *)item
{
    NSString    *sql = [NSString stringWithFormat:@"insert into filelist(name,serverpath,localpath,size,property,format,hassubfolder,ctime,mtime) values(\"%@\",\"%@\",\"%@\",%d,%d,%d,%d,%d,%d)",PCS_FUNC_SENTENCED_EMPTY(item.name),PCS_FUNC_SENTENCED_EMPTY(item.serverPath),PCS_FUNC_SENTENCED_EMPTY(item.localPath),item.size,item.property,item.format,item.hasSubFolder,item.ctime,item.mtime];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    result = [self.PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@" save file info to DB failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}


@end
