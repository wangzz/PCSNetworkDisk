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

/*
 CREATE TABLE "filelist" ("id" integer primary key  autoincrement  not null ,"name" text COLLATE NOCASE, "serverpath" text not null COLLATE NOCASE, "localpath" text COLLATE NOCASE,"size" integer, "property" integer, "hassubfolder" bool, "format" integer,"ctime" datetime, "mtime" datetime, "hasCache" bool default 0,timestamp TimeStamp NOT NULL DEFAULT (datetime('now','localtime')));
 */


//从本地数据库获取当前目录下面的子文件（文件夹）
- (NSArray *)getSubFolderFileListFromDB:(NSString *)currentPath
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSMutableArray  *listArray = [NSMutableArray array];
    NSString    *sql = [NSString stringWithFormat:@"select id, name, serverpath,size,property,format,hassubfolder,ctime,mtime from filelist where parentPath=\"%@\" and accountid=%d",currentPath,accountID];
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
    NSString    *sql = [NSString stringWithFormat:@"replace into filelist(accountid,name,serverpath,parentPath,localpath,size,property,format,hassubfolder,ctime,mtime) values(%d,\"%@\",\"%@\",\"%@\",\"%@\",%d,%d,%d,%d,%d,%d)",accountID,PCS_FUNC_SENTENCED_EMPTY(item.name),PCS_FUNC_SENTENCED_EMPTY(item.serverPath),PCS_FUNC_SENTENCED_EMPTY(item.parentPath),PCS_FUNC_SENTENCED_EMPTY(item.localPath),item.size,item.property,item.format,item.hasSubFolder,item.ctime,item.mtime];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    NSLog(@"pcsdb:%@",self.PCSDB);
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
