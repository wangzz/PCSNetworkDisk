/*!
 @header BaiduPCSActionInfo.h
 @abstract the action info of response
 @author Baidu PCS SDK
 @version 1.00 2012/08/23 Creation (version info)
 */

#import <Foundation/Foundation.h>


/*!
 @class PCSSimplefiedResponse
 @abstract the simplified response, normal response
 */
@interface PCSSimplefiedResponse : NSObject

/*!
 @property errorCode
 @abstract error code
 */
@property(assign, nonatomic) int errorCode;

/*!
 @property message
 @abstract status message if failed
 */
@property(strong, nonatomic) NSString * message;

@end

/*!
 @class PCSCommonFileInfo
 @abstract the response of common file's info
 */
@interface PCSCommonFileInfo : NSObject

/*!
 @property path
 @abstract absolute path in PCS
 */
@property(strong, nonatomic) NSString *path;

/*!
 @property mTime
 @abstract modified time
 */
@property(assign, nonatomic) long mTime;

/*!
 @property cTime
 @abstract created time
 */
@property(assign, nonatomic) long cTime;

/*!
 @property blockList
 @abstract md5 value
 */
@property(strong, nonatomic)NSString *blockList;

/*!
 @property size
 @abstract file's size
 */
@property(assign, nonatomic) int size;

/*!
 @property isDir
 @abstract if the path is a dir
*/
@property(assign, nonatomic) BOOL isDir;

/*!
 @property hasSubFolder
 @abstract if the path has sub folder
*/
@property(assign, nonatomic) BOOL hasSubFolder;

@end

/*!
 @class PCSQuotaResponse
 @abstract the response of Quota info request
 */
@interface PCSQuotaResponse : NSObject

/*!
 @property status
 @abstract the status of response
 */
@property(strong, nonatomic) PCSSimplefiedResponse *status;

/*!
 @property total
 @abstract total space
 */
@property(assign, nonatomic) long total;

/*!
 @property used
 @abstract already used space
 */
@property(assign, nonatomic) long used;

@end

/*!
 @class PCSThumbnailResponse
 @abstract the response of Thumbnail request
 */
@interface  PCSThumbnailResponse  : NSObject

/*!
 @property status
 @abstract the status of response
 */
@property(strong, nonatomic) PCSSimplefiedResponse *status;

/*!
 @property data
 @abstract the thumbnail pic data
 */
@property(strong, nonatomic) NSData *data;

@end


/*!
 @class PCSThumbnailResponse
 @abstract the response of file about request
 */
@interface PCSFileInfoResponse : NSObject

/*!
 @property status
 @abstract the status of response
 */
@property(strong, nonatomic) PCSSimplefiedResponse *status;
    
/*!
 @property commonFileInfo
 @abstract the common file's info
 */
@property(strong, nonatomic) PCSCommonFileInfo *commonFileInfo;

@end


/*!
 @class PCSListInfoResponse
 @abstract  the response of list info
 */
@interface PCSListInfoResponse : NSObject

/*!
 @property the status of response
 @abstract the common file's info
 */
@property(strong, nonatomic) PCSSimplefiedResponse *status;

/*!
 @property list
 @abstract the array of PCSFileInfoResponse
 */
@property(strong, nonatomic) NSMutableArray *list;

@end

/*!
 @class PCSFileFromToInfo
 @abstract the action form of copy file and move file
 */
@interface  PCSFileFromToInfo : NSObject

    
/*!
 @property from
 @abstract the source location
 */
@property(strong, nonatomic) NSString *from;
    
/*!
 @property to
 @abstract the target location
 */
@property(strong, nonatomic) NSString *to;

@end

/*!
 @class PCSFileFromToResponse
 @abstract the response of copy/move request
 */
@interface PCSFileFromToResponse : NSObject

/*!
 @property status
 @abstract the status of response
 */
@property(strong, nonatomic) PCSSimplefiedResponse *status;

/*!
 @property list
 @abstract the array of PCSFileFromToInfo
 */
@property(strong, nonatomic)NSMutableArray *list;

@end

/*!
 @class PCSMetaResponse
 @abstract the response of meta request
 */
@interface PCSMetaResponse : NSObject

/*!
 @enum
 @abstract media type
 @constant Media_Unknown unknown file's type
 @constant Media_Audio audio file
 @constant Media_Video video file
 @constant Media_Image image file
 */
typedef enum tag_MediaType{
    Media_Unknown,
    
    Media_Audio,
    
    Media_Video,
    
    Media_Image,
    
}MediaType;

/*!
 @property status
 @abstract the status of response
 */
@property(strong, nonatomic) PCSSimplefiedResponse *status;

/*!
 @property type
 @abstract media type
 */
@property(assign, nonatomic) MediaType type;

/*!
 @property commonFileInfo
 @abstract the common file's info
 */
@property(strong, nonatomic) PCSCommonFileInfo *commonFileInfo;

@end

/*!
 @class PCSAudioMetaResponse
 @abstract the response of audio meta
 */
@interface PCSAudioMetaResponse : PCSMetaResponse

/*!
 @property hasthumbnail
 @abstract if the file has thumbnail
 */
@property(assign, nonatomic) BOOL hasThumbnail;

/*!
 @property artistName
 @abstract the artist's name
 */
@property(strong, nonatomic) NSString *artistName;

/*!
 @property albumTitle
 @abstract the album's title
 */
@property(strong, nonatomic) NSString *albumTitle;

/*!
 @property albumArtist
 @abstract the album's artist
 */
@property(strong, nonatomic) NSString *albumArtist;

/*!
 @property albumArt
 @abstract the album's art
 */
@property(strong, nonatomic) NSString *albumArt;

/*!
 @property composer
 @abstract the composer
 */
@property(strong, nonatomic) NSString *composer;

/*!
 @property trackTitle
 @abstract the track's title
 */
@property(strong, nonatomic) NSString *trackTitle;

/*!
 @property trackNumber
 @abstract the track's number
 */
@property(assign, nonatomic) long trackNumber;

/*!
 @property duration
 @abstract the duration
 */
@property(assign, nonatomic) long duration;

/*!
 @property compilation
 @abstract the compilation
 */
@property(strong, nonatomic) NSString *compilation;

/*!
 @property date
 @abstract the date
 */
@property(strong, nonatomic) NSString *date;

/*!
 @property genre
 @abstract the genre
 */
@property(strong, nonatomic) NSString *genre;

@end

/*!
 @class PCSVideoMetaResponse
 @abstract the response of video meta
 */
@interface PCSVideoMetaResponse : PCSMetaResponse

/*!
 @property hasThumbnail
 @abstract if the file has thumbnail
 */
@property(assign, nonatomic) BOOL hasThumbnail;

/*!
 @property resolution
 @abstract the resolution of the video
 */
@property(strong, nonatomic) NSString *resolution;

/*!
 @property duration
 @abstract the duration of the video
 */
@property(assign, nonatomic) long duration;

/*!
 @property dateTaken
 @abstract the taken date of the video
 */
@property(assign, nonatomic) long dateTaken;

/*!
 @property category
 @abstract the category of the video
 */
@property(strong, nonatomic) NSString *category;

@end

/*!
 @class PCSImageMetaResponse
 @abstract the response of image meta
 */
@interface PCSImageMetaResponse : PCSMetaResponse

/*!
 @property hasThumbnail
 @abstract if the image has thumbnail
 */
@property(assign, nonatomic) BOOL hasThumbnail;

/*!
 @property dateTaken
 @abstract the taken date of the image
 */
@property(assign, nonatomic) long dateTaken;

/*!
 @property resolution
 @abstract the resolution of the image
 */
@property(strong, nonatomic) NSString *resolution;

/*!
 @property latitude
 @abstract the latitude when the image is taken
 */
@property(assign, nonatomic) double latitude;

/*!
 @property longtitude
 @abstract the longtitude when the image is taken
 */
@property(assign, nonatomic) double longtitude;

@end

/*!
 @class PCSDifferEntryInfo
 @abstract the entry of response of diff request
 */
@interface PCSDifferEntryInfo : NSObject

/*!
 @property commonFileInfo
 @abstract the common file's info
 */
@property(strong, nonatomic) PCSCommonFileInfo *commonFileInfo;

/*!
 @property isDeleted
 @abstract if the file is deleted
 */
@property(assign, nonatomic) BOOL isDeleted;

@end

/*!
 @class PCSDiffResponse
 @abstract the response of diff request
 */
@interface PCSDiffResponse : NSObject

/*!
 @property status
 @abstract the status of the response
 */
@property(strong, nonatomic) PCSSimplefiedResponse *status;

/*!
 @property entries
 @abstract the array of PCSDifferEntryInfo
 */
@property(strong, nonatomic) NSMutableArray *entries;

/*!
 @property hasMore
 @abstract if the diff info has more
 */
@property(assign, nonatomic) BOOL hasMore;

/*!
 @property isReseted
 @abstract if the diff is reset
 */
@property(assign, nonatomic) BOOL isReseted;

/*!
 @property cursor
 @abstract the cursor
 */
@property(strong, nonatomic) NSString *cursor;

@end

/*!
 @class
 @abstract the response of Add Cloud Download Task request
 */
@interface PCSAddCloudDownloadTaskResponse : NSObject

/*!
 @property
 @abstract the status of the response
 */
@property (strong, nonatomic) PCSSimplefiedResponse *status;
/*!
 @property
 @abstract the task id
 */
@property (strong, nonatomic) NSString * taskId;

@end

/*!
 @class
 @abstract the info of task process
 */
@interface PCSCloudDownloadTaskProcessInfo : NSObject

/*!
 @property
 @abstract the task id
 */
@property (strong, nonatomic) NSString *taskId;
/*!
 @property
 @abstract the status of task process
 */
@property (assign, nonatomic) int status;
/*!
 @property
 @abstract the size of the file
 */
@property (assign, nonatomic) long long int fileSize;
/*!
 @property
 @abstract the finished size of the file
 */
@property (assign, nonatomic) long long int finishedSize;
/*!
 @property
 @abstract the creation time of the task
 */
@property (assign, nonatomic) long long int createTime;
/*!
 @property
 @abstract the start time of the task
 */
@property (assign, nonatomic) long long int startTime;
/*!
 @property
 @abstract the finish time of the task
 */
@property (assign, nonatomic) long long int finishTime;
/*!
 @property
 @abstract the result
 */
@property (assign, nonatomic) int result;

@end

/*!
 @class
 @abstract the response of Query Cloud Download Task request
 */
@interface PCSCloudDownloadTaskProcessResponse : NSObject

/*!
 @property
 @abstract the status of the response
 */
@property (strong, nonatomic) PCSSimplefiedResponse *status;
/*!
 @property
 @abstract the task list. 
 */
@property (strong, nonatomic) NSMutableArray *taskList;

@end

/*!
 @class
 @abstract the info of the Cloud Download Task
 */
@interface PCSCloudDownloadTaskInfo : NSObject
/*!
 @property
 @abstract the task id
 */
@property (strong, nonatomic)NSString *taskId;
/*!
 @property
 @abstract the status of the task
 */
@property (assign, nonatomic)int status;
/*!
 @property
 @abstract the result
 */
@property (assign, nonatomic)int result;
/*!
 @property
 @abstract the source url to download
 */
@property (strong, nonatomic)NSString *sourceUrl;
/*!
 @property
 @abstract the target path on pcs
 */
@property (strong, nonatomic)NSString *targetPath;
/*!
 @property
 @abstract the rate limit
 */
@property (assign, nonatomic)int rateLimit;
/*!
 @property
 @abstract the time out of the task
 */
@property (assign, nonatomic)int timeout;
/*!
 @property
 @abstract the call back
 */
@property (strong, nonatomic)NSString *callback;
/*!
 @property
 @abstract the creation time of the task
 */
@property (assign, nonatomic)long long int createTime;

@end
/*!
 @class
 @abstract the response of Cloud Download Task Request
 */
@interface PCSCloudDownloadTaskResponse : NSObject

/*!
 @property
 @abstract the status of the response
 */
@property (strong, nonatomic) PCSSimplefiedResponse *status;
/*!
 @property
 @abstract the num of tasks
 */
@property (assign, nonatomic) int total;
/*!
 @property
 @abstract the list of task info
 */
@property (strong, nonatomic) NSMutableArray *taskList;

@end