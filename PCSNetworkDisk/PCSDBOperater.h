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
 CREATE TABLE "filelist" ("id" integer primary key  autoincrement  not null ,accountid integer , "name" text COLLATE NOCASE, "serverpath" text not null COLLATE NOCASE, "parentpath" text COLLATE NOCASE,"thumbnailPath" text COLLATE NOCASE,"size" integer, "property" integer, "hassubfolder" bool, "format" integer,"ctime" datetime, "mtime" datetime, "hascache" bool default 0,timestamp TimeStamp NOT NULL DEFAULT (datetime('now','localtime')), isdir bool default 0);
 CREATE TABLE "uploadfilelist" ("id" integer primary key  autoincrement  not null ,accountid integer , "name" text COLLATE NOCASE, "cachepath" text COLLATE NOCASE,"size" integer, "status" integer, "format" integer,"mtime" datetime, timestamp TimeStamp NOT NULL DEFAULT (datetime('now','localtime')));
 CREATE UNIQUE INDEX uk_filelist on filelist(accountid, name ,parentpath);
 CREATE UNIQUE INDEX uk_uploadfilelist on uploadfilelist(accountid, name ,cachepath);
 */

@class PCSFileInfoItem;
@class BaiduOAuthResponse;
@interface PCSDBOperater : NSObject

@property(nonatomic,retain) FMDatabase  *PCSDB;

+ (PCSDBOperater *)shareInstance;



- (PCSFileInfoItem *)getNextUploadFileInfo;
- (BOOL)hasUploadingFile;
- (BOOL)updateUploadFile:(NSString *)name status:(PCSFileUploadStatus)newStatus;
- (BOOL)saveUploadFileToDB:(PCSFileInfoItem *)item;
- (NSDictionary *)getUploadFileFromDB;

- (BOOL)deleteFileWith:(NSString *)name;
- (NSData *)getFileWith:(NSString *)name;
- (BOOL)saveFile:(NSData *)value name:(NSString *)name;

- (BOOL)saveLoginInfoToDB:(BaiduOAuthResponse *)response;
- (BOOL)saveFileInfoItemToDB:(PCSFileInfoItem *)item;
- (NSArray *)getSubFolderFileListFromDB:(NSString *)currentPath;
- (BOOL)updateFile:(NSInteger)fileId property:(PCSFileProperty)newProperty;
- (BOOL)deleteFile:(NSInteger)fileId;
- (PCSFileFormat)getFileTypeWith:(NSString *)name;
@end
