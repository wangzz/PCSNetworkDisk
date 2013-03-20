//
//  PCSDBOperater.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-3-13.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSDBOperater.h"
#import "PCSFileInfoItem.h"
#import "BaiduOAuth.h"
#import "NSStringAdditions.h"

@implementation PCSDBOperater
@synthesize PCSDB;


+ (PCSDBOperater *)shareInstance
{
    static dispatch_once_t once;
    static PCSDBOperater *instance = nil;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        NSString *dbPath = [self copyFile2Documents:@"PcsNetDisk.db"];
        PCSLog(@"Databas path is :%@",dbPath);
        PCSDB= [[FMDatabase databaseWithPath:dbPath] retain];
        if (![PCSDB open]) {
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

//删除本地缓存的文件
- (BOOL)deleteFileWith:(NSString *)name
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                       stringByAppendingPathComponent:PCS_STRING_OFFLINE_CACHE]
                      stringByAppendingPathComponent:[name md5Hash]];
    BOOL    result = NO;
    NSError *err = nil;
    result = [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
    if (!result) {
        PCSLog(@"delete file :%@ failed.%@",name,err);
    } else {
        PCSLog(@"delete file :%@ success.",name);
    }
    
    return result;
}

//根据文件名获取文件的二进制数据
- (NSData *)getFileWith:(NSString *)name
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                       stringByAppendingPathComponent:PCS_STRING_OFFLINE_CACHE]
                      stringByAppendingPathComponent:[name md5Hash]];
    NSData  *fileData = [NSData dataWithContentsOfFile:path];
    
    return fileData;
}

//将文件保存到本地
//为防止文件重名，直接用文件路径经过MD5处理后，作为文件名。
- (BOOL)saveFile:(NSData *)value name:(NSString *)name
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_STRING_OFFLINE_CACHE];

    BOOL    isDirectory = YES;
    BOOL    directoryExit = [[NSFileManager defaultManager] fileExistsAtPath:path
                                                                 isDirectory:&isDirectory];
    if (!directoryExit) {
        NSError *err = nil;
        BOOL createResult = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                                      withIntermediateDirectories:YES
                                                                       attributes:nil
                                                                            error:&err];
        if (!createResult) {
            PCSLog(@"directory :%@ create failed.%@",path,err);
            return NO;
        }
    }
    
    NSString    *picPath = [path stringByAppendingFormat:@"/%@",[name md5Hash]];
    BOOL    result = [value writeToFile:picPath atomically:YES];
    if (!result) {
        PCSLog(@"write file :%@ to cache failed.",name);
        return NO;
    } else {
        PCSLog(@"write file :%@ to cache success.",name);
        return YES;
    }
}

/*
 CREATE TABLE "filelist" ("id" integer primary key  autoincrement  not null ,"name" text COLLATE NOCASE, "serverpath" text not null COLLATE NOCASE, "localpath" text COLLATE NOCASE,"size" integer, "property" integer, "hassubfolder" bool, "format" integer,"ctime" datetime, "mtime" datetime, "hasCache" bool default 0,timestamp TimeStamp NOT NULL DEFAULT (datetime('now','localtime')));
 */


- (BOOL)deleteFile:(NSInteger)fileId
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *sql = [NSString stringWithFormat:@"delete from filelist where id=%d and accountid=%d",fileId,accountID];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@" delete file failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}

//更新文件属性信息
- (BOOL)updateFile:(NSInteger)fileId property:(PCSFileProperty)newProperty
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *sql = [NSString stringWithFormat:@"update filelist set property=%d where id=%d and accountid=%d",newProperty,fileId,accountID];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@" update file property failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}

//从本地数据库获取当前目录下面的子文件（文件夹）
//获取属性为下载和离线两种类型的文件
//以是否为文件夹降序排序，名字升序排序
- (NSArray *)getSubFolderFileListFromDB:(NSString *)currentPath
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSMutableArray  *listArray = [NSMutableArray array];
    NSString    *sql = [NSString stringWithFormat:@"select id, name, serverpath,size,property,format,hassubfolder,ctime,mtime from filelist where parentPath=\"%@\" and accountid=%d and property in (2,3) order by isdir desc,name asc",currentPath,accountID];
    FMResultSet *rs = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    while ([rs next]){
        PCSFileInfoItem *item = [[PCSFileInfoItem alloc] init];
        item.fid = [rs intForColumn:@"id"];
        item.name = [rs stringForColumn:@"name"];
        item.serverPath = [rs stringForColumn:@"serverpath"];
        item.size = [rs intForColumn:@"size"];
        item.format = [rs intForColumn:@"format"];
        item.hasSubFolder = [rs boolForColumn:@"hassubfolder"];
        item.property = [rs intForColumn:@"property"];
        item.ctime = [rs intForColumn:@"ctime"];
        item.mtime = [rs intForColumn:@"mtime"];
        [listArray addObject:item];
        PCS_FUNC_SAFELY_RELEASE(item);
    }

    return listArray;
}

//保存从服务端下载的文件信息
- (BOOL)saveFileInfoItemToDB:(PCSFileInfoItem *)item
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSInteger   isDir = 0;
    if (item.format == PCSFileFormatFolder) {
        isDir = 1;
    }
    NSString    *sql = [NSString stringWithFormat:@"replace into filelist(accountid,name,serverpath,parentPath,localpath,size,property,format,hassubfolder,ctime,mtime,isdir) values(%d,\"%@\",\"%@\",\"%@\",\"%@\",%d,%d,%d,%d,%d,%d,%d)",accountID,PCS_FUNC_SENTENCED_EMPTY(item.name),PCS_FUNC_SENTENCED_EMPTY(item.serverPath),PCS_FUNC_SENTENCED_EMPTY(item.parentPath),PCS_FUNC_SENTENCED_EMPTY(item.localPath),item.size,item.property,item.format,item.hasSubFolder,item.ctime,item.mtime,isDir];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@" save file info to DB failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}

                                                                                                                 
#pragma mark -  登陆数据库操作方法
- (BOOL)isAccountAleadyLogin:(NSString *)account
{
    NSString    *sql = [NSString stringWithFormat:@"select * from accountlist where account=\"%@\"",account];
    FMResultSet *rt = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    return rt.next;
}
                                                                                                                 
- (NSInteger)getAccountIDFronDB:(NSString *)account
{
    NSString    *sql = [NSString stringWithFormat:@"select id from accountlist where account=\"%@\"",account];
    FMResultSet *rt = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    
    NSInteger accountId = -1;
    while (rt.next) {
        accountId = [rt intForColumn:@"id"];
    }
    
    return accountId;
}
                                                                                                             
//保存账户信息
- (BOOL)saveLoginInfoToDB:(BaiduOAuthResponse *)response
{
    NSString    *sql = nil;
    BOOL    accountExist = NO;
    accountExist = [self isAccountAleadyLogin:response.userName];
    if (accountExist) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
        sql = [NSString stringWithFormat:@"update accountlist set timestamp=\"%@\" where account=\"%@\"",
               currentDate,response.userName];
        PCS_FUNC_SAFELY_RELEASE(dateFormatter);
    }else{
        sql = [NSString stringWithFormat:@"replace into accountlist (account) values (\"%@\")",
               response.userName];
    }
    
    if (nil == sql) {
        return NO;
    }
    
    BOOL    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@"save longin info to db failed.reason:%@",
                   self.PCSDB.lastErrorMessage);
        return NO;
    }
    
    //获取账号ID
    NSInteger   accountID = [self getAccountIDFronDB:response.userName];
    //保存当前账号ID
    [[NSUserDefaults standardUserDefaults] setInteger:accountID
                                               forKey:PCS_INTEGER_ACCOUNT_ID];    
    return YES;
}
@end
