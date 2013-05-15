//
//  UINavigationBar+UINavigationBar_Addition.h
//  PCSNetworkDisk
//
//  Created by wangzz on 13-5-15.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (UINavigationBar_Addition)
- (void)setBackgroudImage:(UIImage*)image;
-(UIImage*)barBackground;
-(void)didMoveToSuperview;
-(void)drawRect:(CGRect)rect;
@end
