//
//  PCSUploadViewController.m
//  PCSNetDisk
//
//  Created by wangzz on 13-3-7.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "PCSUploadViewController.h"

@interface PCSUploadViewController ()

@property (nonatomic,retain) IBOutlet   UITableView *mTableView;
@property (nonatomic,retain) NSDictionary   *uploadFileDictionary;
@property (nonatomic,retain) NSArray   *sectionTitleArray;

@end

@implementation PCSUploadViewController
@synthesize mTableView;
@synthesize uploadFileDictionary;
@synthesize sectionTitleArray;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"上传记录";
        progressView = [[UIProgressView alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [progressView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    progressView.frame = CGRectMake(50, 75, 220, 20);
    [self.view addSubview:progressView];
    
    [self reloadTableDataSource];
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
        [self presentViewController:picker animated:YES completion:nil];
        PCS_FUNC_SAFELY_RELEASE(picker);
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您的设备不支持访问多媒体文件目录"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - 数据处理
- (void)uploadTest
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:@"/test.pdf"];
    NSData  *data = [NSData dataWithContentsOfFile:filePath];
    NSString    *fileName = @"编码规范.pdf";
    NSString *target = [[NSString alloc] initWithFormat:@"%@%@",PCS_STRING_DEFAULT_PATH,fileName];
    /*
     PCS_FUNC_SENTENCED_EMPTY(item.name),PCS_FUNC_SENTENCED_EMPTY(item.serverPath),item.size,item.property,item.format,item.mtime
     */
    //先将文件保存到缓存中
    [[PCSDBOperater shareInstance] saveFile:data name:target];
    
    PCSFileInfoItem *fileItem = [[PCSFileInfoItem alloc] init];
    fileItem.name = fileName;
    fileItem.serverPath = target;
    fileItem.size = data.length;
    fileItem.property = PCSFileUploadStatusUploading;
    fileItem.format = [[PCSDBOperater shareInstance] getFileTypeWith:fileName];
    fileItem.mtime = [[NSDate date] timeIntervalSince1970] ;
    
    BOOL    result = NO;
    result = [[PCSDBOperater shareInstance] saveUploadFileToDB:fileItem];
    if (result) {
        [self uploadFile:data name:target];
    }
    PCS_FUNC_SAFELY_RELEASE(fileItem);
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
                                                                              :name
                                                                              :self];
        PCSSimplefiedResponse   *result = response.status;
        if (result.errorCode != 0) {
            PCSLog(@"upload file err,errCode:%d,message:%@",response.status.errorCode,response.status.message);
        } else {
            PCSLog(@"upload file :%@ success",name);
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL    result = NO;
                //更新文件状态
                result = [[PCSDBOperater shareInstance] updateUploadFile:name
                                                                  status:PCSFileUploadStatusSuccess];
                if (result) {
                    [self reloadTableDataSource];
                }
            });
            //发送开始数据更新操作通知
            [[NSNotificationCenter defaultCenter] postNotificationName:PCS_NOTIFICATION_INCREMENT_UPDATE
                                                                object:nil];
        }
    });
}

- (void)reloadTableDataSource
{
    self.uploadFileDictionary = [[PCSDBOperater shareInstance] getUploadFileFromDB];
    self.sectionTitleArray = [self createSectionTitleArray];
    [self.mTableView reloadData];
}

- (NSArray  *)createSectionTitleArray
{
    // 获取所有可显示联系人的首字母数组
    NSMutableArray *myKeys = (NSMutableArray*)[self.uploadFileDictionary allKeys];
    if(myKeys == nil || [myKeys count] == 0){
        return myKeys;
    }
    NSMutableArray *mySortedKeys= [[NSMutableArray alloc]initWithArray:[myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    PCS_FUNC_SAFELY_RELEASE(mySortedKeys);
    return myKeys;
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

#pragma mark - Table view data source

#define UPLOAD_TABLEVIEW_HEIGHT 50.0f
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return UPLOAD_TABLEVIEW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self.uploadFileDictionary objectForKey:[self.sectionTitleArray objectAtIndex:section]];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSArray *sectionArray = [self.uploadFileDictionary objectForKey:[self.sectionTitleArray objectAtIndex:indexPath.section]];
    PCSFileInfoItem *fileItem = [sectionArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = fileItem.name;
    
    
    return cell;
}


#pragma mark -- Baidu Listener Delegate
-(void)onProgress:(long)bytes:(long)total
{
    progressView.progress = (float)bytes/(float)total;
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
