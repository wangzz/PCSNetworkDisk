//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

// Private
@interface MWPhoto () {

    // Image Sources
    NSString *_photoPath;
    NSString *_photoServerPath;
    NSURL *_photoURL;

    // Image
    UIImage *_underlyingImage;

    // Other
    NSString *_caption;
    BOOL _loadingInProgress;
        
}

// Properties
@property (nonatomic, retain) UIImage *underlyingImage;

// Methods
- (void)imageDidFinishLoadingSoDecompress;
- (void)imageLoadingComplete;

@end

// MWPhoto
@implementation MWPhoto

// Properties
@synthesize underlyingImage = _underlyingImage, 
caption = _caption,
photoServerPath = _photoServerPath,
folderType = _folderType;


#pragma mark Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[[MWPhoto alloc] initWithImage:image] autorelease];
}

+ (MWPhoto *)photoWithFilePath:(NSString *)path {
	return [[[MWPhoto alloc] initWithFilePath:path] autorelease];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
	return [[[MWPhoto alloc] initWithURL:url] autorelease];
}

+ (MWPhoto *)photoWithServerPath:(NSString *)path {
	return [[[MWPhoto alloc] initWithServerPath:path] autorelease];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		self.underlyingImage = image;
	}
	return self;
}

- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoPath = [path copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_photoURL = [url copy];
	}
	return self;
}

- (id)initWithServerPath:(NSString *)path {
	if ((self = [super init])) {
		_photoServerPath = [path copy];
	}
	return self;
}

- (void)dealloc {
    [_caption release];
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
	[_photoPath release];
	[_photoURL release];
    [_photoServerPath release];
	[_underlyingImage release];
	[super dealloc];
}

#pragma mark MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    _loadingInProgress = YES;
    if (self.underlyingImage) {
        // Image already loaded
        [self imageLoadingComplete];
    } else {
        if (_photoPath) {
            // Load async from file
            [self performSelectorInBackground:@selector(loadImageFromFileAsync) withObject:nil];
        } else if (_photoServerPath) {
            //从PCS服务器加载图片资源
            NSData  *cachedData = nil;
            switch (_folderType) {
                case PCSFolderTypeNetDisk:
                    cachedData = [[PCSDBOperater shareInstance] getFileFromNetCacheBy:_photoServerPath];
                    break;
                case PCSFolderTypeUpload:
                    cachedData = [[PCSDBOperater shareInstance] getFileFromUploadCacheBy:_photoServerPath];
                    break;
                case PCSFolderTypeTypeOffline:
                    cachedData = [[PCSDBOperater shareInstance] getFileFromOfflineCacheBy:_photoServerPath];
                    break;
                default:
                    break;
            }
            UIImage *cachedImage = [UIImage imageWithData:cachedData];
            if (cachedImage) {
                // Use the cached image immediatly
                self.underlyingImage = cachedImage;
                [self imageDidFinishLoadingSoDecompress];
            } else {
                //从服务器下载文件
                [self downloadFileFromServer:_photoServerPath];
            }
        } else if (_photoURL) {
            // Load async from web (using SDWebImage)
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            UIImage *cachedImage = [manager imageWithURL:_photoURL];
            if (cachedImage) {
                // Use the cached image immediatly
                self.underlyingImage = cachedImage;
                [self imageDidFinishLoadingSoDecompress];
            } else {
                // Start an async download
                [manager downloadWithURL:_photoURL delegate:self];
            }
        } else {
            // Failed - no source
            self.underlyingImage = nil;
            [self imageLoadingComplete];
        }
    }
}

- (void)downloadFileFromServer:(NSString *)serverPath
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *data = nil;
        PCSSimplefiedResponse *response = [PCS_APP_DELEGATE.pcsClient downloadFile:serverPath:&data:self];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (response.errorCode == 0) {
                PCSLog(@"download file :%@ from server success.",serverPath);
                
                switch (_folderType) {
                    case PCSFolderTypeNetDisk:
                        [[PCSDBOperater shareInstance] saveFileToNetCache:data name:serverPath];
                        break;
                    case PCSFolderTypeUpload:
                        [[PCSDBOperater shareInstance] saveFileToUploadCache:data name:serverPath];
                        break;
                    case PCSFolderTypeTypeOffline:
                        [[PCSDBOperater shareInstance] saveFileToOfflineCache:data name:serverPath];
                        break;
                    default:
                        break;
                }
                self.underlyingImage = [UIImage imageWithData:data];
                [self imageDidFinishLoadingSoDecompress];
            } else {
                self.underlyingImage = nil;
                [self imageDidFinishLoadingSoDecompress];
                PCSLog(@"download file :%@ from server failed.",serverPath);
            }
        });
    });
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
	if (self.underlyingImage && (_photoPath || _photoURL || _photoServerPath)) {
		self.underlyingImage = nil;
	}
}

#pragma mark - Async Loading

// Called in background
// Load image in background from local file
- (void)loadImageFromFileAsync {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:_photoPath options:NSDataReadingUncached error:&error];
        if (!error) {
            self.underlyingImage = [[[UIImage alloc] initWithData:data] autorelease];
        } else {
            self.underlyingImage = nil;
            MWLog(@"Photo from file error: %@", error);
        }
    } @catch (NSException *exception) {
    } @finally {
        [self performSelectorOnMainThread:@selector(imageDidFinishLoadingSoDecompress) withObject:nil waitUntilDone:NO];
        [pool drain];
    }
}

// Called on main
- (void)imageDidFinishLoadingSoDecompress {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (self.underlyingImage) {
        // Decode image async to avoid lagging when UIKit lazy loads
        [[SDWebImageDecoder sharedImageDecoder] decodeImage:self.underlyingImage withDelegate:self userInfo:nil];
    } else {
        // Failed
        [self imageLoadingComplete];
    }
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

#pragma mark - SDWebImage Delegate

// Called on main
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    self.underlyingImage = image;
    [self imageDidFinishLoadingSoDecompress];
}

// Called on main
- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    self.underlyingImage = nil;
    MWLog(@"SDWebImage failed to download image: %@", error);
    [self imageDidFinishLoadingSoDecompress];
}

// Called on main
- (void)imageDecoder:(SDWebImageDecoder *)decoder didFinishDecodingImage:(UIImage *)image userInfo:(NSDictionary *)userInfo {
    // Finished compression so we're complete
    self.underlyingImage = image;
    [self imageLoadingComplete];
}

#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes :(long)total
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
        
    });
}

-(long)progressInterval
{
    return 1.0f;
}

-(BOOL)toContinue
{
    return YES;
}

@end
