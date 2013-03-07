/*!
 @header BaiduPCSClient.h
 @abstract the main class to call pcs api
 @author Baidu PCS SDK
 @version 1.00 2012/08/23 Creation (version info)
 */

#import <Foundation/Foundation.h>
#import "BaiduPCSActionInfo.h"
#import "BaiduPCSStatusListener.h"


/*!
 @class BaiduPCSClient
 @abstract the base class to call pcs api
 */
@interface BaiduPCSClient : NSObject

/*!
 @method
 @abstract init
 */
-(BaiduPCSClient*)init;

/*!
 @method
 @abstract init with access token
 @param token the access token
 */
-(BaiduPCSClient*)initWithAccessToken:(NSString*)token;

/*!
 @property accessToken
 @abstract the access token
 */
@property (strong, nonatomic) NSString *accessToken;

/*!
 @method
 @abstract the method to call quota api
 */
-(PCSQuotaResponse*)quotaInfo;

/*!
 @method
 @abstract the method to upload data without listener
 @param source the source to upload
 @param target the target location to upload
 */
-(PCSFileInfoResponse*)uploadData:(NSData*)source:(NSString*)target;

/*!
 @method
 @abstract the method to upload data with listener
 @param source the source to upload
 @param target the target location to upload
 @param listener the listener to observe the action
 */
-(PCSFileInfoResponse*)uploadData:(NSData*)source:(NSString*)target:(id<BaiduPCSStatusListener>)listener;

/*!
 @method
 @abstract the method to delete a single file
 @param file the file's path
 */
-(PCSSimplefiedResponse*)deleteFile:(NSString*)file;

/*!
 @method
 @abstract the method to delete files
 @param file the array of files' path
 */
-(PCSSimplefiedResponse*)deleteFiles:(NSArray*)files;

/*!
 @method
 @abstract the method to download a file without listener
 @param source the path of the file
 @param target the data which will store the download file
 */
-(PCSSimplefiedResponse*)downloadFile:(NSString*)source:(NSData**)target;

/*!
 @method
 @abstract the method to download a file with listener
 @param source the path of the file
 @param target the data which will store the download file
 @param listener the listener to observe the action
 */
-(PCSSimplefiedResponse*)downloadFile:(NSString*)source:(NSData**)target:(id<BaiduPCSStatusListener>)listener;

/*!
 @method
 @abstract Stream Download a file from PCS to local path without listener. You should apply for special permission to use this method
 @param source the path of the file
 @param target the data which will store the download file
    */
-(PCSSimplefiedResponse*)downloadFileFromStream:(NSString*)source:(NSData**)target;

/*!
 @method
 @abstract Stream Download a file from PCS to local path with listener. You should apply for special permission to use this method
 @param source the path of the file
 @param target the data which will store the download file
 @param listener the listener to observe the action
    */
-(PCSSimplefiedResponse*)downloadFileFromStream:(NSString*)source:(NSData**)target:(id<BaiduPCSStatusListener>)listener;

/*!
 @method
 @abstract  Download  a 480P mp4 file. from PCS to local path without listener. You should apply for special permission to use this method
 @param source the path of the file
 @param target the data which will store the download file
    */
-(PCSSimplefiedResponse*)downloadFileAsMP4480P:(NSString*)source:(NSData**)target;

/*!
 @method
 @abstract  Download  a 480P mp4 file with listener. from PCS to local path without listener. You should apply for special permission to use this method
 @param source the path of the file
 @param target the data which will store the download file
 @param listener the listener to observe the action
 */
-(PCSSimplefiedResponse*)downloadFileAsMP4480P:(NSString*)source:(NSData**)target:(id<BaiduPCSStatusListener>)listener;

/*!
 @method
 @abstract  Download  a 360P mp4 file without listener. from PCS to local path without listener. You should apply for special permission to use this method
 @param source the path of the file
 @param target the data which will store the download file
 */
-(PCSSimplefiedResponse*)downloadFileAsMP4360P:(NSString*)source:(NSData**)target;

/*!
 @method
 @abstract  Download  a 360P mp4 file with listener. from PCS to local path without listener. You should apply for special permission to use this method
 @param source the path of the file
 @param target the data which will store the download file
 @param listener the listener to observe the action
 */
-(PCSSimplefiedResponse*)downloadFileAsMP4360P:(NSString*)source:(NSData**)target:(id<BaiduPCSStatusListener>)listener;

/*!
 @method
 @abstract  Download a file with codec type without listener. You should apply for special permission to use this method
 @param source the path of the file
 @param target the data which will store the download file
 @param type should be MP4_480P or MP4_360P
 */
-(PCSSimplefiedResponse*)downloadFileAsSpecificCodecType:(NSString*)source:(NSData**)target:(NSString*)type;

/*!
 @method
 @abstract  Download a file with codec type with listener. You should apply for special permission to use this method
 @param source the path of the file
 @param target the data which will store the download file
 @param type should be MP4_480P or MP4_360P
 @param listener the listener to observe the action
 */
-(PCSSimplefiedResponse*)downloadFileAsSpecificCodecType:(NSString*)source:(NSData**)target:(NSString*)type:(id<BaiduPCSStatusListener>)listener;

/*!
 @method
 @abstract the method to create folder
 @param path the path of the file
*/
-(PCSFileInfoResponse*)makeDir:(NSString*)path;

/*!
 @method
 @abstract the method to get the meta
 @param file the path of the file
*/
-(PCSMetaResponse*)meta:(NSString*)file;

/*!
 @method
 @abstract the method to get the list of files
 @param path the path
 @param by order by what. time or name or size.
 @param order asc or desc
*/
-(PCSListInfoResponse*)list:(NSString*)path:(NSString*)by:(NSString*)order;

/*!
 @method
 @abstract the method to move a singe file
 @param from the path of the source file
 @param to the pathe of the target location
*/
-(PCSFileFromToResponse*)move:(NSString*)from:(NSString*)to;


/*!
 @method
 @abstract the method to move files
 @param files the array of the PCSFileFromToInfo
*/
-(PCSFileFromToResponse*)move:(NSArray*)files;

/*!
 @method
 @abstract the method to copy a singe file
 @param from the path of the source file
 @param to the pathe of the target location
 */
-(PCSFileFromToResponse*)copy:(NSString*)from:(NSString*)to;


/*!
 @method
 @abstract the method to copy files
 @param files the array of the PCSFileFromToInfo
*/
-(PCSFileFromToResponse*)copy:(NSArray*)files;

/*!
 @method
 @abstract the method to search
 @param path the path which will search
 @param key the key word to search
*/
-(PCSListInfoResponse*)search:(NSString*)path:(NSString*)key;

/*!
 @method
 @abstract the method to search
 @param path the path which will search
 @param key the key word to search
 @param recursive if or not recur
*/
-(PCSListInfoResponse*)search:(NSString*)path:(NSString*)key:(BOOL)recursive;

/*!
 @method
 @abstract Get the list of all the image files by stream. You should apply for special permission to use this method
 */
-(PCSListInfoResponse*)imageStream;

/*!
 @method
 @abstract Get the list of all the video files by stream. You should apply for special permission to use this method
 */
-(PCSListInfoResponse*)videoStream;

/*!
 @method
 @abstract Get the list of all the audio files by stream. You should apply for special permission to use this method
 */
-(PCSListInfoResponse*)audioStream;

/*!
 @method
 @abstract Get the list of all the documents files by stream. You should apply for special permission to use this method
 */
-(PCSListInfoResponse*)docStream;

/*!
 @method
 @abstract Get the list of all the specialized files by stream.You should apply for special permission to use this method
 @param type should be "image", "audio", "video" or "doc"
 */
-(PCSListInfoResponse*)streamWithSpecificMediaType:(NSString*)type;

/*!
 @method
 @abstract Get the list of the image files by stream with num limit.You should apply for special permission to use this method
 @param start The start num of the file to list.if start < 0, start from 0
 @param end The end num of the file to list.if end < 0, there is no end
 */
-(PCSListInfoResponse*)imageStreamWithLimit:(int)start:(int)end;

/*!
 @method
 @abstract Get the list of the video files by stream with num limit.You should apply for special permission to use this method
 @param start The start num of the file to list.if start < 0, start from 0
 @param end The end num of the file to list.if end < 0, there is no end
 */
-(PCSListInfoResponse*)videoStreamWithLimit:(int)start:(int)end;

/*!
 @method
 @abstract Get the list of the audio files by stream with num limit.You should apply for special permission to use this method
 @param start The start num of the file to list.if start < 0, start from 0
 @param end The end num of the file to list.if end < 0, there is no end
 */
-(PCSListInfoResponse*)audioStreamWithLimit:(int)start:(int)end;

/*!
 @method
 @abstract Get the list of the documents files by stream with num limit.You should apply for special permission to use this method
 @param start The start num of the file to list.if start < 0, start from 0
 @param end The end num of the file to list.if end < 0, there is no end
 */
-(PCSListInfoResponse*)docStreamWithLimit:(int)start:(int)end;

/*!
 @method
 @abstract  Get the list of the specialized files by stream with num limit.You should apply for special permission to use this method
 @param type should be "image", "audio", "video" or "doc"
 @param start The start num of the file to list.if start < 0, start from 0
 @param end The end num of the file to list.if end < 0, there is no end
 */
-(PCSListInfoResponse*)streamWithSpecificMediaType:(NSString*)type:(int)start:(int)end;

/*!
 @method
 @abstract Generate a thumbnail of a image.
 @param path the path of image which will generate a thumbnail
 @param quality the quality of thumbnail,(0,100]
 @param width the width of the thumbnail, maxmum is 850
 @param height the height of thumbnail, maxnum is 580
 */
-(PCSThumbnailResponse*)thumbnail:(NSString*)path:(int)quality:(int)width:(int)height;

/*!
 @method
 @abstract cursor set to 'null'.Diff provides a way to keep up with the latest changes of user files.In the initial call, this method should be called.There is 10 seconds delay, if a file was just modified in the server, the update info is returned only if call this API after 10 seconds
 */
-(PCSDiffResponse*)diff;

/*!
 @method
 @abstract Diff provides a way to keep up with the latest changes of user files.
 @param cursor It is used to keep track of your current state.In the initial call, set cursor=null in the request.You can get the next cursor from the response and set it in the next request.
 */
-(PCSDiffResponse*)diff:(NSString*)cursor;

/*!
 @method
 @abstract add a cloud download task
 @discussion
 @param sourceUrl the source which want to download
 @param target the path which used to save the source
 @result the response of the request
 */
-(PCSAddCloudDownloadTaskResponse *)addCloudDownloadTask:(NSString *)sourceUrl
                                                        :(NSString *)target;
/*!
 @method
 @abstract query the progress of a task
 @discussion
 @param taskId the task which want to query
 @result the response of the request
 */
-(PCSCloudDownloadTaskProcessResponse *)queryTaskProgress:(NSString *)taskId;

/*!
 @method
 @abstract query the progress of sevral tasks
 @discussion
 @param taskIds the array of task ids to query
 @result the respnse of the request
 */
-(PCSCloudDownloadTaskProcessResponse *)queryTasksProgress:(NSArray *)taskIds;

/*!
 @method
 @abstract query the info of a task
 @discussion
 @param taskId the task which want to query
 @result the response of the request
 */
-(PCSCloudDownloadTaskResponse *)queryTaskInfo:(NSString *)taskId;

/*!
 @method
 @abstract query the info of sevral tasks
 @discussion
 @param taskIds the array of task ids to query
 @result the response of the request
 */
-(PCSCloudDownloadTaskResponse *)queryTasksInfo:(NSArray *)taskIds;

/*!
 @method
 @abstract get the task list
 @discussion
 @result the response of the request
 */
-(PCSCloudDownloadTaskResponse *)getTaskList;

/*!
 @method
 @abstract get the task list
 @discussion
 @param start the start index
 @param limit the num of task in return list
 @result the response of the request
 */
-(PCSCloudDownloadTaskResponse *)getTaskList:(int)start
                                            :(int)limit;

/*!
 @method
 @abstract cancel a cloud download task
 @discussion
 @param taskId the id of a task which want to cancel
 @result the response of the request
 */
-(PCSSimplefiedResponse *)cancelTask:(NSString *)taskId;

/*!
 @method
 @abstract rapid upload
 @discussion if the source a user (or someone esle) has been uploaded, you will not need to upload again. and your target path will point to the source on server.
 @param source the data of the file which want to upload
 @param the target on server to save the source
 @result the response of the request
 */
-(PCSFileInfoResponse *)rapidUpload:(NSData *)source
                                   :(NSString *)target;
@end
