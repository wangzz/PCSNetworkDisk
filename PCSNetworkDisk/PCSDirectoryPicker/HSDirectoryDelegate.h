//
//  HSDirectoryDelegate.h
//  HSShtFaxClient
//
//  Created by zhongzhou wang on 13-2-20.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSDirectoryNavigationController;
@protocol HSDirectoryDelegate <UINavigationControllerDelegate>

@optional
- (void)directoryPickerController:(HSDirectoryNavigationController *)picker 
  didFinishPickingDirectoryAtPath:(NSString *)selectPath;
- (void)directoryPickerControllerDidCancel:(HSDirectoryNavigationController *)picker;
@end

