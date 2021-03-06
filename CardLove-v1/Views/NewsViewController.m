//
//  NewsViewController.m
//  CardLove-v1
//
//  Created by FOLY on 2/24/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "NewsViewController.h"
#import "SSCollectionView.h"
#import "SSCollectionViewItem.h"
#import "CollectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "GiftsManager.h"
#import "AJNotificationView.h"
#import "RequestsManager.h"
#import "NSArray+findObject.h"

@interface NewsViewController ()
{
    NSDictionary *_currentGift;
}

@end

@implementation NewsViewController

@synthesize actionBlock = _actionBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"News", @"News");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Gift Inbox";
    
    UIBarButtonItem *btnRefesh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refeshList:)];
    self.navigationItem.rightBarButtonItem = btnRefesh;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:kNotificationReload object:nil];
    self.collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;

    _recieveArray = [[GiftsManager sharedManager] listRecievedGifts];
    _sentArray = [[GiftsManager sharedManager] listSentGifts];
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
}

-(void) viewDidUnload
{
    [self setRecieveArray:nil];
    [self setSentArray:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.collectionView name:kNotificationReload object:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
	return 2;
}


- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
	switch (section) {
        case 0:
        {
            return [_recieveArray count];
        }
            break;
        case 1:
            return [_sentArray count];
            break;
            
        default:
            return 0;
            break;
    }
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
	static NSString *const itemIdentifier = @"itemIdentifier";
    
    SSCollectionViewItem *item = [aCollectionView dequeueReusableItemWithIdentifier:itemIdentifier];
    if(!item)
    {
        item = (SSCollectionViewItem *)[[[NSBundle mainBundle] loadNibNamed:@"SSCollectionViewItem" owner:self options:nil] objectAtIndex:0];
        item.reuseIdentifier = [itemIdentifier copy];
    }
    
    item.imageView.image = [UIImage imageNamed:@"card-icon.jpg"];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    NSDictionary *dictGift = nil;
    NSString *name = nil;
    
    switch (section) {
        case 0:
        {
            dictGift = [_recieveArray objectAtIndex:row];
            name = [[FriendsManager sharedManager] friendNameByID:[dictGift valueForKey:@"gfSenderID"]];
            if ([[dictGift valueForKey:@"gfMarkOpened"] intValue] == 0) {
                item.imvNew.hidden = NO;
            }else
            {
                item.imvNew.hidden = YES;
            }
            
        }
            break;
        case 1:
        {
            dictGift = [_sentArray objectAtIndex:row];
            name = [[FriendsManager sharedManager] friendNameByID:[dictGift valueForKey:@"gfRecieverID"]];
            item.imvNew.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    item.titleLabel.text = [dictGift valueForKey:@"gfTitle"];
    if (name) {
        item.nameLabel.text = name;
    }else
    {
        item.nameLabel.text = @"<Unknown>";
    }
    
    NSDate *date = [[FunctionObject sharedInstance] dateFromStringDateTime:[dictGift valueForKey:@"gfDateSent"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    item.detailTextLabel.text = [dateFormatter stringFromDate:date];
    
	return item;
}

- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
    
    CollectionHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:@"CollectionHeaderView" owner:self options:nil] objectAtIndex:0];
    
    
    switch (section) {
        case 0:
        {
            header.lbTitle.text = @"Inbox";
        }
            break;
        case 1:
        {
            header.lbTitle.text = @"Sent";
        }
            break;
            
        default:
            break;
    }

    
    return header;
}


#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
	return CGSizeMake(150, 120);
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            _currentGift = [_recieveArray objectAtIndex:indexPath.row];
        }
            break;
        case 1:
        {
            _currentGift = [_sentArray objectAtIndex:indexPath.row];
        }
            break;
            
        default:
            break;
    }

	NSString *title = [NSString stringWithFormat:@"You selected %@",[_currentGift valueForKey:@"gfTitle"]];
    NSString *message = [NSString stringWithFormat:@"Download and play gift"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self
										  cancelButtonTitle:@"Cancel" otherButtonTitles:@"Play", nil];
	[alert show];
}


- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
	return 40.0f;
}

-(void) refeshList: (id) sender
{
    
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   
    
    switch (buttonIndex) {
        case 1:
        {
            //Download
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            NSString *pathDownload = [self pathDownload:_currentGift];
            
            NSLog(@"OPEN %@", [_currentGift valueForKey:@"gfID"]);
            
            if (![[[UserManager sharedInstance] accID] isEqualToString:[_currentGift valueForKey:@"gfSenderID"]]) {
                [[FunctionObject sharedInstance] openGift:[_currentGift valueForKey:@"gfID"] completion:^(BOOL success, NSError *error) {
                    NSLog(@"Marked Open !");
                }];
            }
            
            if ([[FunctionObject sharedInstance] fileHasBeenCreatedAtPath:pathDownload]) {
                [HUD hide:YES afterDelay:0.5];
                [self performSelector:@selector(unzipAndOpenWithPath:) withObject:pathDownload afterDelay:0.5];
            }else{
                NSString *urlDownload = [_currentGift valueForKey:@"gfResourcesLink"];

                
                [[FunctionObject sharedInstance] dowloadFromURL:urlDownload toPath:pathDownload withProgress:^(CGFloat progress) {
                    HUD.mode = MBProgressHUDModeDeterminate;
                    HUD.progress = progress;
                } completion:^(BOOL success, NSError *error) {
                    
                    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                    HUD.mode = MBProgressHUDModeCustomView;
                    HUD.labelText = @"Download gift successful";
                    [HUD hide:YES afterDelay:0.5];
                    [self performSelector:@selector(unzipAndOpenWithPath:) withObject:pathDownload afterDelay:0.5];
                }];

            }
            
        }
            break;
        case 0:
        {
            //cancel
            _currentGift = nil;
        }
            break;
        case 2:
            break;
            
        default:
            break;
    }
}

-(NSString *) pathDownload: (NSDictionary *) objGift
{
    [[FunctionObject sharedInstance] createNewFolder:kDowndloads];
    NSString *downloadFolder = [[FunctionObject sharedInstance]  dataFilePath:kDowndloads];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.zip", [objGift valueForKey:@"gfTitle"],[objGift valueForKey:@"gfID"]];
    return [downloadFolder stringByAppendingPathComponent:fileName];
}

-(void) unzipAndOpenWithPath:(NSString *)path
{
    
    [[FunctionObject sharedInstance] createNewFolder:kGift];
    NSString *docUnzip = [[FunctionObject sharedInstance] dataFilePath:kGift];
    
    NSString *pathUnzip = [docUnzip stringByAppendingPathComponent:[[path lastPathComponent] substringToIndex:[path lastPathComponent].length-4]];
    [[FunctionObject sharedInstance] unzipFileAtPath:path toPath:pathUnzip withCompetionBlock:^(NSString *pathToOpen) {
        NSLog(@"PATH = %@", pathToOpen);
        ViewGiftViewController *cvcv = [[ViewGiftViewController alloc] initWithNibName:@"ViewGiftViewController" bundle:nil];
        cvcv.giftPath = pathToOpen;
        Friend *cF = [[FriendsManager sharedManager] friendByID:[_currentGift objectForKey:@"gfSenderID"]];
        if (!cF) {
            
            id personRequest = [[[RequestsManager sharedManager] listRequests ] findObjectWithKey:@"accID" andValue:[_currentGift objectForKey:@"gfSenderID"]];
                                ;
            if (personRequest) {
                cF = [[Friend alloc] initWithDictionary:personRequest];
            }
        }
        if (!cF) {
            cF = [[Friend alloc] init];
            cF.fID = [_currentGift objectForKey:@"gfSenderID"];
            cF.displayName = @"Unknown";
        }
        cvcv.sender = cF;
        cvcv.delegate = self;
        
        [[HMGLTransitionManager sharedTransitionManager] setTransition:[[DoorsTransition alloc] init]];
        [[HMGLTransitionManager sharedTransitionManager] presentModalViewController:cvcv onViewController:self.navigationController];
        _currentGift = nil;
    }];
}

#pragma mark - ViewGift Delegate
-(void) modalControllerDidFinish:(ViewGiftViewController *)modalController
{
    [[HMGLTransitionManager sharedTransitionManager] setTransition:[[DoorsTransition alloc] init]];
	[[HMGLTransitionManager sharedTransitionManager] dismissModalViewController:modalController];
}


-(void) modalControllerDidFinish:(ViewGiftViewController *)modalController toSend:(Friend *)sF withPath:(NSString *)giftPath
{
    [[HMGLTransitionManager sharedTransitionManager] setTransition:[[DoorsTransition alloc] init]];
	[[HMGLTransitionManager sharedTransitionManager] dismissModalViewController:modalController];
    
    __weak typeof(self) weakSelf = self;
    _actionBlock = ^{
        
        SendGiftViewController *sgvc = [[SendGiftViewController alloc] initWithNibName:@"SendGiftViewController" bundle:nil];
        sgvc.delegate = weakSelf;
        sgvc.toFriend = sF;
        sgvc.pathGift = giftPath;
        [weakSelf.navigationController pushViewController:sgvc animated:YES];
    };
    
    [self performSelector:@selector(runBlock:) withObject:_actionBlock afterDelay:0.75];
    
}

-(void) modalControllerDidFinish:(ViewGiftViewController *)modalController toEditWithPath:(NSString *)gifPath
{
    [[HMGLTransitionManager sharedTransitionManager] setTransition:[[DoorsTransition alloc] init]];
	[[HMGLTransitionManager sharedTransitionManager] dismissModalViewController:modalController];
    
    __weak typeof(self) weakSelf = self;
    _actionBlock = ^{
        
        CreateCardViewController *ccvc = [[CreateCardViewController alloc] initWithNibName:@"CreateCardViewController" bundle:nil];
        ccvc.giftPath = gifPath;
        ccvc.edit = YES;
        [weakSelf.navigationController pushViewController:ccvc animated:YES];
    };
    
    [self performSelector:@selector(runBlock:) withObject:_actionBlock afterDelay:0.75];
}

-(void) modalControllerDidFinish:(ViewGiftViewController *)modalController toTalk:(Friend *)sF
{
    [[HMGLTransitionManager sharedTransitionManager] setTransition:[[DoorsTransition alloc] init]];
	[[HMGLTransitionManager sharedTransitionManager] dismissModalViewController:modalController];
    
    __weak typeof(self) weakSelf = self;
    _actionBlock = ^{
        
        ChatViewController *ccvc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        ccvc.friendChatting = sF;
        ccvc.mode = ChatModeSigle;
        [weakSelf.navigationController pushViewController:ccvc animated:YES];
    };
    
    [self performSelector:@selector(runBlock:) withObject:_actionBlock afterDelay:0.75];

}

-(void) runBlock:(ActionGiftBlock) actionBlock
{
    NSLog(@"SHIT");
    actionBlock();
}

-(void) sendGiftViewController:(SendGiftViewController *)sgvc didSendGift:(NSString *)path withParams:(NSDictionary *)dictParams
{
    
    NSData *giftData = [NSData dataWithContentsOfFile:path];
    [[FunctionObject sharedInstance] uploadGift:giftData withProgress:^(CGFloat progress) {
       
    } completion:^(BOOL success, NSError *error, NSString *urlUpload) {
        
        [[FunctionObject sharedInstance] sendGift:urlUpload withParams:dictParams completion:^(BOOL success, NSError *error) {
            
            if (success) {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Send gift successful" image:[UIImage imageNamed:@"37x-Checkmark.png"]];
            }else{
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Error send gift !"];
                NSLog(@"ERROR = %@", error);
            }
            
        }];
    }];
}


@end
