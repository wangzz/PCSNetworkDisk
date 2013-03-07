/*!
 @header BaiduPCSStatusListener.h
 @abstract upload and download status listener
 @author Baidu PCS SDK
 @version 1.00 2012/08/23 Creation (version info)
 */

#import <Foundation/Foundation.h>

/*!
 @protocal
 @abstract the call back protocal which used to observe at the upload and the download action
 */
@protocol BaiduPCSStatusListener <NSObject>

/*!
 @method
 @abstract the upload or download progress
 @param bytes the bytes that already uploaded or downloaded
 @param total the total bytes
 */
-(void)onProgress:(long)bytes:(long)total;

/*!
 @method
 @abstract the progress interval
 */
-(long)progressInterval;

/*!
 @method
 @abstract should stop or continue
 */
-(BOOL)toContinue;

@end
