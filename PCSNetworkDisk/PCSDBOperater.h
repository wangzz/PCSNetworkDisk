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
 CREATE TABLE "uploadfilelist" ("id" integer primary key  autoincrement  not null ,accountid integer , "name" text COLLATE NOCASE, "serverpath" text COLLATE NOCASE, "cachepath" text COLLATE NOCASE,"size" integer, "status" integer, "format" integer,"mtime" datetime, timestamp TimeStamp NOT NULL DEFAULT (datetime('now','localtime')));
 CREATE UNIQUE INDEX uk_filelist on filelist(accountid, name ,parentpath);
 CREATE UNIQUE INDEX uk_uploadfilelist on uploadfilelist(accountid, name ,serverpath);
 */

@class PCSFileInfoItem;
@class BaiduOAuthResponse;
@interface PCSDBOperater : NSObject

@property(nonatomic,retain) FMDatabase  *PCSDB;

#pragma mark - 类方法
/*****************************类方法*****************************/
/*!
 @method
 @abstract  单例的方式生成一个PCSDBOperater对象
 @return    PCSDBOperater类型对象的指针，获取结果
 */
+ (PCSDBOperater *)shareInstance;

#pragma mark - 本地文件操作方法

/*!
 @method
 @abstract  根据文件在服务端的路径，和文件夹类型，获取文件所在的绝对路径
 @param     path    NSString类型的指针，指向文件在服务端的路径
 @param     folderType  PCSFilderType型，文件所在的文件夹类型
 @return    NSString型，文件在本地的绝对路径
 */
- (NSString *)absolutePathBy:(NSString *)path folderType:(PCSFolderType)folderType;

/*****************************本地文件操作*****************************/
/*!
 @method
 @abstract  删除本地Document目录下面子目录uploadCache目录下的指定名称的文件
 @param     name    NSString类型的指针，指向要删除的文件名称
 @return    BOOL型，表示删除结果
 */
- (BOOL)deleteFileFromUploadCache:(NSString *)name;

/*!
 @method
 @abstract  删除本地Document目录下面子目录offlineCache目录下的指定名称的文件
 @param     name    NSString类型的指针，指向要删除的文件名称
 @return    BOOL型，表示删除结果
 */
- (BOOL)deleteFileFromOfflineCache:(NSString *)name;

/*!
 @method
 @abstract  删除本地Document目录下面子目录netCache目录下的指定名称的文件
 @param     name    NSString类型的指针，指向要删除的文件名称
 @return    BOOL型，表示删除结果
 */
- (BOOL)deleteFileFromNetCache:(NSString *)name;

/*!
 @method
 @abstract  获取Document目录下面子目录uploadCache目录下的指定名称的文件二进制数据
 @param     name    想要获取数据的文件名称
 @return    NSData型指针，指向获取到的文件数据
 */
- (NSData *)getFileFromUploadCacheBy:(NSString *)name;

/*!
 @method
 @abstract  获取Document目录下面子目录offlineCache目录下的指定名称的文件二进制数据
 @param     name    想要获取数据的文件名称
 @return    NSData型指针，指向获取到的文件数据
 */
- (NSData *)getFileFromOfflineCacheBy:(NSString *)name;

/*!
 @method
 @abstract  获取Document目录下面子目录netCache目录下的指定名称的文件二进制数据
 @param     name    想要获取数据的文件名称
 @return    NSData型指针，指向获取到的文件数据
 */
- (NSData *)getFileFromNetCacheBy:(NSString *)name;

/*!
 @method
 @abstract  将二进制文件数据以特定名称保存到Document目录下面子目录uploadCache目录下
 @param     value   NSData类型的指针，指向要保存的文件
 @param     name    NSString类型的指针，指向要保存的文件名
 @return    BOOL型，表示保存结果
 */
- (BOOL)saveFileToUploadCache:(NSData *)value name:(NSString *)name;

/*!
 @method
 @abstract  将二进制文件数据以特定名称保存到Document目录下面子目录offlineCache目录下
 @param     value   NSData类型的指针，指向要保存的文件
 @param     name    NSString类型的指针，指向要保存的文件名
 @return    BOOL型，表示保存结果
 */
- (BOOL)saveFileToOfflineCache:(NSData *)value name:(NSString *)name;

/*!
 @method
 @abstract  将二进制文件数据以特定名称保存到Document目录下面子目录netCache目录下
 @param     value   NSData类型的指针，指向要保存的文件
 @param     name    NSString类型的指针，指向要保存的文件名
 @return    BOOL型，表示保存结果
 */
- (BOOL)saveFileToNetCache:(NSData *)value name:(NSString *)name;

/*!
 @method
 @abstract  获取指定名称的文件格式
 @param     name    NSString类型指针，指向要获取类型的文件名称
 @return    PCSFileFormat型，表示获取到的文件类型
 */
- (PCSFileFormat)getFileTypeWith:(NSString *)name;

/*!
 @method
 @abstract  删除指定目录的文件或文件夹
 @param     filePath    NSString类型指针，指向要删除的文件或文件夹目录
 @return    BOOL型，表示删除结果
 */
- (BOOL)clearDataAtPath:(NSString *)filePath;

/*!
 @method
 @abstract  获取指定文件或文件夹的大小
 @param     filePath    NSString类型指针，指向要获取大小的文件或文件夹目录
 @return    long long型，表示文件或文件夹大小
 */
- (long long)folderSizeAtPath:(NSString *)filePath;

/*!
@method
@abstract  将指定大小的字节数转换成以B、KB、MB或GB为单位的字符串
@param     sizeBytes    long类型数据，表示转换单位前的字节数
@return    NSString类型指针，指向转换单位后的字符串
*/
- (NSString *)getFormatSizeString:(float)sizeBytes;

#pragma mark - accountlist表数据库操作方法
/*****************************accountlist表数据库操作方法*****************************/

/*!
 @method
 @abstract  保存登陆返回的数据到accountlist表中
 @param     response    BaiduOAuthResponse类型的指针，登陆时从服务端返回的登陆结果
 @return    BOOL型，保存数据库的结果
 */
- (BOOL)saveLoginInfoToDB:(BaiduOAuthResponse *)response;

#pragma mark - uploadfilelist表数据库操作方法
/*****************************uploadfilelist操作方法*****************************/

/*!
 @method    
 @abstract  判断值为serverpath的文件是否在在uploadfilelist数据库中
 @param     serverpath NSString类型指针，表示文件服务端地址
 @return    BOOL型，查询结果
 */
- (BOOL)isFileInUploadFileList:(NSString *)serverPath;
/*!
 @method    
 @abstract  从uploadfilelist表中删除一条上传的历史记录，该上传文件在cache中对应的文件数据
            不用删除，因为上传时保存的cache文件名跟filelist表中对应的cache文件名是一样的
 @param     fid NSInteger型，表示要删除的文件ID
 @return    BOOL型，表示删除结果
 */
- (BOOL)deleteFromUploadFileList:(NSInteger)fid;

/*!
 @method    
 @abstract  获取下一条要上传的文件信息。通常用于一个文件上传成功以后，检查是否有处于等待
            上传状态的传真,获得下一个要上传的文件信息,选择最早入库的那个（先添加先上传）且
            只查找出一条
 @return    PCSFileInfoItem类型的指针，指向下一条上传的文件信息
 @
 */
- (PCSFileInfoItem *)getNextUploadFileInfo;

/*!
 @method
 @abstract  判断是否有处于正在上传中的文件
 @return    BOOL型，YES表示有上传中的文件，NO表示没有上传中的文件
 */
- (BOOL)hasUploadingFile;

/*!
 @method
 @abstract  更新uploadfilelist表中上传文件的上传状态
 @param     serverPath    NSString类型指针，文件的服务端地址
 @param     newStatus   PCSFileUploadStatus类型，新的文件状态
 @return    BOOL型，YES表示状态更新成功，NO表示状态更新失败
 */
- (BOOL)updateUploadFile:(NSString *)serverPath status:(PCSFileUploadStatus)newStatus;

/*!
 @method
 @abstract  更新uploadfilelist表中上传文件的大小
 @param     serverPath    NSString类型指针，文件的服务端地址
 @param     size   NSInteger类型，表示文件大小
 @return    BOOL型，YES表示状态更新成功，NO表示状态更新失败
 */
- (BOOL)updateUploadFile:(NSString *)serverPath size:(NSInteger)size;

/*!
 @method
 @abstract  将一条新的文件记录保存到uploadfilelist表中
 @param     item    PCSFileInfoItem类型的指针，指向要入库的文件信息
 @return    BOOL型，表示入库结果
 */
- (BOOL)saveUploadFileToDB:(PCSFileInfoItem *)item;

/*!
 @method
 @abstract  获取uploadfilelist表中的文件记录信息，用于“上传“界面的数据展示
 @return    NSDictionary类型的指针，指向可以用于”上传“界面展示的数据结构
 */
- (NSDictionary *)getUploadFileFromDB;

#pragma mark - filelist表数据库操作方法
/*****************************filelist表数据库操作方法*****************************/

/*!
 @method
 @abstract  将filelist表中属性为PCSFilePropertyOffLineSuccess状态的文件置为
            PCSFilePropertyDownLoad，用于清空离线文件本地缓存
 @return    BOOL型，表示执行结果
 */
- (BOOL)resetOfflineSuccessFileStatus;

/*!
 @method
 @abstract  从filelist表中查找出offline状态的文件，按照修改时间降序排列
 @return    NSDictionary型指针，指向离线状态数组格式化的PCSFileInfoItem类型文件集合
 */
- (NSDictionary *)getOfflineFileFromDB;

/*!
 @method
 @abstract  获取下一个要离线下载的文件信息
 @return    PCSFileInfoItem型指针，指向下一个要离线下载的文件信息
 */
- (PCSFileInfoItem *)getNextOfflineFileItem;

/*!
 @method
 @abstract  判断当前是否有离线下载中的文件
 @return    BOOL型，表示是否有离线下载中的文件
 */
- (BOOL)hasOffliningFile;

/*!
 @method
 @abstract  保存从服务端下载的文件信息到filelist表
 @param     item    PCSFileInfoItem类型的指针，指向一条文件记录
 @return    BOOL型，表示保存数据库结果
 */
- (BOOL)saveFileInfoItemToDB:(PCSFileInfoItem *)item;

/*!
 @method
 @abstract  从本地数据库获取当前目录下面的文件夹，用于文件移动和文件上传时选择目的文件夹
            按照文件夹的名字升序排序
 @param     currentPath NSString类型的指针，要获取文件信息的目录
 @return    NSArray型指针，为PCSFileInfoItem类型对象的集合，用于“我的云盘”界面展示
 */
- (NSArray *)getSubFolderListFromDB:(NSString *)currentPath;

/*!
 @method
 @abstract  从本地数据库获取当前目录下面的子文件（文件夹）用于我的文档界面展示
            获取属性为下载和离线两种类型的文件
            以是否为文件夹降序排序，名字升序排序
 @param     currentPath NSString类型的指针，要获取文件信息的目录
 @return    NSArray型指针，为PCSFileInfoItem类型对象的集合，用于“我的云盘”界面展示
 */
- (NSArray *)getSubFolderFileListFromDB:(NSString *)currentPath;

/*!
 @method
 @abstract  更新filelist表中的文件属性信息
 @param     fileId  NSInteger型，表示要更新的文件ID
 @param     newProperty PCSFileProperty型，表示新的文件属性
 @return    BOOL型，表示更新结果
 */
- (BOOL)updateFile:(NSInteger)fileId property:(PCSFileProperty)newProperty;

/*!
 @method
 @abstract  从filelist表中删除指定的文件数据
 @param     fileId  NSInteger型，表示要删除的文件ID
 @return    BOOL型，表示删除结果
 */
- (BOOL)deleteFileFromFileList:(NSInteger)fileId;

/*!
 @method
 @abstract  删除指定目录下面的所有文件（或者文件夹，如果是文件夹，则删除子文件夹下的内容，以此类推）
 @param     parentPath  NSString类型的指针，指向将被删除子目录信息的目录名称
 @return    BOOL型，表示删除结果
 */
- (BOOL)deleteFileFromFileListByParentpath:(NSString *)parentPath;

/*!
 @method
 @abstract  删除文件在本地的全部信息，包括filelist表，uploadfilelist表，cache文件夹中
 的信息。一个文件记录被删除后，该文件在本地的全部信息都将被删除；一个文件夹被删
 除后，该文件夹，以及该文件夹目录下面的子文件或文件夹在本地的所有信息都将被清除
 @param     item    PCSFileInfoItem类型的对象，描述要删除的文件信息
 @return    BOOL类型，表示删除结果
 */
- (BOOL)deleteAllFileInfoFromLocal:(PCSFileInfoItem *)item;

- (BOOL)updateUploadFailFileStatus;
- (BOOL)updateOfflineFailFileStatus;

@end
