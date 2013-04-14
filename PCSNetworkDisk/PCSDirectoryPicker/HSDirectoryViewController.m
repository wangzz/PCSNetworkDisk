//
//  HSDirectoryViewController.m
//  HSShtFaxClient
//
//  Created by zhongzhou wang on 13-2-20.
//  Copyright (c) 2013年 hisunsray. All rights reserved.
//

#import "HSDirectoryViewController.h"

@interface HSDirectoryViewController ()
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, retain) UITableView   *mTableView;
@end

@implementation HSDirectoryViewController
@synthesize path;
@synthesize files;
@synthesize mTableView;
@synthesize showBackNavigationButton;

- (HSDirectoryViewController *)initWithDirectoryAtPath:(NSString *)aPath
{
    self = [super init];
    
    if (self) {
        NSArray *array = [aPath componentsSeparatedByString:@"/"];
        if (array.count > 2) {
            NSString    *string = [array objectAtIndex:(array.count - 2)];
            if (string != nil) {
                self.title = string;
            }
        }
        path = [aPath copy];
    }
    
    return self;
}

- (void)dealloc
{
    [path release];
    [super dealloc];
}

- (void)creatNavigationBar
{
    UIButton *navButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 32)] autorelease];
    navButton.backgroundColor  = [UIColor clearColor];
    [navButton setBackgroundImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    [navButton setBackgroundImage:[UIImage imageNamed:@"back_selected"] forState:UIControlStateHighlighted];
    [navButton addTarget:self
                  action:@selector(onNavButtonAction)
        forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *navMenuBtn = [[[UIBarButtonItem alloc] initWithCustomView:navButton] autorelease];
    self.navigationItem.leftBarButtonItem = navMenuBtn;
}

- (void)onNavButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.files = [[PCSDBOperater shareInstance] getSubFolderListFromDB:self.path];
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 372+(iPhone5?88:0))];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    [self.view addSubview:mTableView];
    [mTableView release];
    
    if (showBackNavigationButton) {
        [self creatNavigationBar];
    }
    
    // Set the prompt text
    [[self navigationItem] setPrompt:@"选择文件上传路径"];
}

- (BOOL)isFileVaild:(NSString *)fileName
{
    if ([fileName hasPrefix:@"."]) {
        return NO;
    } else if ([fileName isEqualToString:@"Draft"]) {
        return NO;
    } else if ([fileName isEqualToString:@"imgfax"]) {
        return NO;
    }
    
    return YES;
}

- (UIImage *)getImageBy:(PCSFileFormat)format
{
    UIImage *image = nil;
    switch (format) {
        case PCSFileFormatFolder:
            image = [UIImage imageNamed:@"netdisk_type_folder"];
            break;
        default:
            break;
    }
    return image;
}

#define PCS_TABLEVIEW_CELL_HEIGHT               50.0f
#define TAG_DIRECTORY_TABLEVIEW_CELL_IMAGEVIEW  200001
#define TAG_DIRECTORY_TABLEVIEW_CELL_MAIN_LABLE 200003

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return PCS_TABLEVIEW_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (NSInteger) tableView:(UITableView *)tableView
indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @" ";
        cell.textLabel.hidden = YES;
        
        UIImageView* bgImage = [[UIImageView alloc] initWithFrame:
                                CGRectMake(0,
                                           PCS_TABLEVIEW_CELL_HEIGHT - 1,
                                           320,
                                           1)];
        bgImage.image = [UIImage imageNamed:@"line"];
        [cell.contentView addSubview:bgImage];
        PCS_FUNC_SAFELY_RELEASE(bgImage);
        
        UIImageView*    imageView = [[UIImageView alloc] initWithFrame:
                                     CGRectMake(10, 5, 40, 40)];
        imageView.tag = TAG_DIRECTORY_TABLEVIEW_CELL_IMAGEVIEW;
        [cell.contentView addSubview:imageView];
        PCS_FUNC_SAFELY_RELEASE(imageView);
        
        UILabel *mainLable = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 250, 30)];
        mainLable.backgroundColor = [UIColor clearColor];
        mainLable.lineBreakMode = UILineBreakModeMiddleTruncation;
        mainLable.font = PCS_MAIN_FONT;
        mainLable.tag = TAG_DIRECTORY_TABLEVIEW_CELL_MAIN_LABLE;
        [cell.contentView addSubview:mainLable];
        PCS_FUNC_SAFELY_RELEASE(mainLable);
    }
    
    PCSFileInfoItem *item = [self.files objectAtIndex:[indexPath row]];

    UILabel *mainLable = (UILabel *)[cell.contentView viewWithTag:TAG_DIRECTORY_TABLEVIEW_CELL_MAIN_LABLE];
    mainLable.text = item.name;

    UIImageView *typeImageView = (UIImageView *)[cell.contentView viewWithTag:TAG_DIRECTORY_TABLEVIEW_CELL_IMAGEVIEW];
    typeImageView.image = [self getImageBy:item.format];

    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCSFileInfoItem *item = [self.files objectAtIndex:[indexPath row]];
    NSString    *nextPath = [NSString stringWithFormat:@"%@/",item.serverPath];
    HSDirectoryViewController *detailViewController = [[HSDirectoryViewController alloc] initWithDirectoryAtPath:nextPath];
    detailViewController.showBackNavigationButton = YES;
    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
}


@end
