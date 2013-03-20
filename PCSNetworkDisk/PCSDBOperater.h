//
//  PCSDBOperater.h
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-13.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

/*!
 数据库创建脚本：
 CREATE TABLE "accountlist" ("id" integer primary key  autoincrement  not null ,"account" text COLLATE NOCASE UNIQUE ,timestamp TimeStamp NOT NULL DEFAULT (datetime('now','localtime')));
 CREATE TABLE "filelist" ("id" integer primary key  autoincrement  not null ,accountid integer , "name" text COLLATE NOCASE, "serverpath" text not null COLLATE NOCASE, "parentpath" text COLLATE NOCASE,"localpath" text COLLATE NOCASE,"size" integer, "property" integer, "hassubfolder" bool, "format" integer,"ctime" datetime, "mtime" datetime, "hascache" bool default 0,timestamp TimeStamp NOT NULL DEFAULT (datetime('now','localtime')), isdir bool default 0);
 CREATE UNIQUE INDEX uk_filelist on filelist(accountid, name ,parentpath);
 */

@class PCSFileInfoItem;
@class BaiduOAuthResponse;
@interface PCSDBOperater : NSObject

@property(nonatomic,retain) FMDatabase  *PCSDB;

+ (PCSDBOperater *)shareInstance;

- (BOOL)deleteFileWith:(NSString *)name;
- (NSData *)getFileWith:(NSString *)name;
- (BOOL)saveFile:(NSData *)value name:(NSString *)name;

- (BOOL)saveLoginInfoToDB:(BaiduOAuthResponse *)response;
- (BOOL)saveFileInfoItemToDB:(PCSFileInfoItem *)item;
- (NSArray *)getSubFolderFileListFromDB:(NSString *)currentPath;
- (BOOL)updateFile:(NSInteger)fileId property:(PCSFileProperty)newProperty;
- (BOOL)deleteFile:(NSInteger)fileId;
@end
