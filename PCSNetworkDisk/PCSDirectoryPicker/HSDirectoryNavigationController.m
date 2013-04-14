//
//  HSDirectoryNavigationController.m
//  HSShtFaxClient
//
//  Created by zhongzhou wang on 13-2-20.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "HSDirectoryNavigationController.h"
#import "HSDirectoryViewController.h"

@implementation HSDirectoryNavigationController
@synthesize rootDirectory;
@synthesize delegate;

- (id)initWithRootDirectory:(NSString *)directory
{
    self = [super init];
    
    if (self) {        
        rootDirectory = [directory copy];
    }
    
    return self;
}

- (void)dealloc
{
    [rootDirectory release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the inital directory list.
    HSDirectoryViewController *directoryList = [[HSDirectoryViewController alloc] initWithDirectoryAtPath:rootDirectory];
    [self pushViewController:directoryList animated:NO];
    [directoryList release];
    
    UIImageView *tooBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 436+(iPhone5?88:0), 320, 44)];
    tooBarImageView.image = [UIImage imageNamed: @"file_picker_toolbar"];
    tooBarImageView.userInteractionEnabled = YES;
    
    UIImage *normalImage = [[UIImage imageNamed:@"file_picker_toolbar_button"] stretchableImageWithLeftCapWidth:4
                                                                                        topCapHeight:14];
    UIImage *highlishtlightedImage = [[UIImage imageNamed:@"file_picker_toolbar_buttoned"] stretchableImageWithLeftCapWidth:4
                                                                                                    topCapHeight:14];
    UIButton    *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, 5.5, 47, 33)];
    [cancelBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [cancelBtn setBackgroundImage:highlishtlightedImage forState:UIControlStateHighlighted];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self
                  action:@selector(cancelButtonTapped)
        forControlEvents:UIControlEventTouchUpInside];
    [tooBarImageView addSubview:cancelBtn];
    PCS_FUNC_SAFELY_RELEASE(cancelBtn);
    
    UIButton    *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(259, 5.5f, 47, 33)];
    [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:highlishtlightedImage forState:UIControlStateHighlighted];
    [doneBtn addTarget:self
                action:@selector(doneButtonTapped)
      forControlEvents:UIControlEventTouchUpInside];
    [tooBarImageView addSubview:doneBtn];
    PCS_FUNC_SAFELY_RELEASE(doneBtn);
    
    [self.view addSubview:tooBarImageView];
    PCS_FUNC_SAFELY_RELEASE(tooBarImageView);
}

#pragma mark - Navigation Button Action
- (void)cancelButtonTapped
{
    [self dismissModalViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(directoryPickerControllerDidCancel:)]) {
        [self.delegate directoryPickerControllerDidCancel:self];
    }
}

- (void)doneButtonTapped
{
    [self dismissModalViewControllerAnimated:YES];
    
    HSDirectoryViewController *visibleViewController = (HSDirectoryViewController *)[self visibleViewController];
    if ([self.delegate respondsToSelector:@selector(directoryPickerController:didFinishPickingDirectoryAtPath:)]) {
        [self.delegate directoryPickerController:self didFinishPickingDirectoryAtPath:visibleViewController.path];
    }
}

@end
