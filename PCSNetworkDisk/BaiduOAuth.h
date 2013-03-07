/*!
 @header BaiduOAuth.h
 @abstract Use to get Access Token
 @author Baidu PCS SDK
 @version 1.00 2012/08/23 Creation (version info)
 */

#import <UIKit/UIKit.h>


/*!
 @class BaiduOAuthResponse
 @abstract The Response when request Baidu OAuth2 Server.
 */
@interface BaiduOAuthResponse : NSObject

/*!
 @property accessToken
 @abstract The token which used to request PCS API.
 */
@property (strong, nonatomic) NSString *accessToken;

/*!
 @property refreshToken
 @abstract The refresh token which used to refresh the access token
 */
@property (strong, nonatomic) NSString *refreshToken;

/*!
 @property userName
 @abstract the login user's name
 */
@property (strong, nonatomic) NSString *userName;

/*!
 @property expiresIn
 @abstract the access token 's expires in
 */
@property (strong, nonatomic) NSString *expiresIn;

@end


/*!
 @protocal
 @abstract the call back protocal which used to do something when finish oauth
 */
@protocol BaiduOAuthDelegate <NSObject>

/*!
 @method
 @abstract called when oauth succeeds
 @param response the struct of the response
 */
-(void)onSuccess:(BaiduOAuthResponse*)response;

/*!
 @method
 @abstract called when fials to get access token
 @param error the error message
 */
-(void)onError:(NSString*)error;

/*!
 @method
 @abstract called when the action is canceled
 */
-(void)onCancel;

@end

/*!
 @class
 @abstract Baidu OAuth class
 */
@interface BaiduOAuth : UIViewController<UIWebViewDelegate>

/*!
 @method
 @abstract manual expires in the access token
 @param token the access token to expire in
 */
-(BOOL)logout:(NSString*)token;


/*!
 @property mpWebView
 @abstract the webview used to display oauth web interface
 */
@property (strong, nonatomic) UIWebView *mpWebView;

/*!
 @property delegate
 @abstract the delegate used to callback
 */
@property (unsafe_unretained, nonatomic) id<BaiduOAuthDelegate> delegate;

/*!
 @property apiKey
 @abstract the app api key (client id)
 */
@property (unsafe_unretained, nonatomic) NSString* apiKey;

@end
