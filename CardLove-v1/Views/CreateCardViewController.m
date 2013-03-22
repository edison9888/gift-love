//
//  CreateCardViewController.m
//  CardLove-v1
//
//  Created by FOLY on 2/25/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "CreateCardViewController.h"
#import "ViewGiftViewController.h"
#import "GestureImageView.h"
#import "GiftItemManager.h"
#import "MBProgressHUD.h"
#import "ZipArchive.h"
#import "GestureLabel.h"
#import "UILabel+dynamicSizeMe.h"
#import "ViewStyle.h"
#import <QuartzCore/QuartzCore.h>

#define kNewProject     @"NewTemplate"
#define kProjects       @"Projects"
#define kCards          @"Cards"
#define kPackages       @"Packages"
#define kDowndloads     @"Downloads"

#define kIndex          @"index.tjkoifoly"

#define kCanvasSize     200
#define kImageMaxSize   400

const NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@interface CreateCardViewController ()
{
    GestureImageView* currentPhoto;
    UIAlertView *photoAlert;
    UIAlertView *backAlert;
    ViewStyle *toolViewStyle;
}
@property (strong, nonatomic) NSString *pathResources;
@property (strong, nonatomic) NSString *pathConf;

-(void) addPhotoView: (UIImage *)image;

@end

@implementation CreateCardViewController

@synthesize toolBar;
@synthesize pathConf = _pathConf;
@synthesize pathResources =_pathResources;
@synthesize exportMenu =_exportMenu;

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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        toolViewStyle = [[[NSBundle mainBundle] loadNibNamed:@"ViewStyle" owner:self options:nil] objectAtIndex:0];
        [toolViewStyle setFrame:CGRectMake(0, 480, 320, 300)];
        [self.view addSubview:toolViewStyle];
    });
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"New Gift";

    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveCard)];
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(showExportMenu)];
    NSArray *arrButtons = [NSArray arrayWithObjects:btnSave, btnSend, nil];
    
    self.navigationItem.rightBarButtonItems = arrButtons;
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"Back Button.png"] forState:UIControlStateNormal];
    [btnBack setFrame:CGRectMake(0, 0, 54, 34)];
    [btnBack addTarget:self action:@selector(backPreviousView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnRemove = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeImageView)];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:btnBack], btnRemove, nil] ;
    
     [toolBar setFrame:CGRectMake(0, 480, 320, 54)];
    [self.view addSubview:toolBar];
    [self performSelector:@selector(showToolBar) withObject:nil afterDelay:0.2f];
    
    self.viewCard.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"font-frame.png"]];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    _pathResources = [self dataFilePath:kNewProject];
    NSLog(@"PATH = %@", _pathResources);
    _pathConf = [_pathResources stringByAppendingPathComponent:[NSString stringWithFormat:kIndex]];

    BOOL isDir;
    if ([fileManager fileExistsAtPath:_pathResources isDirectory:&isDir]) {
        if (isDir) {
            
            [self loadGiftView];
            
        }
    }else
    {
        [self createNewFolder:kNewProject];
    }
    [self createNewFolder:kProjects];
    [self createNewFolder:kCards];
    
    // Create a blinking text
    GestureLabel* labelText = [[GestureLabel alloc] initWithFrame:CGRectMake(50, 200, 0, 50)];
    labelText.text = @"Tap to start tap to start Tap to start";
    labelText.backgroundColor = [UIColor clearColor];


    [labelText resizeToFit];
    [self.viewCard addSubview:labelText];
    CGRect frame1 = labelText.frame;
    frame1.size.width = 100;
    labelText.frame = frame1;
    [labelText resizeToFit];

    
//    
//    void (^animationLabel) (void) = ^{
//        labelText.alpha = 0;
//    };
//    void (^completionLabel) (BOOL) = ^(BOOL f) {
//        labelText.alpha = 1;
//    };
//    
//    NSUInteger opts =  UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat;
//    [UIView animateWithDuration:1.f delay:0 options:opts
//                     animations:animationLabel completion:completionLabel];
    
    //load Tool
   

}

-(void) backPreviousView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setToolBar:nil];
    [self setViewCard:nil];
    [super viewDidUnload];
}

-(void) loadGiftView
{
    [[GiftItemManager sharedManager] setPathData:_pathConf];
    NSArray *listItems = [[GiftItemManager sharedManager] getListItems];
    
    for(GiftItem *gi in listItems)
    {
        [self addPhotoViewWithItem:gi];
    }
}

-(NSString *) dataFilePath: (NSString *) comp
{
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                  NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    return  [docsDir stringByAppendingPathComponent:comp];
}

-(void)createNewFolder: (NSString *)foleder
{
    NSFileManager *filemgr;
    NSArray *dirPaths;
    NSString *docsDir;
    NSString *newDir;
    
    filemgr =[NSFileManager defaultManager];
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    newDir = [docsDir stringByAppendingPathComponent:foleder];
    
    BOOL isDir;
    if([filemgr fileExistsAtPath:newDir isDirectory:&isDir])
    {
        if (!isDir) {
            if ([filemgr createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO)
            {
                // Failed to create directory
                NSLog(@" Failed to create directory");
            }
        }
    }else if ([filemgr createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO)
    {
        // Failed to create directory
        NSLog(@" Failed to create directory");
    }
}


#pragma mark - Instance Methods

-(void) saveCard
{
    NSMutableArray *listItems = [[NSMutableArray alloc] init];
    NSArray *arrPhotos = [self.viewCard subviews];
    NSLog(@"ARR = %@", arrPhotos);
    
    for(UIView *subview in arrPhotos)
    {
        if([subview isKindOfClass:[GestureImageView class]])
        {
            GestureImageView *temp = (GestureImageView *) subview;
            
            GiftItem *gi = [[GiftItem alloc] initWithView:temp];
            [listItems addObject:gi];
        }
    }
    
    if ([[GiftItemManager sharedManager] saveList:listItems toPath:_pathConf]) {
        [self showMessageWithCompletedView:@"Saved"];
    }
    
    
    NSLog(@"PHOTOS = %@", listItems);
}

-(void)showExportMenu
{
    if (_exportMenu.isOpen)
        return [_exportMenu close];
    
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Run Demo"
                                                    subtitle:@"Run demo of gift"
                                                       image:[UIImage imageNamed:@"Icon_Home"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          [self runDemo];
                                                      }];
    
    REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:@"Export as image"
                                                       subtitle:@"Rending gift as image"
                                                          image:[UIImage imageNamed:@"Icon_Explore"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             [self saveAsImage];
                                                         }];
    
    REMenuItem *activityItem = [[REMenuItem alloc] initWithTitle:@"Package gift"
                                                        subtitle:@"Package gift as a zip file"
                                                           image:[UIImage imageNamed:@"Icon_Activity"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
                                                              [self saveAsZip];
                                                          }];
    
    REMenuItem *saveProjectItem = [[REMenuItem alloc] initWithTitle:@"Send gift"
                                                           subtitle:@"Send gift to your friend"
                                                          image:[UIImage imageNamed:@"Icon_Profile"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             [self sendGift];
                                                         }];
    
    homeItem.tag = 0;
    exploreItem.tag = 1;
    activityItem.tag = 2;
    saveProjectItem.tag = 3;
    
    _exportMenu = [[REMenu alloc] initWithItems:@[ homeItem, exploreItem, activityItem, saveProjectItem]];
    _exportMenu.cornerRadius = 4;
    _exportMenu.shadowColor = [UIColor blackColor];
    _exportMenu.shadowOffset = CGSizeMake(0, 1);
    _exportMenu.shadowOpacity = 1;
    _exportMenu.imageOffset = CGSizeMake(5, -1);
    
    [_exportMenu showFromNavigationController:self.navigationController];
}

-(NSString *) saveAsZip
{
    [self createNewFolder:kPackages];
    NSString *docspath = [self dataFilePath:kPackages];
    NSString *projectPath = [self dataFilePath:kNewProject];
    
    NSString *zipFile = [docspath stringByAppendingPathComponent:@"newzipfile.zip"];
    
    ZipArchive *za = [[ZipArchive alloc] init];
    [za CreateZipFile2:zipFile];
    
    //[za addDirectoryToZip:projectPath];
    NSArray *filesInDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectPath error:NULL];
    NSMutableArray *mutFiles = [NSMutableArray arrayWithArray:filesInDirectory];
  
    for(id file in mutFiles)
    {
        NSLog(@"Adding file = %@ ...", file);
        [za addFileToZip:[projectPath stringByAppendingPathComponent:file] newname:file];
    }
    
    BOOL success = [za CloseZipFile2];
    
    NSLog(@"Zipped file with result %d",success);
    NSLog(@"Zip Path = %@", zipFile);
    
    return zipFile;
}

-(void) saveAsImage
{
    NSString *cardsPath = [self dataFilePath:kCards];
    NSString *fileName = [NSString stringWithFormat:@"card-love.png"];
    NSString *filePath = [cardsPath stringByAppendingPathComponent:fileName];
    
    UIImage *imageSaved = [self imageCaptureSave:self.viewCard];
    
    NSData *dataImage = [NSData dataWithData:UIImagePNGRepresentation(imageSaved)];
    
    [dataImage writeToFile:filePath atomically:YES];
}

-(void) runDemo
{
    ViewGiftViewController *vgvc = [[ViewGiftViewController alloc] initWithNibName:@"" bundle:nil];
    [self.navigationController pushViewController:vgvc animated:YES];
}

-(void) sendGift
{
    NSString *docspath = [self dataFilePath:kPackages];
    NSString *zipFile = [docspath stringByAppendingPathComponent:@"newzipfile.zip"];
    
    NSString *projectPath = [self dataFilePath:kProjects];
    NSString *unzipPath = [projectPath stringByAppendingPathComponent:@"UnZip"];
    NSFileManager *fmgr = [[NSFileManager alloc] init] ;
    
   [fmgr createDirectoryAtPath:unzipPath withIntermediateDirectories:YES attributes:nil error:NULL];
    
    if ([fmgr fileExistsAtPath:unzipPath]) {
        ZipArchive *za = [[ZipArchive alloc] init];
        if ([za UnzipOpenFile:zipFile]) {
           BOOL ret = [za UnzipFileTo:unzipPath overWrite:YES];
            if (NO == ret){} [za UnzipCloseFile];
        }
    }
    
}

-(void) removeImageView
{
    if (!currentPhoto) {
        return;
    }
    
    NSFileManager *fmgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    
    if ([fmgr removeItemAtPath:currentPhoto.imgURL error:&error]) {
        NSLog(@"Removed photo.");
        
        GiftItem *itemDeleted = (GiftItem*) [[GiftItemManager sharedManager] findGiftByImageURL:currentPhoto.imgURL];
        NSLog(@"Delete Item = %@", [itemDeleted.photo lastPathComponent] );
        [[GiftItemManager sharedManager] removeItem:itemDeleted];
    }

    [UIView animateWithDuration:0.5 animations:^{
        currentPhoto.transform =
        CGAffineTransformMakeTranslation(
                                         currentPhoto.frame.origin.x,
                                         480.0f + (currentPhoto.frame.size.height/2)  // move the whole view offscreen
                                         );
        currentPhoto.alpha = 0; // also fade to transparent
    } completion:^(BOOL finished) {
        [currentPhoto removeFromSuperview];
    }];

}

-(void)showToolBar
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; 
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [toolBar setFrame:CGRectMake(0, 416-54, 320, 54)];
    
    [UIView commitAnimations];
    
}

-(void) showStyleView
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = toolViewStyle.frame;
        frame.origin.y = 416 - frame.size.height;
        [toolViewStyle setFrame:frame];
    }];
}

-(void) hideStyleView
{
    [UIView animateWithDuration:0.5 animations:^{
        [toolViewStyle setFrame:CGRectMake(0, 480, 320, 300)];
    } completion:^(BOOL finished) {
        //[self showToolBar];
    }];
}

-(void) hideToolBarWithView: (UIView*) altView
{
    [UIView animateWithDuration:0.5 animations:^{
        //[toolBar setFrame:CGRectMake(0, 480, 320, 54)];
    } completion:^(BOOL finished) {
        [self showStyleView];
    }];
}

-(NSString *)generateRandomStringWithLength: (int) len
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(NSString *) saveImagetoResources: (UIImage *) image 
{
    NSString *pngFilePath;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    do {
        NSString *pngFileName = [NSString stringWithFormat:@"%@.png", [self generateRandomStringWithLength:10]];
        pngFilePath = [_pathResources stringByAppendingPathComponent:pngFileName];
    } while ([fileManager fileExistsAtPath:pngFilePath]);
    
    UIImage *imageBySize = [self imageBySize:image];
    
    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageBySize)];
    [data1 writeToFile:pngFilePath atomically:YES];
    
    return pngFilePath;
}

-(UIImage *)imageCaptureSave: (UIView *)viewInput
{
    CGSize viewSize = viewInput.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [viewInput.layer renderInContext:context];
    UIImage *imageX = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageX;
}

- (UIImage *)imageBySize:(UIImage *)image

{
    CGSize sizeRatio = [self resizeImage:image toMax:kImageMaxSize];
    
    UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sizeRatio.width, sizeRatio.height)];
    canvasView.image = image;
    canvasView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *result = [self imageCaptureSave:canvasView];
    
    return result;
    
}

-(void) addPhotoView: (UIImage *)image
{
    GestureImageView *imvPhoto = [[GestureImageView alloc] initWithImage:image];
    
    imvPhoto.imgURL = [self saveImagetoResources:image];
    
    [self flxibleFrameImage:image withMaxValue:kCanvasSize forView:imvPhoto inView:self.viewCard];
    [imvPhoto showShadow:YES];
    imvPhoto.delegate = self;
    
    GiftItem *item = [[GiftItem alloc] initWithView:imvPhoto];
    [[GiftItemManager sharedManager] addItem:item];
    
    [self.viewCard addSubview:imvPhoto];
    
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.1];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([imvPhoto center].x - 20.0f, [imvPhoto center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([imvPhoto center].x + 20.0f, [imvPhoto center].y)]];
    [[imvPhoto layer] addAnimation:animation forKey:@"position"];
    
    currentPhoto = imvPhoto;
}

-(void) addPhotoViewWithItem: (GiftItem *) item
{
    GestureImageView *imvPhoto = [[GestureImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:item.photo]];
    imvPhoto.bounds = CGRectFromString(item.bounds);
    imvPhoto.center = CGPointFromString(item.center);
    imvPhoto.transform = CGAffineTransformFromString(item.transform);
    imvPhoto.imgURL = item.photo;
    
    [imvPhoto showShadow:YES];
    imvPhoto.delegate = self;
    
    [self.viewCard addSubview:imvPhoto];
}

-(void) addPhotoView: (UIImage *)image withURL:(NSString *) strURL
{
    GestureImageView *imvPhoto = [[GestureImageView alloc] initWithImage:image];
    
    [self flxibleFrameImage:image withMaxValue:kCanvasSize forView:imvPhoto inView:self.viewCard];
    [imvPhoto showShadow:YES];
    imvPhoto.delegate = self;
    imvPhoto.imgURL = strURL;
    
    GiftItem *item = [[GiftItem alloc] initWithView:imvPhoto];
    [[GiftItemManager sharedManager] addItem:item];
    
    [self.viewCard addSubview:imvPhoto];
    currentPhoto = imvPhoto;
}

-(void) addPhotoView:(UIImage *)image withCenterPoint: (CGPoint)centerPoint andTransfrom: (CGAffineTransform) transform
{
    GestureImageView *imvPhoto = [[GestureImageView alloc] initWithImage:image];
    
    imvPhoto.imgURL = [self saveImagetoResources:image];
    
    [self flxibleFrameImage:image withMaxValue:kCanvasSize forView:imvPhoto inView:self.viewCard];
    imvPhoto.center = centerPoint;
    imvPhoto.transform = transform;
    [imvPhoto showShadow:YES];
    imvPhoto.delegate = self;
    
    GiftItem *item = [[GiftItem alloc] initWithView:imvPhoto];
    [[GiftItemManager sharedManager] addItem:item];
    
    [self.viewCard addSubview:imvPhoto];
}

-(CGSize) resizeImage: (UIImage *)image toMax: (CGFloat) maxValue
{
    CGSize sizeImage = image.size;
    CGSize sizeRatio;
    if (sizeImage.width > sizeImage.height) {
        if (sizeImage.width <= maxValue) {
            return image.size;
        }
        sizeRatio.width = maxValue;
        sizeRatio.height = sizeImage.height/sizeImage.width * maxValue;
    }else
    {
        if (sizeImage.height <= maxValue) {
            return image.size;
        }
        sizeRatio.height = maxValue;
        sizeRatio.width = sizeImage.width/sizeImage.height * maxValue;
    }

    return sizeRatio;
}

-(void) flxibleFrameImage: (UIImage*) image withMaxValue:(CGFloat)maxValue forView: (UIView *)view inView: (UIView *) containerView
{
    CGSize sizeRatio = [self resizeImage:image toMax:maxValue];
    [view setFrame:CGRectMake(0,0, sizeRatio.width, sizeRatio.height)];
    view.center = CGPointMake(containerView.bounds.size.width/2, containerView.bounds.size.height/2);
}

-(void) flxibleFrameImage: (UIImage*) image withMaxValue:(CGFloat)maxValue forView:(UIView*) view
{
    CGPoint centerPoint = view.center;
    [self flxibleFrameImage:image withMaxValue:maxValue forView:view inView:self.viewCard];
    view.center = centerPoint;
}

#pragma mark - GestureImage Delegate
-(void) displayEditor: (GestureImageView *)gestureImageView forImage:(UIImage *)imageToEdit
{
    currentPhoto = gestureImageView;
    
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:nil];
}

#pragma mark - AFPhotoEditor
- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    // Handle the result image here
//    NSLog(@"%@" , NSStringFromCGSize(image.size));
//    [self flxibleFrameImage:image withMaxValue:kCanvasSize forView:currentPhoto inView:self.viewCard];
//    ((GestureImageView *)currentPhoto).image = image;
//
    CGPoint center = ((GestureImageView *)currentPhoto).center;
    CGAffineTransform transform = currentPhoto.transform;
    [self removeImageView];
    
    [self addPhotoView:image withCenterPoint:center andTransfrom:transform];
    [self dismissModalViewControllerAnimated:YES];
    
}

-(void) selectImageView:(GestureImageView *)gestureImageView
{
    if (currentPhoto) {
        [currentPhoto showBorder:NO];
    }
    currentPhoto = gestureImageView;
    [currentPhoto showBorder:YES];
    NSLog(@"Select image view %@", gestureImageView);
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancelation here
    [self dismissModalViewControllerAnimated:YES];
    currentPhoto = nil;
}

#pragma mark - IBActions

- (IBAction)importPhoto:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add photo to gift" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a photo" otherButtonTitles: @"Choose from library",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
}

- (IBAction)addText:(id)sender {
    CMTextStylePickerViewController *textStylePickerViewController = [CMTextStylePickerViewController textStylePickerViewController];
	textStylePickerViewController.delegate = self;
		
	UINavigationController *actionsNavigationController = [[UINavigationController alloc] initWithRootViewController:textStylePickerViewController];
    
	[self presentModalViewController:actionsNavigationController animated:YES];
}

- (IBAction)addAnimation:(id)sender {
}
- (IBAction)editPhoto:(id)sender {
    [self hideToolBarWithView:nil];
}

- (IBAction)addMusic:(id)sender {
}

#pragma mark - ActionSheet

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"Take a photo by camera");
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                [self photoPicker:UIImagePickerControllerSourceTypeCamera];
            }else
            {
                photoAlert = [[UIAlertView alloc ]initWithTitle:@"Failed" message:@"Camera isn't available on device" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Album", nil];
                [photoAlert show];
            }
            break;
        }
        case 1:
            NSLog(@"Choose a photo from library");
            [self photoPicker:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIImagePickerController

-(void) photoPicker : (UIImagePickerControllerSourceType) pickerSourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType = pickerSourceType;
    
    [self presentModalViewController:picker animated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    //NSLog(@"KEY = %@", [info allKeys]);
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //NSString *imgURL = [[info objectForKey:UIImagePickerControllerMediaURL] absoluteString];
    [self addPhotoView:image];
    NSLog(@"Add image = %@", image);
}

#pragma mark - AlertView

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == photoAlert) {
        switch (buttonIndex) {
            case 1:
            {
                [self photoPicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            }
                break;
                
            default:
                break;
        }

    }else if (alertView == backAlert)
    {
        
    }
}

-(void) showMessageWithCompletedView: (NSString *) message
{
    UIImageView *completedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] ;
	
	[self showMessage:message withCustomView:completedView];
}

-(void) showMessage: (NSString *)message withCustomView :(UIView *)customView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
    HUD.customView = customView;
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = self;
	HUD.labelText = message;
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:1];

}

-(void) hudWasHidden:(MBProgressHUD *)hud
{
    [HUD removeFromSuperview];
}

#pragma mark - Touch Event
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self currentItemDeslected:currentPhoto];
    
}

-(void)currentItemDeslected : (GestureImageView *)currentItem
{
    [self hideStyleView];
    [currentItem showBorder:NO];
    currentItem = nil;
}

#pragma mark -
#pragma mark CMTextStylePickerViewControllerDelegate methods

- (void)textStylePickerViewController:(CMTextStylePickerViewController *)textStylePickerViewController userSelectedFont:(UIFont *)font {
	
}

- (void)textStylePickerViewController:(CMTextStylePickerViewController *)textStylePickerViewController userSelectedTextColor:(UIColor *)textColor {
	
}

- (void)textStylePickerViewControllerSelectedCustomStyle:(CMTextStylePickerViewController *)textStylePickerViewController {
	// Use custom text style
	
}

- (void)textStylePickerViewControllerSelectedDefaultStyle:(CMTextStylePickerViewController *)textStylePickerViewController {
	// Use default text style
	
}

- (void)textStylePickerViewController:(CMTextStylePickerViewController *)textStylePickerViewController replaceDefaultStyleWithFont:(UIFont *)font textColor:(UIColor *)textColor {
	
}

- (void)textStylePickerViewControllerIsDone:(CMTextStylePickerViewController *)textStylePickerViewController {
	[self dismissModalViewControllerAnimated:YES];
}






@end
