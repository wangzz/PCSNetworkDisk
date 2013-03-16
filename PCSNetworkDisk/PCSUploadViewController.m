//
//  PCSUploadViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSUploadViewController.h"

@interface PCSUploadViewController ()

@end

@implementation PCSUploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 构建界面
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];        PCS_FUNC_SAFELY_RELEASE(picker);
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的设备不支持访问多媒体文件目录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - 数据处理

- (void)uploadTest
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:@"/happy.mp3"];
    NSData  *data = [NSData dataWithContentsOfFile:filePath];
    NSString *target = [[NSString alloc] initWithFormat:@"%@%@",PCS_STRING_DEFAULT_PATH,@"qiea.mp4"];
    [self uploadFile:data name:target];
}

- (void)uploadFile:(NSData *)data name:(NSString *)name
{
    if (nil == data || nil == name) {
        PCSLog(@"upload err,the data or name is nil.");
        return;
    }
    
    dispatch_queue_t queue = PCS_APP_DELEGATE.gcdQueue;
    dispatch_async(queue, ^{
        PCSFileInfoResponse *response = [PCS_APP_DELEGATE.pcsClient uploadData:data
                                                                              :name];
        PCSSimplefiedResponse   *result = response.status;
        if (result.errorCode != 0) {
            PCSLog(@"upload file err,errCode:%d,message:%@",response.status.errorCode,response.status.message);
            return;
        } else {
            PCSLog(@"upload file :%@ success",name);
        }
        //发送开始数据更新操作通知
        [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_INCREMENT_UPDATE
                                                            object:nil];
    });
    
}

#pragma mark - 按钮响应事件
- (IBAction)onButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1001) {
        [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (button.tag == 1002) {
        [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
    } else if (button.tag == 1003) {
        [self uploadTest];
    }
}

@end
