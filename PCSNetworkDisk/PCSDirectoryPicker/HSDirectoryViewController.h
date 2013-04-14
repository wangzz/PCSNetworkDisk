//
//  HSDirectoryViewController.h
//  HSShtFaxClient
//
//  Created by zhongzhou wang on 13-2-20.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HSDirectoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) BOOL  showBackNavigationButton;
@property (nonatomic, copy) NSString    *path;

- (HSDirectoryViewController *)initWithDirectoryAtPath:(NSString *)aPath;

@end
