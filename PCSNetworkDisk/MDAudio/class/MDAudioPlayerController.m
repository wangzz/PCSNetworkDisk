//
//  AudioPlayer.m
//  MobileTheatre
//
//  Created by Matt Donnelly on 27/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "MDAudioPlayerController.h"
#import "MDAudioFile.h"
#import "MDAudioPlayerTableViewCell.h"
#import "MBProgressHUD.h"


@interface MDAudioPlayerController ()
@property (nonatomic,retain) MBProgressHUD  *HUD;
@property (nonatomic,retain) NSString   *serverPath;
@property (nonatomic,assign) PCSFolderType  folderType;
- (UIImage *)reflectedImage:(UIButton *)fromImage withHeight:(NSUInteger)height;
@end

@implementation MDAudioPlayerController

static const CGFloat kDefaultReflectionFraction = 0.65;
static const CGFloat kDefaultReflectionOpacity = 0.40;

@synthesize soundFiles;
@synthesize soundFilesPath;

@synthesize player;
@synthesize gradientLayer;

@synthesize playButton;
@synthesize pauseButton;
@synthesize nextButton;
@synthesize previousButton;
@synthesize toggleButton;
@synthesize repeatButton;
@synthesize shuffleButton;

@synthesize currentTime;
@synthesize duration;
@synthesize indexLabel;
@synthesize titleLabel;
@synthesize artistLabel;
@synthesize albumLabel;

@synthesize volumeSlider;
@synthesize progressSlider;

@synthesize songTableView;

@synthesize artworkView;
@synthesize reflectionView;
@synthesize containerView;
@synthesize overlayView;

@synthesize updateTimer;

@synthesize interrupted;
@synthesize repeatAll;
@synthesize repeatOne;
@synthesize shuffle;

@synthesize HUD;
@synthesize serverPath;
@synthesize folderType;

void interruptionListenerCallback (void *userData, UInt32 interruptionState)
{
	MDAudioPlayerController *vc = (MDAudioPlayerController *)userData;
	if (interruptionState == kAudioSessionBeginInterruption)
		vc.interrupted = YES;
	else if (interruptionState == kAudioSessionEndInterruption)
		vc.interrupted = NO;
}

-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
	NSString *current = [NSString stringWithFormat:@"%d:%02d", (int)p.currentTime / 60, (int)p.currentTime % 60, nil];
	NSString *dur = [NSString stringWithFormat:@"-%d:%02d", (int)((int)(p.duration - p.currentTime)) / 60, (int)((int)(p.duration - p.currentTime)) % 60, nil];
	duration.text = dur;
	currentTime.text = current;
	progressSlider.value = p.currentTime;
}

- (void)updateCurrentTime
{
	[self updateCurrentTimeForPlayer:self.player];
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
	titleLabel.text = [[soundFiles objectAtIndex:selectedIndex] title];
	artistLabel.text = [[soundFiles objectAtIndex:selectedIndex] artist];
	albumLabel.text = [[soundFiles objectAtIndex:selectedIndex] album];
	
	[self updateCurrentTimeForPlayer:p];
	
	if (updateTimer) 
		[updateTimer invalidate];
	
	if (p.playing)
	{
		[playButton removeFromSuperview];
		[self.view addSubview:pauseButton];
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
	}
	else
	{
		[pauseButton removeFromSuperview];
		[self.view addSubview:playButton];
		updateTimer = nil;
	}
	
	if (![songTableView superview]) 
	{
        UIImage *artImage = [[soundFiles objectAtIndex:selectedIndex] coverImage];
        if (artImage == nil) {
            if (iPhone5) {
                artImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNoArtwork5" ofType:@"png"]];
                self.artworkView.backgroundColor = [UIColor lightGrayColor];
            } else {
                artImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNoArtwork" ofType:@"png"]];
            }
        }

		[artworkView setImage:artImage forState:UIControlStateNormal];
		reflectionView.image = [self reflectedImage:artworkView withHeight:artworkView.bounds.size.height * kDefaultReflectionFraction];
	}
	
	if (repeatOne || repeatAll || shuffle)
		nextButton.enabled = YES;
	else	
		nextButton.enabled = [self canGoToNextTrack];
	previousButton.enabled = [self canGoToPreviousTrack];
}

-(void)updateViewForPlayerInfo:(AVAudioPlayer*)p
{
	duration.text = [NSString stringWithFormat:@"%d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
	indexLabel.text = [NSString stringWithFormat:@"%d of %d", (selectedIndex + 1), [soundFiles count]];
	progressSlider.maximumValue = p.duration;
	if ([[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"])
		volumeSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"];
	else
		volumeSlider.value = p.volume;
}

- (MDAudioPlayerController *)initWithSoundFiles:(NSMutableArray *)songs atPath:(NSString *)path andSelectedIndex:(int)index
{
	if (self = [super init]) 
	{
		self.soundFiles = songs;
		self.soundFilesPath = path;
		selectedIndex = index;
				
		NSError *error = nil;
				
		self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
		[player setNumberOfLoops:0];
		player.delegate = self;
				
		[self updateViewForPlayerInfo:player];
		[self updateViewForPlayerState:player];
		
		if (error)
			NSLog(@"%@", error);
	}
	
	return self;
}

#pragma mark - PCSNetDisk
- (MDAudioPlayerController *)initWithServerPath:(NSString *)path
                                     folderType:(PCSFolderType)type
{
    if (self = [super init]){
        serverPath = path;
        folderType = type;
    }
    return self;
}

- (void)hideFileDownloadingView
{
    PCSLog(@"dissmiss downloading notice view.");
//    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.playButton.enabled = YES;
    if (HUD != nil) {
        [HUD hide:YES];
        PCS_FUNC_SAFELY_RELEASE(HUD);
    }
}

- (void)showFileDownloadFailedView
{
    PCSLog(@"file download failed.");
//    self.navigationItem.leftBarButtonItem.enabled = YES;
    if (HUD != nil) {
        [HUD hide:YES];
        PCS_FUNC_SAFELY_RELEASE(HUD);
    }
}

- (void)showFileBeginDownloadView
{
    PCSLog(@"file download begin.");
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeDeterminate;
	HUD.dimBackground = YES;
	HUD.labelText = @"下载中...";
    [HUD show:YES];
//    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.playButton.enabled = NO;
}

- (void)initMusicPlayerWithPath:(NSString *)path
{
    NSMutableArray *songArray = [[NSMutableArray alloc] init];
    MDAudioFile *audioFile = [[MDAudioFile alloc] initWithPath:[NSURL fileURLWithPath:path]];
    [songArray addObject:audioFile];
    self.soundFiles = songArray;
    [songArray release];
    [audioFile release];
    
    self.soundFilesPath = path;
    
    NSError *error = nil;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
    [player setNumberOfLoops:0];
    player.delegate = self;
    
    [self updateViewForPlayerInfo:player];
    [self updateViewForPlayerState:player];
    
    if (error)
        NSLog(@"%@", error);
}

- (void)downloadFileFromServer:(NSString *)path folderType:(PCSFolderType)type
{
    [self showFileBeginDownloadView];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *data = nil;
        PCSSimplefiedResponse *response = [PCS_APP_DELEGATE.pcsClient downloadFile:path:&data:self];
        dispatch_sync(dispatch_get_main_queue(), ^{
            //让文件下载中界面消失
            [self hideFileDownloadingView];
            if (response.errorCode == 0) {
                PCSLog(@"download file :%@ from server success.",path);
                BOOL result = NO;
                switch (folderType) {
                    case PCSFolderTypeNetDisk:
                        result = [[PCSDBOperater shareInstance] saveFileToNetCache:data name:path];
                        break;
                    case PCSFolderTypeUpload:
                        result = [[PCSDBOperater shareInstance] saveFileToUploadCache:data name:path];
                        break;
                    case PCSFolderTypeOffline:
                        result = [[PCSDBOperater shareInstance] saveFileToOfflineCache:data name:path];
                        break;
                    default:
                        break;
                }
                
                if (result) {
                    NSString    *absolutePath = [[PCSDBOperater shareInstance] absolutePathBy:path
                                                                                   folderType:type];
                    [self initMusicPlayerWithPath:absolutePath];
                }
                
            } else {
                //显示文件下载失败界面
                [self showFileDownloadFailedView];
                PCSLog(@"download file :%@ from server failed.",path);
            }
        });
    });
}

#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes :(long)total
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        //主线程中更新进度条的显示
        float progress = (float)bytes/(float)total;
        HUD.progress = progress;
        PCSLog(@"current download progress:%f",progress);
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

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	
	updateTimer = nil;
	
//	UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
//	navigationBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//	navigationBar.barStyle = UIBarStyleBlackOpaque;
//	[self.view addSubview:navigationBar];
//	
//	UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
//	[navigationBar pushNavigationItem:navItem animated:NO];
//	
//	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAudioPlayer)];
    UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismissAudioPlayer)];
    self.navigationItem.leftBarButtonItem = returnButton;
	
	self.toggleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	[toggleButton setImage:[UIImage imageNamed:@"AudioPlayerAlbumInfo.png"] forState:UIControlStateNormal];
	[toggleButton addTarget:self action:@selector(showSongFiles) forControlEvents:UIControlEventTouchUpInside];
	
//	UIBarButtonItem *songsListBarButton = [[UIBarButtonItem alloc] initWithCustomView:toggleButton];
//	
//	navItem.leftBarButtonItem = doneButton;
//	[doneButton release];
//	doneButton = nil;
//	
//	navItem.rightBarButtonItem = songsListBarButton;
//	[songsListBarButton release];
//	songsListBarButton = nil;
//	
//	[navItem release];
//	navItem = nil;
	
	AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, self);
	AudioSessionSetActive(true);
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);	
	
	MDAudioFile *selectedSong = [self.soundFiles objectAtIndex:selectedIndex];
	
//	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 195, 12)];
//	titleLabel.text = [selectedSong title];
//	titleLabel.font = [UIFont boldSystemFontOfSize:12];
//	titleLabel.backgroundColor = [UIColor clearColor];
//	titleLabel.textColor = [UIColor whiteColor];
//	titleLabel.shadowColor = [UIColor blackColor];
//	titleLabel.shadowOffset = CGSizeMake(0, -1);
//	titleLabel.textAlignment = UITextAlignmentCenter;
//	titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//	[self.view addSubview:titleLabel];
	
//	self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 2, 195, 12)];
//	artistLabel.text = [selectedSong artist];
//	artistLabel.font = [UIFont boldSystemFontOfSize:12];
//	artistLabel.backgroundColor = [UIColor clearColor];
//	artistLabel.textColor = [UIColor lightGrayColor];
//	artistLabel.shadowColor = [UIColor blackColor];
//	artistLabel.shadowOffset = CGSizeMake(0, -1);
//	artistLabel.textAlignment = UITextAlignmentCenter;
//	artistLabel.lineBreakMode = UILineBreakModeTailTruncation;
//	[self.view addSubview:artistLabel];
	
//	self.albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 27, 195, 12)];
//	albumLabel.text = [selectedSong album];
//	albumLabel.backgroundColor = [UIColor clearColor];
//	albumLabel.font = [UIFont boldSystemFontOfSize:12];
//	albumLabel.textColor = [UIColor lightGrayColor];
//	albumLabel.shadowColor = [UIColor blackColor];
//	albumLabel.shadowOffset = CGSizeMake(0, -1);
//	albumLabel.textAlignment = UITextAlignmentCenter;
//	albumLabel.lineBreakMode = UILineBreakModeTailTruncation;
//	[self.view addSubview:albumLabel];

//	[navigationBar release];
//	navigationBar = nil;
	
	duration.adjustsFontSizeToFitWidth = YES;
	currentTime.adjustsFontSizeToFitWidth = YES;
	progressSlider.minimumValue = 0.0;	
	
    
    CGRect  containerFrame;
    if (iPhone5) {
        containerFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } else {
        containerFrame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44);
    }
	self.containerView = [[UIView alloc] initWithFrame:containerFrame];
	[self.view addSubview:containerView];
	
    CGRect  artworkViewFrame;
    if (iPhone5) {
        artworkViewFrame = CGRectMake(0, 44, 320, 320+88);
    } else {
        artworkViewFrame = CGRectMake(0, 0, 320, 320);
    }
	self.artworkView = [[UIButton alloc] initWithFrame:artworkViewFrame];
    UIImage *artImage = [selectedSong coverImage];
    if (artImage == nil) {
        if (iPhone5) {
            artImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNoArtwork5" ofType:@"png"]];
            if (artImage == nil) {
                self.artworkView.backgroundColor = [UIColor lightGrayColor];
            }
        } else {
            artImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNoArtwork" ofType:@"png"]];
        }
    }
        
	[artworkView setImage:artImage forState:UIControlStateNormal];
	[artworkView addTarget:self action:@selector(showOverlayView) forControlEvents:UIControlEventTouchUpInside];
	artworkView.showsTouchWhenHighlighted = NO;
	artworkView.adjustsImageWhenHighlighted = NO;
	[containerView addSubview:artworkView];
	
    CGRect  reflectionRect = CGRectMake(0, iPhone5?472:320, 320, 96);
	self.reflectionView = [[UIImageView alloc] initWithFrame:reflectionRect];
	reflectionView.image = [self reflectedImage:artworkView withHeight:artworkView.bounds.size.height * kDefaultReflectionFraction];
	reflectionView.alpha = kDefaultReflectionFraction;
	[self.containerView addSubview:reflectionView];
	
    CGRect  rect = CGRectMake(0, 0, self.view.bounds.size.width, 368+(iPhone5?88:0));
	self.songTableView = [[UITableView alloc] initWithFrame:rect];
	self.songTableView.delegate = self;
	self.songTableView.dataSource = self;
	self.songTableView.separatorColor = [UIColor colorWithRed:0.986 green:0.933 blue:0.994 alpha:0.10];
	self.songTableView.backgroundColor = [UIColor clearColor];
	self.songTableView.contentInset = UIEdgeInsetsMake(0, 0, 37, 0); 
	self.songTableView.showsVerticalScrollIndicator = NO;
	
	gradientLayer = [[CAGradientLayer alloc] init];
	gradientLayer.frame = CGRectMake(0.0, self.containerView.bounds.size.height - 96, self.containerView.bounds.size.width, 48);
	gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, nil];
	gradientLayer.zPosition = INT_MAX;
	
	/*! HACKY WAY OF REMOVING EXTRA SEPERATORS */
	
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
	v.backgroundColor = [UIColor clearColor];
	[self.songTableView setTableFooterView:v];
	[v release];
	v = nil;

	UIImageView *buttonBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44 + 320 + (iPhone5?88:0), self.view.bounds.size.width, 96)];
	buttonBackground.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerBarBackground" ofType:@"png"]] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	[self.view addSubview:buttonBackground];
	[buttonBackground release];
	buttonBackground  = nil;
		
	self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(144, 370 + (iPhone5?88:0), 40, 40)];
	[playButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPlay" ofType:@"png"]] forState:UIControlStateNormal];
	[playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
	playButton.showsTouchWhenHighlighted = YES;
	[self.view addSubview:playButton];
							  
	self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 370 + (iPhone5?88:0), 40, 40)];
	[pauseButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPause" ofType:@"png"]] forState:UIControlStateNormal];
	[pauseButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
	pauseButton.showsTouchWhenHighlighted = YES;
	
	self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 370 + (iPhone5?88:0), 40, 40)];
	[nextButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNextTrack" ofType:@"png"]] 
				forState:UIControlStateNormal];
	[nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
	nextButton.showsTouchWhenHighlighted = YES;
	nextButton.enabled = [self canGoToNextTrack];
	[self.view addSubview:nextButton];
	
	self.previousButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 370 + (iPhone5?88:0), 40, 40)];
	[previousButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPrevTrack" ofType:@"png"]] 
				forState:UIControlStateNormal];
	[previousButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
	previousButton.showsTouchWhenHighlighted = YES;
	previousButton.enabled = [self canGoToPreviousTrack];
	[self.view addSubview:previousButton];
	
	self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(25, 420 + (iPhone5?88:0), 270, 9)];
	[volumeSlider setThumbImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerVolumeKnob" ofType:@"png"]]
														forState:UIControlStateNormal];
	[volumeSlider setMinimumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberLeft" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
					   forState:UIControlStateNormal];
	[volumeSlider setMaximumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberRight" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
							  forState:UIControlStateNormal];
	[volumeSlider addTarget:self action:@selector(volumeSliderMoved:) forControlEvents:UIControlEventValueChanged];
	
	if ([[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"])
		volumeSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"];
	else
		volumeSlider.value = player.volume;
		
	[self.view addSubview:volumeSlider];
	
    
    NSString    *absolutePath = [[PCSDBOperater shareInstance] absolutePathBy:serverPath
                                                                   folderType:folderType];
    BOOL    fileExit = NO;
    fileExit = [[NSFileManager defaultManager] fileExistsAtPath:absolutePath];
    if (fileExit) {
        //文件存在，直接播放
        [self initMusicPlayerWithPath:absolutePath];
    } else {
        //文件不存在，下载后播放
        [self downloadFileFromServer:serverPath folderType:folderType];
    }

    
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)setNavBarAppearance:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self setNavBarAppearance:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[player play];
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)dismissAudioPlayer
{
	[player stop];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)showSongFiles
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:5];
	
	[UIView setAnimationTransition:([self.songTableView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.toggleButton cache:YES];
	if ([songTableView superview])
		[self.toggleButton setImage:[UIImage imageNamed:@"AudioPlayerAlbumInfo.png"] forState:UIControlStateNormal];
	else
		[self.toggleButton setImage:self.artworkView.imageView.image forState:UIControlStateNormal];
	
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:5];
	
	[UIView setAnimationTransition:([self.songTableView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.containerView cache:YES];
	if ([songTableView superview])
	{
		[self.songTableView removeFromSuperview];
        UIImage *artImage = [[soundFiles objectAtIndex:selectedIndex] coverImage];
        if (artImage == nil) {
            if (iPhone5) {
                artImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNoArtwork5" ofType:@"png"]];
                self.artworkView.backgroundColor = [UIColor lightGrayColor];
            } else {
                artImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNoArtwork" ofType:@"png"]];
            }
        }
		[self.artworkView setImage:artImage forState:UIControlStateNormal];
		[self.containerView addSubview:reflectionView];
		
		[gradientLayer removeFromSuperlayer];
	}
	else
	{
		[self.artworkView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerTableBackground" ofType:@"png"]] forState:UIControlStateNormal];
		[self.reflectionView removeFromSuperview];
		[self.overlayView removeFromSuperview];
		[self.containerView addSubview:songTableView];
		
		[[self.containerView layer] insertSublayer:gradientLayer atIndex:0];
	}
	
	[UIView commitAnimations];
}

- (void)showOverlayView
{	
	if (overlayView == nil) 
	{		
		self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, iPhone5?44:0, self.view.bounds.size.width, 76)];
		overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
		overlayView.opaque = NO;
		
		self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(54, 20, 212, 23)];
		[progressSlider setThumbImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberKnob" ofType:@"png"]]
						   forState:UIControlStateNormal];
		[progressSlider setMinimumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberLeft" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
								  forState:UIControlStateNormal];
		[progressSlider setMaximumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberRight" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
								  forState:UIControlStateNormal];
		[progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
		progressSlider.maximumValue = player.duration;
		progressSlider.minimumValue = 0.0;	
		[overlayView addSubview:progressSlider];
		
		self.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 2, 64, 21)];
		indexLabel.font = [UIFont boldSystemFontOfSize:12];
		indexLabel.shadowOffset = CGSizeMake(0, -1);
		indexLabel.shadowColor = [UIColor blackColor];
		indexLabel.backgroundColor = [UIColor clearColor];
		indexLabel.textColor = [UIColor whiteColor];
		indexLabel.textAlignment = UITextAlignmentCenter;
		[overlayView addSubview:indexLabel];
		
		self.duration = [[UILabel alloc] initWithFrame:CGRectMake(272, 21, 48, 21)];
		duration.font = [UIFont boldSystemFontOfSize:14];
		duration.shadowOffset = CGSizeMake(0, -1);
		duration.shadowColor = [UIColor blackColor];
		duration.backgroundColor = [UIColor clearColor];
		duration.textColor = [UIColor whiteColor];
		[overlayView addSubview:duration];
		
		self.currentTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 48, 21)];
		currentTime.font = [UIFont boldSystemFontOfSize:14];
		currentTime.shadowOffset = CGSizeMake(0, -1);
		currentTime.shadowColor = [UIColor blackColor];
		currentTime.backgroundColor = [UIColor clearColor];
		currentTime.textColor = [UIColor whiteColor];
		currentTime.textAlignment = UITextAlignmentRight;
		[overlayView addSubview:currentTime];
		
		duration.adjustsFontSizeToFitWidth = YES;
		currentTime.adjustsFontSizeToFitWidth = YES;
		
		self.repeatButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 45, 32, 28)];
		[repeatButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerRepeatOff" ofType:@"png"]] 
					  forState:UIControlStateNormal];
		[repeatButton addTarget:self action:@selector(toggleRepeat) forControlEvents:UIControlEventTouchUpInside];
		[overlayView addSubview:repeatButton];
		
		self.shuffleButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 45, 32, 28)];
		[shuffleButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerShuffleOff" ofType:@"png"]] 
					  forState:UIControlStateNormal];
		[shuffleButton addTarget:self action:@selector(toggleShuffle) forControlEvents:UIControlEventTouchUpInside];
		[overlayView addSubview:shuffleButton];
	}
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	
	if ([overlayView superview])
		[overlayView removeFromSuperview];
	else
		[containerView addSubview:overlayView];
	
	[UIView commitAnimations];
}

- (void)toggleShuffle
{
	if (shuffle)
	{
		shuffle = NO;
		[shuffleButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerShuffleOff" ofType:@"png"]] forState:UIControlStateNormal];
	}
	else
	{
		shuffle = YES;
		[shuffleButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerShuffleOn" ofType:@"png"]] forState:UIControlStateNormal];
	}
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)toggleRepeat
{
	if (repeatOne)
	{
		[repeatButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerRepeatOff" ofType:@"png"]] 
					  forState:UIControlStateNormal];
		repeatOne = NO;
		repeatAll = NO;
	}
	else if (repeatAll)
	{
		[repeatButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerRepeatOneOn" ofType:@"png"]] 
					  forState:UIControlStateNormal];
		repeatOne = YES;
		repeatAll = NO;
	}
	else
	{
		[repeatButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerRepeatOn" ofType:@"png"]] 
					  forState:UIControlStateNormal];
		repeatOne = NO;
		repeatAll = YES;
	}
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (BOOL)canGoToNextTrack
{
	if ([self.soundFiles count] == 0 ||
        selectedIndex + 1 == [self.soundFiles count])
		return NO;
	else
		return YES;
}

- (BOOL)canGoToPreviousTrack
{
	if (selectedIndex == 0)
		return NO;
	else
		return YES;
}

-(void)play
{
	if (self.player.playing == YES) 
	{
		[self.player pause];
	}
	else
	{
		if ([self.player play]) 
		{
			
		}
		else
		{
			NSLog(@"Could not play %@\n", self.player.url);
		}
	}
	
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)previous
{
	NSUInteger newIndex = selectedIndex - 1;
	selectedIndex = newIndex;
		
	NSError *error = nil;
	AVAudioPlayer *newAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
	
	if (error)
		NSLog(@"%@", error);
	
	[player stop];
	self.player = newAudioPlayer;
	[newAudioPlayer release];
	
	player.delegate = self;
	player.volume = volumeSlider.value;
	[player prepareToPlay];
	[player setNumberOfLoops:0];
	[player play];
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];	
}

- (void)next
{
	NSUInteger newIndex;
	
	if (shuffle)
	{
		newIndex = rand() % [soundFiles count];
	}
	else if (repeatOne)
	{
		newIndex = selectedIndex;
	}
	else if (repeatAll)
	{
		if (selectedIndex + 1 == [self.soundFiles count])
			newIndex = 0;
		else
			newIndex = selectedIndex + 1;
	}
	else
	{
		newIndex = selectedIndex + 1;
	}
	
	selectedIndex = newIndex;
		
	NSError *error = nil;
	AVAudioPlayer *newAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
		
	if (error)
		NSLog(@"%@", error);
	
	[player stop];
	self.player = newAudioPlayer;
	[newAudioPlayer release];
	
	player.delegate = self;
	player.volume = volumeSlider.value;
	[player prepareToPlay];
	[player setNumberOfLoops:0];
	[player play];
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)volumeSliderMoved:(UISlider *)sender
{
	player.volume = [sender value];
	[[NSUserDefaults standardUserDefaults] setFloat:[sender value] forKey:@"PlayerVolume"];
}

- (IBAction)progressSliderMoved:(UISlider *)sender
{
	player.currentTime = sender.value;
	[self updateCurrentTimeForPlayer:player];
}


#pragma mark -
#pragma mark AVAudioPlayer delegate


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
	
	if ([self canGoToNextTrack])
		 [self next];
	else if (interrupted)
		[self.player play];
	else
		[self.player stop];
		 
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error);
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Decode Error" 
														message:[NSString stringWithFormat:@"Unable to decode audio file with error: %@", [error localizedDescription]] 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	// perform any interruption handling here
	printf("(apbi) Interruption Detected\n");
	[[NSUserDefaults standardUserDefaults] setFloat:[self.player currentTime] forKey:@"Interruption"];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	// resume playback at the end of the interruption
	printf("(apei) Interruption ended\n");
	[self.player play];
	
	// remove the interruption key. it won't be needed
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Interruption"];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[player release];
	player = nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{	
    return [soundFiles count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    MDAudioPlayerTableViewCell *cell = (MDAudioPlayerTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[MDAudioPlayerTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.title = [[soundFiles objectAtIndex:indexPath.row] title];
	cell.number = [NSString stringWithFormat:@"%d.", (indexPath.row + 1)];
	cell.duration = [[soundFiles objectAtIndex:indexPath.row] durationInMinutes];

	cell.isEven = indexPath.row % 2;
	
	if (selectedIndex == indexPath.row)
		cell.isSelectedIndex = YES;
	else
		cell.isSelectedIndex = NO;
	
	return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	selectedIndex = indexPath.row;
	
	for (MDAudioPlayerTableViewCell *cell in [aTableView visibleCells])
	{
		cell.isSelectedIndex = NO;
	}
	
	MDAudioPlayerTableViewCell *cell = (MDAudioPlayerTableViewCell *)[aTableView cellForRowAtIndexPath:indexPath];
	cell.isSelectedIndex = YES;
	
	NSError *error = nil;
	AVAudioPlayer *newAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
	
	if (error)
		NSLog(@"%@", error);
	
	[player stop];
	self.player = newAudioPlayer;
	[newAudioPlayer release];
	
	player.delegate = self;
	player.volume = volumeSlider.value;
	[player prepareToPlay];
	[player setNumberOfLoops:0];
	[player play];
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (BOOL)tableView:(UITableView *)table canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return NO;
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}


#pragma mark - Image Reflection

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);

	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
	
    return bitmapContext;
}

- (UIImage *)reflectedImage:(UIButton *)fromImage withHeight:(NSUInteger)height
{
    if (height == 0)
		return nil;
    
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
	
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.bounds.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);

	CGContextTranslateCTM(mainViewContentContext, 0.0, height);
	CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
	
	CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.imageView.image.CGImage);
	
	CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	CGImageRelease(reflectionImage);
	
	return theImage;
}

- (void)viewDidUnload
{
	self.reflectionView = nil;
}

- (void)dealloc
{
	[soundFiles release], soundFiles = nil;
	[soundFilesPath release], soundFiles = nil;
	[player release], player = nil;
	[gradientLayer release], gradientLayer = nil;
	[playButton release], playButton = nil;
	[pauseButton release], pauseButton = nil;
	[nextButton release], nextButton = nil;
	[previousButton release], previousButton = nil;
	[toggleButton release], toggleButton = nil;
	[repeatButton release], repeatButton = nil;
	[shuffleButton release], shuffleButton = nil;
	[currentTime release], currentTime = nil;
	[duration release], duration = nil;
	[indexLabel release], indexLabel = nil;
	[titleLabel release], titleLabel = nil;
	[artistLabel release], artistLabel = nil;
	[albumLabel release], albumLabel = nil;
	[volumeSlider release], volumeSlider = nil;
	[progressSlider release], progressSlider = nil;
	[songTableView release], songTableView = nil;
	[artworkView release], artworkView = nil;
	[reflectionView release], reflectionView = nil;
	[containerView release], containerView = nil;
	[overlayView release], overlayView = nil;
	[updateTimer invalidate], updateTimer = nil;
	[super dealloc];
}


@end
