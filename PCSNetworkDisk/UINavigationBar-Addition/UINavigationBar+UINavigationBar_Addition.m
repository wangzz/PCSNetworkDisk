//
//  UINavigationBar+UINavigationBar_Addition.m
//  PCSNetworkDisk
//
//  Created by wangzz on 13-5-15.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "UINavigationBar+UINavigationBar_Addition.h"

@implementation UINavigationBar (UINavigationBar_Addition)
- (void)setBackgroudImage:(UIImage*)image
{
    CGSize imageSize = [image size];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, imageSize.height);
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:image];
    backgroundImage.frame = self.bounds;
    [self addSubview:backgroundImage];
    
    [backgroundImage release];
}

-(UIImage*)barBackground
{
    
    return [UIImage imageNamed:@"nav_background"];
}

-(void)didMoveToSuperview
{
    //iOS5 only
    if([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [self setBackgroundImage:[self barBackground] forBarMetrics:UIBarMetricsDefault];
    }
}

//this doesn't work on iOS5 but is needed for iOS4 and earlier
-(void)drawRect:(CGRect)rect
{
    //draw image
    [[self barBackground] drawInRect:rect];
}

@end
