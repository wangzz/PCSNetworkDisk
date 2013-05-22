//
//  AGIPCAssetsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCAssetsController.h"

#import "AGImagePickerController.h"
#import "AGImagePickerController+Constants.h"

#import "AGIPCGridCell.h"
#import "AGIPCToolbarItem.h"

#import "HSDirectoryNavigationController.h"

@interface AGIPCAssetsController ()

@property (nonatomic,retain) NSString   *uploadPath;
@property (nonatomic, retain) NSMutableArray *assets;
@property (readonly) AGImagePickerController *imagePickerController;

@end


@interface AGIPCAssetsController (Private)

- (void)changeSelectionInformation;

- (void)createNotifications;
- (void)destroyNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;

- (BOOL)toolbarHidden;

- (void)loadAssets;
- (void)reloadData;

- (void)setupToolbarItems;

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)doneAction:(id)sender;
- (void)selectAllAction:(id)sender;
- (void)deselectAllAction:(id)sender;
- (void)customBarButtonItemAction:(id)sender;

@end

@implementation AGIPCAssetsController

#pragma mark - Properties

@synthesize tableView, assetsGroup, assets;
@synthesize uploadPath;
@synthesize imagePickerType;

- (BOOL)toolbarHidden
{
    if (self.imagePickerController.toolbarItemsForSelection != nil) {
        return !(self.imagePickerController.toolbarItemsForSelection.count > 0);
    } else {
        return NO;
    }
}

- (void)setAssetsGroup:(ALAssetsGroup *)theAssetsGroup
{
    @synchronized (self)
    {
        if (assetsGroup != theAssetsGroup)
        {
            [assetsGroup release];
            assetsGroup = [theAssetsGroup retain];
            if (self.imagePickerType == PCSImagePickerTypeVideo) {
                [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
            } else {
                [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
            }

            [self reloadData];
        }
    }
}

- (ALAssetsGroup *)assetsGroup
{
    ALAssetsGroup *ret = nil;
    
    @synchronized (self)
    {
        ret = [[assetsGroup retain] autorelease];
    }
    
    return ret;
}

- (NSArray *)selectedAssets
{
    NSMutableArray *selectedAssets = [NSMutableArray array];
    
	for (AGIPCGridItem *gridItem in self.assets) 
    {		
		if (gridItem.selected)
        {	
			[selectedAssets addObject:gridItem.asset];
		}
	}
    
    return selectedAssets;
}

- (AGImagePickerController *)imagePickerController
{
    return ((AGImagePickerController *)self.navigationController);
}

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [tableView release];
    [assetsGroup release];
    [assets release];
    
    [super dealloc];
}

- (id)initWithAssetsGroup:(ALAssetsGroup *)theAssetsGroup type:(PCSImagePickerType)type
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self = [super initWithNibName:@"AGIPCAssetsController_iPhone" bundle:nil];
    } else {
        self = [super initWithNibName:@"AGIPCAssetsController_iPad" bundle:nil];
    }
    if (self)
    {
        assets = [[NSMutableArray alloc] init];
        imagePickerType = type;
        self.assetsGroup = theAssetsGroup;
        self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Loading", nil, [NSBundle mainBundle], @"Loading...", nil);
    }
    
    return self;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    double numberOfAssets = (double)self.assetsGroup.numberOfAssets;
    return ceil(numberOfAssets / [AGImagePickerController numberOfItemsPerRow]);
}

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[AGImagePickerController numberOfItemsPerRow]];
    
    NSUInteger startIndex = indexPath.row * [AGImagePickerController numberOfItemsPerRow], 
                 endIndex = startIndex + [AGImagePickerController numberOfItemsPerRow] - 1;
    if (startIndex < self.assets.count)
    {
        if (endIndex > self.assets.count - 1)
            endIndex = self.assets.count - 1;
        
        for (NSUInteger i = startIndex; i <= endIndex; i++)
        {
            [items addObject:[self.assets objectAtIndex:i]];
        }
    }
    
    return items;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    AGIPCGridCell *cell = (AGIPCGridCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {		        
        cell = [[[AGIPCGridCell alloc] initWithItems:[self itemsForRowAtIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }	
	else 
    {		
		cell.items = [self itemsForRowAtIndexPath:indexPath];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect itemRect = [AGImagePickerController itemRect];
    return itemRect.size.height + itemRect.origin.y;
}

#pragma mark - View Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Reset the number of selections
    [AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Fullscreen
    if (self.imagePickerController.shouldChangeStatusBarStyle) {
        self.wantsFullScreenLayout = YES;
    }
    
    // Setup Notifications
    [self createNotifications];
    
    // Start loading the assets
    [self loadAssets];
    
    self.uploadPath = PCS_STRING_DEFAULT_PATH;
    
    // Navigation Bar Items    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc]
                                       initWithTitle:@"全选"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(doneAction:)];
	self.navigationItem.rightBarButtonItem = doneButtonItem;
    [doneButtonItem release];
    
    // Setup toolbar items
//    [self setupToolbarItems];
    [self setupToolbarItemsForPCS];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Destroy Notifications
    [self destroyNotifications];
}

#pragma mark - Method for PCS
#define PCS_TAG_FILE_PATH_BUTTON    210001
- (void)setupToolbarItemsForPCS
{
    UILabel *noticeLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 60, 22)];
    noticeLable.text = @"上传到：";
    noticeLable.textAlignment = UITextAlignmentRight;
    noticeLable.font = [UIFont systemFontOfSize:13.5f];
    noticeLable.backgroundColor = [UIColor clearColor];
    [self.navigationController.toolbar addSubview:noticeLable];
    [noticeLable release];
    
    UIImage *uploadImage = [[UIImage imageNamed:@"upload_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:18];
    UIImage *uploadImaged = [[UIImage imageNamed:@"upload_buttoned"] stretchableImageWithLeftCapWidth:5 topCapHeight:18];
    UIButton    *pathButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 2, 150, 40)];
    [pathButton addTarget:self
                   action:@selector(onPathButtonAction)
         forControlEvents:UIControlEventTouchUpInside];
    [pathButton setTitle:@"Hi网盘" forState:UIControlStateNormal];
    [pathButton setBackgroundImage:uploadImage forState:UIControlStateNormal];
    [pathButton setBackgroundImage:uploadImaged forState:UIControlStateHighlighted];
    pathButton.tag = PCS_TAG_FILE_PATH_BUTTON;
    [self.navigationController.toolbar addSubview:pathButton];
    [pathButton release];
    
    UIButton    *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 2, 80, 40)];
    [uploadButton addTarget:self
                     action:@selector(onUploadButtonAction)
           forControlEvents:UIControlEventTouchUpInside];
    [uploadButton setTitle:@"上传" forState:UIControlStateNormal];
    [uploadButton setBackgroundImage:uploadImage forState:UIControlStateNormal];
    [uploadButton setBackgroundImage:uploadImaged forState:UIControlStateHighlighted];
    [self.navigationController.toolbar addSubview:uploadButton];
    [uploadButton release];
}

- (void)onPathButtonAction
{
    HSDirectoryNavigationController *directController = [[HSDirectoryNavigationController alloc] initWithRootDirectory:PCS_STRING_DEFAULT_PATH];
    directController.delegate = self;
    [self presentModalViewController:directController animated:YES];
}

- (void)onUploadButtonAction
{
    if (self.selectedAssets.count <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请选择要上传的文件！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    } else if (self.uploadPath == nil || self.uploadPath.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请选择图片上传路径！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    [self.imagePickerController didFinishPickingAssets:self.selectedAssets path:self.uploadPath];
}

- (void)directoryPickerController:(HSDirectoryNavigationController *)picker
  didFinishPickingDirectoryAtPath:(NSString *)selectPath
{
    NSLog(@"directory Picker select path:%@",selectPath);
    self.uploadPath = selectPath;
    UIButton    *pathButton = (UIButton *)[self.navigationController.toolbar viewWithTag:PCS_TAG_FILE_PATH_BUTTON];
    NSArray *array = [selectPath componentsSeparatedByString:@"/"];
    if (array.count > 2) {
        NSString    *string = [array objectAtIndex:(array.count - 2)];
        if (string != nil) {
            [pathButton setTitle:nil forState:UIControlStateNormal];
            [pathButton setTitle:string forState:UIControlStateNormal];
        }
    }
}

- (void)directoryPickerControllerDidCancel:(HSDirectoryNavigationController *)picker
{
    NSLog(@"directory Picker cancel button pressed.");
}

#pragma mark - Private
- (void)setupToolbarItems
{
    if (self.imagePickerController.toolbarItemsForSelection != nil)
    {
        NSMutableArray *items = [NSMutableArray array];
        
        // Custom Toolbar Items
        for (id item in self.imagePickerController.toolbarItemsForSelection)
        {
            NSAssert([item isKindOfClass:[AGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
            
            ((AGIPCToolbarItem *)item).barButtonItem.target = self;
            ((AGIPCToolbarItem *)item).barButtonItem.action = @selector(customBarButtonItemAction:);
            
            [items addObject:((AGIPCToolbarItem *)item).barButtonItem];
        }
        
        self.toolbarItems = items;
    } else {
        // Standard Toolbar Items
        UIBarButtonItem *selectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.SelectAll", nil, [NSBundle mainBundle], @"Select All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllAction:)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *deselectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.DeselectAll", nil, [NSBundle mainBundle], @"Deselect All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(deselectAllAction:)];
        
        NSArray *toolbarItems = [[NSArray alloc] initWithObjects:selectAll, flexibleSpace, deselectAll, nil];
        self.toolbarItems = toolbarItems;
        [toolbarItems release];
        
        [selectAll release];
        [flexibleSpace release];
        [deselectAll release];
    }
}

- (void)loadAssets
{
    [self.assets removeAllObjects];
    
    __block AGIPCAssetsController *blockSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        @autoreleasepool {
            [blockSelf.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result == nil) 
                {
                    return;
                }
                
                AGIPCGridItem *gridItem = [[AGIPCGridItem alloc] initWithAsset:result andDelegate:blockSelf];
                if ( blockSelf.imagePickerController.selection != nil && 
                    [blockSelf.imagePickerController.selection containsObject:result])
                {
                    gridItem.selected = YES;
                }
                [blockSelf.assets addObject:gridItem];
                [gridItem release];
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [blockSelf reloadData];
            
        });
        
    });
}

- (void)reloadData
{
    // Don't display the select button until all the assets are loaded.
    [self.navigationController setToolbarHidden:[self toolbarHidden] animated:YES];
    
    [self.tableView reloadData];
    
    NSString    *albumString = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    if ([albumString isEqualToString:@"Camera Roll"]) {
        albumString = @"相机胶卷";
    }
    [self setTitle:albumString];
    [self changeSelectionInformation];
    
    NSInteger totalRows = [self.tableView numberOfRowsInSection:0];
    
    //Prevents crash if totalRows = 0 (when the album is empty). 
    if (totalRows > 0) {

        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:totalRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)doneAction:(id)sender
{
    UIBarButtonItem *barItem = (UIBarButtonItem *)sender;
    selectAllAssets = !selectAllAssets;
    if (selectAllAssets) {
        barItem.title = @"全不选";
        for (AGIPCGridItem *gridItem in self.assets) {
            gridItem.selected = YES;
        }
    } else {
        barItem.title = @"全选";
        for (AGIPCGridItem *gridItem in self.assets) {
            gridItem.selected = NO;
        }
    }
}

- (void)selectAllAction:(id)sender
{
    for (AGIPCGridItem *gridItem in self.assets) {
        gridItem.selected = YES;
    }
}

- (void)deselectAllAction:(id)sender
{
    for (AGIPCGridItem *gridItem in self.assets) {
        gridItem.selected = NO;
    }
}

- (void)customBarButtonItemAction:(id)sender
{
    for (id item in self.imagePickerController.toolbarItemsForSelection)
    {
        NSAssert([item isKindOfClass:[AGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
        
        if (((AGIPCToolbarItem *)item).barButtonItem == sender)
        {
            if (((AGIPCToolbarItem *)item).assetIsSelectedBlock) {
                
                NSUInteger idx = 0;
                for (AGIPCGridItem *obj in self.assets) {
                    obj.selected = ((AGIPCToolbarItem *)item).assetIsSelectedBlock(idx, ((AGIPCGridItem *)obj).asset);
                    idx++;
                }
            }
        }
    }
}

- (void)changeSelectionInformation
{
    if (self.imagePickerController.shouldDisplaySelectionInformation) {
        self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
    }
}

#pragma mark - AGGridItemDelegate Methods

- (void)agGridItem:(AGIPCGridItem *)gridItem didChangeNumberOfSelections:(NSNumber *)numberOfSelections
{
//    self.navigationItem.rightBarButtonItem.enabled = (numberOfSelections.unsignedIntegerValue > 0);
    [self changeSelectionInformation];
}

- (BOOL)agGridItemCanSelect:(AGIPCGridItem *)gridItem
{
    if (self.imagePickerController.maximumNumberOfPhotos > 0)
        return ([AGIPCGridItem numberOfSelections] < self.imagePickerController.maximumNumberOfPhotos);
    else
        return YES;
}

#pragma mark - Notifications

- (void)createNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didChangeLibrary:) 
                                                 name:ALAssetsLibraryChangedNotification 
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)destroyNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end