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

#pragma mark - 文件的本地缓存操作
//从本地缓存uploadCache目录下的文件
- (BOOL)deleteFileFromUploadCache:(NSString *)name
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                       stringByAppendingPathComponent:PCS_FOLDER_UPLOAD_CACHE]
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

//从本地缓存offlineCache目录下的文件
- (BOOL)deleteFileFromOfflineCache:(NSString *)name
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                       stringByAppendingPathComponent:PCS_FOLDER_OFFLINE_CACHE]
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

//根据文件名从Documents/uploadCache文件夹获取文件的二进制数据
- (NSData *)getFileFromUploadCacheBy:(NSString *)name
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                       stringByAppendingPathComponent:PCS_FOLDER_UPLOAD_CACHE]
                      stringByAppendingPathComponent:[name md5Hash]];
    NSData  *fileData = [NSData dataWithContentsOfFile:path];
    return fileData;
}

//根据文件名从Documents/offlineCache文件夹获取文件的二进制数据
- (NSData *)getFileFromOfflineCacheBy:(NSString *)name
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                       stringByAppendingPathComponent:PCS_FOLDER_OFFLINE_CACHE]
                      stringByAppendingPathComponent:[name md5Hash]];
    NSData  *fileData = [NSData dataWithContentsOfFile:path];
    return fileData;
}

//将文件保存到沙盒Documents/uploadCache目录下
- (BOOL)saveFileToUploadCache:(NSData *)value name:(NSString *)name
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_FOLDER_UPLOAD_CACHE];
    return [self saveFileToPath:path data:value name:name];
}

//将文件保存到沙盒Documents/offlineCache目录下
- (BOOL)saveFileToOfflineCache:(NSData *)value name:(NSString *)name
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:PCS_FOLDER_OFFLINE_CACHE];
    return [self saveFileToPath:path data:value name:name];
}

//为防止文件重名，直接用文件路径经过MD5处理后，作为文件名。
- (BOOL)saveFileToPath:(NSString *)path data:(NSData *)value name:(NSString *)name
{
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

- (PCSFileFormat)getFileTypeWith:(NSString *)name
{
    PCSFileFormat fileType = PCSFileFormatUnknown;
    NSString    *pathExtension = [name pathExtension];
    if ([pathExtension isEqualToString:@"txt"]) {
        fileType = PCSFileFormatTxt;
    } else if ([pathExtension isEqualToString:@"jpg"] ||
               [pathExtension isEqualToString:@"jpeg"] ||
               [pathExtension isEqualToString:@"png"] ||
               [pathExtension isEqualToString:@"gif"] ||
               [pathExtension isEqualToString:@"bmp"]) {
        fileType = PCSFileFormatJpg;
    } else if ([pathExtension isEqualToString:@"doc"] ||
               [pathExtension isEqualToString:@"docx"]) {
        fileType = PCSFileFormatDoc;
    } else if ([pathExtension isEqualToString:@"pdf"]) {
        fileType = PCSFileFormatPdf;
    } else if ([pathExtension isEqualToString:@"xls"] ||
               [pathExtension isEqualToString:@"xlsx"] ||
               [pathExtension isEqualToString:@"xlt"] ||
               [pathExtension isEqualToString:@"xltx"]) {
        fileType = PCSFileFormatExcel;
    } else if ([pathExtension isEqualToString:@"ppt"] ||
               [pathExtension isEqualToString:@"pptx"] ||
               [pathExtension isEqualToString:@"pot"] ||
               [pathExtension isEqualToString:@"potx"]) {
        fileType = PCSFileFormatPpt;
    } else if ([pathExtension isEqualToString:@"rar"] ||
               [pathExtension isEqualToString:@"zip"] ||
               [pathExtension isEqualToString:@"7z"] ||
               [pathExtension isEqualToString:@"tar"] ||
               [pathExtension isEqualToString:@"tgz"]) {
        fileType = PCSFileFormatZip;
    } else if ([pathExtension isEqualToString:@"mp3"] ||
               [pathExtension isEqualToString:@"pcm"] ||
               [pathExtension isEqualToString:@"wav"] ||
               [pathExtension isEqualToString:@"wma"] ||
               [pathExtension isEqualToString:@"aac"]) {
        fileType = PCSFileFormatAudio;
    } else if ([pathExtension isEqualToString:@"avi"] ||
               [pathExtension isEqualToString:@"wmv"] ||
               [pathExtension isEqualToString:@"mpeg"] ||
               [pathExtension isEqualToString:@"rmvb"] ||
               [pathExtension isEqualToString:@"rm"] ||
               [pathExtension isEqualToString:@"mp4"] ||
               [pathExtension isEqualToString:@"3gp"] ||
               [pathExtension isEqualToString:@"mov"]) {
        fileType = PCSFileFormatVideo;
    }
    return fileType;
}

#pragma mark - 删除一个文件记录在本地所有内容
- (BOOL)deleteAllFileInfoFromLocal:(PCSFileInfoItem *)item
{
    //找出该文件夹所有子文件
    //排除掉子目录，因为目录在offlineCache中没有缓存文件
    //且只查找property为PCSFilePropertyOffLineSuccess状态的记录（有缓存文件的）
    //将这些这文件在offlineCache中的缓存文件删除
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *deleteCacheql = [NSString stringWithFormat:@"select serverpath from filelist where parentPath like \"%@%%\" and accountid=%d and format not in(%d) and property=%d",item.serverPath,accountID,PCSFileFormatFolder,PCSFilePropertyOffLineSuccess];
    FMResultSet *rs = [[PCSDBOperater shareInstance].PCSDB executeQuery:deleteCacheql];
    while ([rs next]){
        NSString    *filePath = [rs stringForColumn:@"serverpath"];
        [self deleteFileFromOfflineCache:filePath];
    }
    
    //删除该目录，以及该目录下面的所有子文件、文件夹在filelist表中的记录
    BOOL result = NO;
    NSString    *deleteSubSql = [NSString stringWithFormat:@"delete from filelist where parentPath like \"%@%%\" and accountid=%d",item.serverPath,accountID];
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:deleteSubSql];
    if (!result) {
        PCSLog(@"delete %@ sub file from filelist failed.%@ ",item.serverPath,[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    } else {
        PCSLog(@"delete %@ sub file from filelist success.",item.serverPath);
    }  
    
    //从filelist表中删除当前文件记录
    NSString    *deleteCurrentSql = [NSString stringWithFormat:@"delete from filelist where serverpath= \"%@\" and accountid=%d",item.serverPath,accountID];
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:deleteCurrentSql];
    if (!result) {
        PCSLog(@"delete %@ current file from filelist failed.%@ ",item.serverPath,[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    } else {
        PCSLog(@"delete %@ current file from filelist success.",item.serverPath);
    }
    
    return result;
}

#pragma mark - uploadfilelist表数据库操作方法
- (BOOL)deleteFromUploadFileList:(NSInteger)fid
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *sql = [NSString stringWithFormat:@"delete from uploadfilelist where id=%d and accountid=%d",fid,accountID];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@"delete upload file failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}

//获得下一个要上传的文件信息
//选择最早入库的那个（先添加先上传）
//只找出一条
- (PCSFileInfoItem *)getNextUploadFileInfo
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    PCSFileInfoItem *item = nil;
    NSString    *sql = [NSString stringWithFormat:@"select id, name, cachepath,size,status,format,mtime from uploadfilelist where accountid=%d and status=%d order by mtime asc limit 1",accountID,PCSFileUploadStatusWaiting];
    FMResultSet *rs = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    while ([rs next]){
        item = [[[PCSFileInfoItem alloc] init] autorelease];
        item.fid = [rs intForColumn:@"id"];
        item.name = [rs stringForColumn:@"name"];
        item.serverPath = [rs stringForColumn:@"cachepath"];
        item.size = [rs intForColumn:@"size"];
        item.format = [rs intForColumn:@"format"];
        item.property = [rs intForColumn:@"status"];
        item.mtime = [rs intForColumn:@"mtime"];
    }
    return item;
}

//判断serverpath值为cachePath的文件是否在在uploadfilelist数据库中
- (BOOL)isFileInUploadFileList:(NSString *)cachePath
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *sql = [NSString stringWithFormat:@"select * from uploadfilelist where accountid=%d and cachepath=\"%@\"",accountID,cachePath];
    FMResultSet *rt = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    return rt.next;
}

//判断当前是否有正在上传的文件
- (BOOL)hasUploadingFile
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *sql = [NSString stringWithFormat:@"select * from uploadfilelist where accountid=%d and status=%d",accountID,PCSFileUploadStatusUploading];
    FMResultSet *rt = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    return rt.next;
}

//更新文件的上传状态
- (BOOL)updateUploadFile:(NSString *)name status:(PCSFileUploadStatus)newStatus
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *sql = [NSString stringWithFormat:@"update uploadfilelist set status=%d, mtime=%d where cachepath=\"%@\" and accountid=%d",newStatus,(NSInteger)[[NSDate date] timeIntervalSince1970],name,accountID];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@" update upload file status failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}

/*
 cachepath由serverPath来保存
 status由property来保存
 */
- (BOOL)saveUploadFileToDB:(PCSFileInfoItem *)item
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *sql = [NSString stringWithFormat:@"replace into uploadfilelist(accountid,name,cachepath,size,status,format,mtime) values(%d,\"%@\",\"%@\",%d,%d,%d,%d)",accountID,PCS_FUNC_SENTENCED_EMPTY(item.name),PCS_FUNC_SENTENCED_EMPTY(item.serverPath),item.size,item.property,item.format,item.mtime];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@" save upload file info to DB failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}

- (NSDictionary *)getUploadFileFromDB
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSMutableDictionary  *fileDictionary = [NSMutableDictionary dictionary];
    NSMutableArray  *uploadingArray = [NSMutableArray array];
    NSMutableArray  *uploadSuccessArray = [NSMutableArray array];
    NSString    *sql = [NSString stringWithFormat:@"select id, name, cachepath,size,status,format,mtime from uploadfilelist where accountid=%d order by status desc,mtime desc",accountID];
    FMResultSet *rs = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    while ([rs next]){
        PCSFileInfoItem *item = [[PCSFileInfoItem alloc] init];
        item.fid = [rs intForColumn:@"id"];
        item.name = [rs stringForColumn:@"name"];
        item.serverPath = [rs stringForColumn:@"cachepath"];
        item.size = [rs intForColumn:@"size"];
        item.format = [rs intForColumn:@"format"];
        item.property = [rs intForColumn:@"status"];
        item.mtime = [rs intForColumn:@"mtime"];
        if (item.property == PCSFileUploadStatusFailed ||
            item.property == PCSFileUploadStatusUploading ||
            item.property == PCSFileUploadStatusWaiting) {
            [uploadingArray addObject:item];
        } else if (item.property == PCSFileUploadStatusSuccess) {
            [uploadSuccessArray addObject:item];
        }
        PCS_FUNC_SAFELY_RELEASE(item);
    }
    
    if (uploadingArray.count > 0) {
        NSString    *uploading = [NSString stringWithFormat:@"%d",PCSFileUploadStatusUploading];
        [fileDictionary setValue:uploadingArray forKey:uploading];
    }
    
    if (uploadSuccessArray.count > 0) {
        NSString    *uploadSuccess = [NSString stringWithFormat:@"%d",PCSFileUploadStatusSuccess];
        [fileDictionary setValue:uploadSuccessArray forKey:uploadSuccess];
    }
    
    return fileDictionary;
}

#pragma mark - filelist表数据库操作方法
//从filelist表中查找出offline状态的文件，按照修改时间降序排列
- (NSDictionary *)getOfflineFileFromDB
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSMutableDictionary *offlineDictionary = [NSMutableDictionary dictionary];
    NSMutableArray  *offliningArray = [NSMutableArray array];
    NSMutableArray  *offlinedArray = [NSMutableArray array];
    NSString    *sql = [NSString stringWithFormat:@"select * from filelist where accountid=%d and property in(%d,%d,%d,%d) order by property desc,mtime desc",accountID,PCSFilePropertyOffLineFailed,PCSFilePropertyOffLineSuccess,PCSFilePropertyOffLining,PCSFilePropertyOffLineWaiting];
    FMResultSet *rs = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    while ([rs next]){
        PCSFileInfoItem* item = [[PCSFileInfoItem alloc] init];
        item.fid = [rs intForColumn:@"id"];
        item.name = [rs stringForColumn:@"name"];
        item.serverPath = [rs stringForColumn:@"serverpath"];
        item.size = [rs intForColumn:@"size"];
        item.format = [rs intForColumn:@"format"];
        item.hasSubFolder = [rs boolForColumn:@"hassubfolder"];
        item.property = [rs intForColumn:@"property"];
        item.ctime = [rs intForColumn:@"ctime"];
        item.mtime = [rs intForColumn:@"mtime"];
        
        if (item.property == PCSFilePropertyOffLineFailed ||
            item.property == PCSFilePropertyOffLineWaiting ||
            item.property == PCSFilePropertyOffLining) {
            [offliningArray addObject:item];
        } else if (item.property == PCSFilePropertyOffLineSuccess) {
            [offlinedArray addObject:item];
        }
        PCS_FUNC_SAFELY_RELEASE(item);
        
        if (offliningArray.count > 0) {
            [offlineDictionary setValue:offliningArray forKey:[NSString stringWithFormat:@"%d",PCSFilePropertyOffLining]];
        }
        
        if (offlinedArray.count > 0) {
            [offlineDictionary setValue:offlinedArray forKey:[NSString stringWithFormat:@"%d",PCSFilePropertyOffLineSuccess]];
        }
    }
    return offlineDictionary;
}

//获得下一个要离线下载的文件在服务器上的地址
//选择最早入库的那个（先添加先下载）
//只找出一条
- (PCSFileInfoItem *)getNextOfflineFileItem
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    PCSFileInfoItem *item = nil;
    NSString    *sql = [NSString stringWithFormat:@"select id,serverpath from filelist where accountid=%d and property=%d order by mtime asc limit 1",accountID,PCSFilePropertyOffLineWaiting];
    FMResultSet *rs = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    while ([rs next]){
        item = [[[PCSFileInfoItem alloc] init] autorelease];
        item.fid = [rs intForColumn:@"id"];
        item.serverPath = [rs stringForColumn:@"serverpath"];
    }
    
    return item;
}

//判断当前是否有离线下载中的文件
- (BOOL)hasOffliningFile
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSString    *sql = [NSString stringWithFormat:@"select * from filelist where accountid=%d and property=%d",accountID,PCSFilePropertyOffLining];
    FMResultSet *rt = [[PCSDBOperater shareInstance].PCSDB executeQuery:sql];
    return rt.next;
}

//根据文件ID删除filelist表中的文件记录
- (BOOL)deleteFileFromFileList:(NSInteger)fileId
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
    NSString    *sql = [NSString stringWithFormat:@"update filelist set property=%d, mtime=%d where id=%d and accountid=%d",newProperty,(NSInteger)[[NSDate date] timeIntervalSince1970],fileId,accountID];
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@" update file property failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}

//从本地数据库获取当前目录下面的子文件（文件夹）用于我的文档界面展示
//获取属性为下载和离线两种类型的文件
//以是否为文件夹降序排序，名字升序排序
- (NSArray *)getSubFolderFileListFromDB:(NSString *)currentPath
{
    NSInteger accountID = [[NSUserDefaults standardUserDefaults] integerForKey:PCS_INTEGER_ACCOUNT_ID];
    NSMutableArray  *listArray = [NSMutableArray array];
    NSString    *sql = [NSString stringWithFormat:@"select id, name, serverpath,size,property,format,hassubfolder,ctime,mtime from filelist where parentPath=\"%@\" and accountid=%d and property not in (%d,%d) order by isdir desc,name asc",currentPath,accountID,PCSFilePropertyNull,PCSFilePropertyDelete];
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
    NSString    *sql = [NSString stringWithFormat:@"replace into filelist(accountid,name,serverpath,parentPath,thumbnailPath,size,property,format,hassubfolder,ctime,mtime,isdir) values(%d,\"%@\",\"%@\",\"%@\",\"%@\",%d,%d,%d,%d,%d,%d,%d)",accountID,PCS_FUNC_SENTENCED_EMPTY(item.name),PCS_FUNC_SENTENCED_EMPTY(item.serverPath),PCS_FUNC_SENTENCED_EMPTY(item.parentPath),PCS_FUNC_SENTENCED_EMPTY(item.thumbnailPath),item.size,item.property,item.format,item.hasSubFolder,item.ctime,item.mtime,isDir];
    PCSLog(@"sql:%@",sql);
    BOOL result = NO;
    result = [[PCSDBOperater shareInstance].PCSDB executeUpdate:sql];
    if (!result) {
        PCSLog(@" save file info to DB failed.%@",[[PCSDBOperater shareInstance].PCSDB lastErrorMessage]);
    }
    
    return result;
}

                                                                                                                 
#pragma mark -  accountlist表数据库操作方法
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
