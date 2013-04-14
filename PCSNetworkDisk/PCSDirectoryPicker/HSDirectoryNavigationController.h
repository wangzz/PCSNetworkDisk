//
//  HSDirectoryNavigationController.h
//  HSShtFaxClient
//
//  Created by zhongzhou wang on 13-2-20.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSDirectoryDelegate.h"

@interface HSDirectoryNavigationController : UINavigationController
@property (nonatomic, assign) id<UINavigationControllerDelegate,HSDirectoryDelegate> delegate;
@property (nonatomic, copy)   NSString *rootDirectory;

- (id)initWithRootDirectory:(NSString *)directory;

@end
