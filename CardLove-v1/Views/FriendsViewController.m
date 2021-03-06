//
//  FriendsViewController.m
//  CardLove-v1
//
//  Created by FOLY on 2/24/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "FriendsViewController.h"
#import "DrawerViewMenu.h"
#import "ChatViewController.h"
#import "AppDelegate.h"
#import "EKNotifView.h"
#import "AddFriendViewController.h"
#import "ModalPanelPickerView.h"
#import "UANoisyGradientBackground.h"
#import "UAGradientBackground.h"
#import "UserManager.h"
#import "UIImageView+AFNetworking.h"
#import "NKApiClient.h"
#import "AFNetworking.h"
#import "JSONKit.h"
#import "FriendInfoViewController.h"
#import "SendGiftViewController.h"
#import "UIView+Badge.h"
#import "UILabel+dynamicSizeMe.h"
#import "NSArray+findObject.h"
#import "AJNotificationView.h"
#import "RequestsManager.h"

typedef void (^FinishBlock)();

@interface FriendsViewController ()
{
    NSIndexPath *currentIndexPath;
    Friend *currentFriend;
    
}
@property (strong, nonatomic) NSTimer *timerScheduleRequest;
@end

@implementation FriendsViewController

@synthesize tableView           = _tableView;
@synthesize actionHeaderView    = _actionHeaderView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Friends", @"Friends");
        self.tabBarItem.image = [UIImage imageNamed:@"friends.png"];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
    self.view.backgroundColor = bgColor;
    [self loadActionHeaderView];
    
    //    UIButton *btnAddFriend = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnAddFriend setBackgroundImage:[UIImage imageNamed:@"ButtonAddFriend.png"] forState:UIControlStateNormal];
    //    btnAddFriend.frame = CGRectMake(0, 0, 40, 30);
    //    [btnAddFriend addTarget:self action:@selector(addFriendView) forControlEvents:UIControlEventTouchUpInside];
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnAddFriend];
    
    _mode = FriendModeList;
    _listRequest = [[RequestsManager sharedManager] listRequests];
    
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriendView)];
    self.navigationItem.rightBarButtonItem = btnAdd;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFriend) name:kNotificationReloadFriendsList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendGiftView:) name:kNotificationSendGiftToFriend object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendGiftToFriend:) name:kNotificationSendGiftFromChoice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRequest) name:kNotificationReload object:nil];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Loading";
    
    NSString *userID = [[UserManager sharedInstance] accID];
    [[FriendsManager sharedManager] loadFriendsFromURLbyUser:userID completion:^(BOOL success, NSError *error) {
        [hud hide:YES];
        [_tableView reloadData];
    }];
    
//    if (!_timerScheduleRequest) {
//         _timerScheduleRequest = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(reloadAll) userInfo:nil repeats:YES];
//    }

    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [_timerScheduleRequest invalidate];
    [super viewWillDisappear:animated];
    
}

-(void) reloadFriend
{
    NSString *userID = [[UserManager sharedInstance] accID];
    [[FriendsManager sharedManager] loadFriendsFromURLbyUser:userID completion:^(BOOL success, NSError *error) {
        [_tableView reloadData];
    }];
}


-(void) addFriendView
{
//    Friend *f = [[Friend alloc] init];
//    f.displayName = @"Nguyen Chi Cong";
//    f.userName = @"foly";
//    
//    [[FriendsManager sharedManager] addFriend:f];
//    [[FriendsManager sharedManager]loadFriends];
//    
//    NSIndexPath *newLastIndexPath = [NSIndexPath indexPathForRow:([_tableView numberOfRowsInSection:(_tableView.numberOfSections - 1)]) inSection:(_tableView.numberOfSections - 1)];
//    //[_tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//
//    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newLastIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//    [self performSelector:@selector(addFriendCompleteWithBlock:) withObject:^{
//        [_tableView reloadData];
//        } afterDelay:0.5];
    
    AddFriendViewController *addFriendVC = [[AddFriendViewController alloc] initWithNibName:@"AddFriendViewController" bundle:nil];
    [self.navigationController pushViewController:addFriendVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setActionHeaderView:nil];
    [self setListRequest:nil];
    [self setTimerScheduleRequest:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloadFriendsList object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSendGiftToFriend object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSendGiftFromChoice object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReload object:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//
//-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Friends List";
//}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (_mode) {
        case FriendModeList:
        {
            return [[[FriendsManager sharedManager] friendsList] count];
        }
            break;
        case RequestModeList:
        {
            return [_listRequest count];
        }
            break;
            
        default:
            break;
    }
    return 0;
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_mode) {
        case FriendModeList:
        {
            static NSString *CellIdentifier = @"FriendCell";
            
            HHPanningTableViewCell *cell = (HHPanningTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if(!cell)
            {
                cell = [[HHPanningTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                DrawerViewMenu *drawerView = [[[NSBundle mainBundle] loadNibNamed:@"DrawerViewMenu" owner:nil options:nil] objectAtIndex:0];
                drawerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_dotted.png"]];
                drawerView.delegate = self;
                
                cell.drawerView = drawerView;
                
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            
            //cell.delegate = self;
            cell.directionMask = HHPanningTableViewCellDirectionLeft;
            
            ((DrawerViewMenu *)cell.drawerView).indexPath = indexPath;
            
            Friend *cF = [[[FriendsManager sharedManager] friendsList] objectAtIndex:indexPath.row];
            
            cell.textLabel.text = cF.displayName;
            cell.detailTextLabel.text = cF.userName;
            
            [cell.imageView setImage:[UIImage imageNamed:@"noavata.png"]];
            NSString *avatarLink = cF.fAvatarLink;
            if (avatarLink!= (id)[NSNull null] && avatarLink.length != 0) {
                [cell.imageView setImageWithURL:[NSURL URLWithString:avatarLink] placeholderImage:[UIImage imageNamed:@"noavata.png"]];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.badgeString = [NSString stringWithFormat:@" "];
            
            if ([cF.fStatus intValue]==FriendRequest) {
                cell.badgeColor = [UIColor colorWithRed:0.992 green:0.897 blue:0.019 alpha:1.000];
                
            }else if ([cF.fStatus intValue] == FriendSuccessful)
            {
                cell.badgeColor = [UIColor colorWithRed:0.192 green:0.797 blue:0.219 alpha:1.000];
            }else
            {
                cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
            }
            
            cell.showShadow = YES;
            
            return cell;
        }
            break;
        case RequestModeList:
        {
            static NSString *cellIdetifier = @"FriendRequestCell";
            FriendRequestCell *cell = (FriendRequestCell*)[tableView dequeueReusableCellWithIdentifier:cellIdetifier];
            if (!cell) {
                cell = (FriendRequestCell *)[self loadReusableTableViewCellFromNibNamed:@"FriendRequestCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
            }
            
            NSDictionary *dictPerson = [_listRequest objectAtIndex:indexPath.row];
            cell.lbName.text = [dictPerson valueForKey:@"accDisplayName"];
            cell.lbNick.text = [dictPerson valueForKey:@"accName"];
            
            [cell.imvAvarta setImage:[UIImage imageNamed:@"noavata.png"]];
            NSString *avatarLink = [dictPerson valueForKey:@"accImageAvata"];
            if (avatarLink!= (id)[NSNull null] && avatarLink.length != 0) {
                [cell.imvAvarta setImageWithURL:[NSURL URLWithString:avatarLink] placeholderImage:[UIImage imageNamed:@"noavata.png"]];
            }
            
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_mode) {
        case FriendModeList:
        {
            return 44;
        }
            break;
        case RequestModeList:
        {
            return 60;
        }
            break;
            
        default:
            break;
    }
    return 44;
}

#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if ([cell isKindOfClass:[HHPanningTableViewCell class]]) {
		HHPanningTableViewCell *panningTableViewCell = (HHPanningTableViewCell*)cell;
		
		if ([panningTableViewCell isDrawerRevealed]) {
			return nil;
		}
	}
	
	return indexPath;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == RequestModeList) {
        return;
    }
    
    NSLog(@"LOG = %@", [[[[FriendsManager sharedManager] friendsList] objectAtIndex:indexPath.row] displayName]);
    
    Friend *f = [[[FriendsManager sharedManager] friendsList] objectAtIndex:indexPath.row];
    ChatViewController *chatVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    chatVC.friendChatting = f;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - ActionHeader

-(void) itemAction:(id)sender
{
    
    switch ([sender tag]) {
        case 1:
        {
            
            BOOL show = !self.actionHeaderView.titleLabel.hidden;
            [self.actionHeaderView expandPicker:show];
        }
            break;
        case 2:
        {
            self.actionHeaderView.titleLabel.text = @"Friends List";
            [self.actionHeaderView shrinkActionPicker];
            _mode = FriendModeList;
            [self reloadFriend];
        }
            break;
        case 3:
        {
            self.actionHeaderView.titleLabel.text = @"Friends Request";
           
            [self.actionHeaderView shrinkActionPicker];
            _mode = RequestModeList;
            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}



-(void) loadActionHeaderView
{
    self.actionHeaderView = [[DDActionHeaderView alloc] initWithFrame:self.view.bounds];
    self.actionHeaderView.titleLabel.text = @"Friends List";
    
    
    UIButton *mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mainButton.tag = 1;
    [mainButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    [mainButton setImage:[UIImage imageNamed:@"mainButton"] forState:UIControlStateNormal];
    mainButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    mainButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    mainButton.center = CGPointMake(25.0f, 25.0f);
    
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    friendsButton.tag = 2;
    [friendsButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    [friendsButton setImage:[UIImage imageNamed:@"friend-button"] forState:UIControlStateNormal];
    friendsButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    friendsButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    friendsButton.center = CGPointMake(75.0f, 25.0f);
    
    UIButton *contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    contactsButton.tag = 3;
    [contactsButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    [contactsButton setImage:[UIImage imageNamed:@"ContactsList"] forState:UIControlStateNormal];
    contactsButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    contactsButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    contactsButton.center = CGPointMake(125.0f, 25.0f);
	
    // Set action items, and previous items will be removed from action picker if there is any.
    self.actionHeaderView.items = [NSArray arrayWithObjects:mainButton, friendsButton, contactsButton, nil];
	
    [self.view addSubview:self.actionHeaderView];
}


#pragma mark -
#pragma mark HHPanningTableViewCellDelegate

- (void)panningTableViewCellDidTrigger:(HHPanningTableViewCell *)cell inDirection:(HHPanningTableViewCellDirection)direction
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom Action"
                                                    message:@"You triggered a custom action"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - DrawMenu Delegate
-(void) updateContact:(NSIndexPath *)indexPath
{
    NSLog(@"Update %@", indexPath);
    FriendInfoViewController *fivc = [[FriendInfoViewController alloc] initWithNibName:@"FriendInfoViewController" bundle:nil];
    
    fivc.currentFriend =  [[[FriendsManager sharedManager] friendsList] objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:fivc animated:YES];
}

-(void) sendMessageTo:(NSIndexPath *)indexPath
{
    NSLog(@"Chat %@", indexPath);
    ChatViewController *chatVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    chatVC.friendChatting = [[[FriendsManager sharedManager] friendsList] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
}

-(void) sendGiftTo:(NSIndexPath *)indexPath
{
//    NSLog(@"Gift %@", indexPath);
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    NSArray *controllers = [appDelegate.menuController _controllers];
//        [appDelegate.revealController setContentViewController: controllers[1][3]];
//    NSIndexPath *indexPathMenu = [NSIndexPath indexPathForRow:3 inSection:1];
//    [appDelegate.menuController._menuTableView selectRowAtIndexPath:indexPathMenu animated:YES scrollPosition:UITableViewScrollPositionBottom];
    
    currentFriend = [[[FriendsManager sharedManager] friendsList] objectAtIndex:indexPath.row];
    
    ModalPanelPickerView *modalPanel = [[ModalPanelPickerView alloc] initWithFrame:self.view.bounds title:@"Choose a gift" mode:ModalPickerGifts] ;
    modalPanel.onClosePressed = ^(UAModalPanel* panel) {
        // [panel hide];
        [panel hideWithOnComplete:^(BOOL finished) {
            [panel removeFromSuperview];
            currentFriend = nil;
            NSLog(@"CURRENT = nil");
        }];
        UADebugLog(@"onClosePressed block called from panel: %@", modalPanel);
    };
    
    ///////////////////////////////////////////
    //   Panel is a reference to the modalPanel
    modalPanel.onActionPressed = ^(UAModalPanel* panel) {
        UADebugLog(@"onActionPressed block called from panel: %@", modalPanel);
    };

    modalPanel.delegate = self;
    
    [self.view addSubview:modalPanel];
	
	///////////////////////////////////
	// Show the panel from the center of the button that was pressed
	[modalPanel showFromPoint:self.view.center];
    
}

-(void) removeContact:(NSIndexPath *)indexPath
{
    NSLog(@"Remove %@", indexPath);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete this contact" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
    currentIndexPath = indexPath;
}

#pragma mark - ActionSheet
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"Delete");
            
            Friend *cF = [[[FriendsManager sharedManager] friendsList ]objectAtIndex:currentIndexPath.row];
//            [[FriendsManager sharedManager] removeFriend:cF];
//            
////            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[UserManager sharedInstance] accID],@"sourceID",
                                    cF.fID, @"friendID",
                                    @"cancel_request", @"usage",
                                    nil];
            
            [[NKApiClient shareInstace] postPath:@"add_friend.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                id jsonObject = [[JSONDecoder decoder] objectWithData:responseObject];
                NSLog(@"%@", jsonObject);
                NSString *userID = [[UserManager sharedInstance] accID];
                [[FriendsManager sharedManager] loadFriendsFromURLbyUser: userID completion:^(BOOL success, NSError *error) {
                    [self performSelector:@selector(deleteContactCompleteWithBlock:) withObject:^{
                        [_tableView reloadData];
                    } afterDelay:0.5];
                }];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"HTTP ERROR : %@", error);
            }];

            currentIndexPath = nil;
            
            break;
        }
        case 1:
        {
            NSLog(@"Cancel");
            currentIndexPath = nil;
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - AlertAction

-(void) deleteContactCompleteWithBlock: (FinishBlock) reloadBlock
{
    EKNotifView *note = [[EKNotifView alloc] initWithNotifViewType:EKNotifViewTypeSuccess notifPosition:EKNotifViewPositionBottom notifTextStyle:EKNotifViewTextStyleTitle andParentView:self.view];
    [note changeTitleOfLabel:EKNotifViewLabelTypeTitle to:@"Unfriend successful !"];
    [note show];
    
    reloadBlock();
}

-(void) addFriendCompleteWithBlock: (FinishBlock) reloadBlock
{
    EKNotifView *note = [[EKNotifView alloc] initWithNotifViewType:EKNotifViewTypeSuccess notifPosition:EKNotifViewPositionBottom notifTextStyle:EKNotifViewTextStyleTitle andParentView:self.view];
    [note changeTitleOfLabel:EKNotifViewLabelTypeTitle to:@"Added a friend successful !"];
    [note show];
    
    reloadBlock();
}

#pragma mark - Notifications
-(void) sendGiftView:(NSNotification *)notification
{
    NSString *pathGift = notification.object;
    NSLog(@"GIFT = %@", pathGift);

    SendGiftViewController *sgvc = [[SendGiftViewController alloc] initWithNibName:@"SendGiftViewController" bundle:nil];
    sgvc.toFriend = currentFriend;
    sgvc.pathGift = pathGift;
    sgvc.isPresenting = YES;
    
    currentFriend = nil;
    UINavigationController *navSendGift = [[UINavigationController alloc] initWithRootViewController:sgvc];
    [self presentModalViewController:navSendGift animated:YES];
}

-(void) sendGiftToFriend: (NSNotification *) notificaion
{
    NSLog(@"Notification = %@", notificaion);
    
    MBProgressHUD *hud;
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    NSData *giftData = [NSData dataWithContentsOfFile:notificaion.object];
    [[FunctionObject sharedInstance] uploadGift:giftData withProgress:^(CGFloat progress) {
        hud.mode = MBProgressHUDModeDeterminate;
        hud.progress = progress;
    } completion:^(BOOL success, NSError *error, NSString *urlUpload) {
        
        [[FunctionObject sharedInstance] sendGift:urlUpload withParams:notificaion.userInfo completion:^(BOOL success, NSError *error) {
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"Send gift successful";
            [hud hide:YES afterDelay:0.5];
            
        }];
    }];

}


#pragma mark - UAModalDisplayPanelViewDelegate

// Optional: This is called before the open animations.
//   Only used if delegate is set.
- (void)willShowModalPanel:(UAModalPanel *)modalPanel {
	UADebugLog(@"willShowModalPanel called with modalPanel: %@", modalPanel);
}

// Optional: This is called after the open animations.
//   Only used if delegate is set.
- (void)didShowModalPanel:(UAModalPanel *)modalPanel {
	UADebugLog(@"didShowModalPanel called with modalPanel: %@", modalPanel);
}

// Optional: This is called when the close button is pressed
//   You can use it to perform validations
//   Return YES to close the panel, otherwise NO
//   Only used if delegate is set.
- (BOOL)shouldCloseModalPanel:(UAModalPanel *)modalPanel {
	UADebugLog(@"shouldCloseModalPanel called with modalPanel: %@", modalPanel);
	return YES;
}

// Optional: This is called when the action button is pressed
//   Action button is only visible when its title is non-nil;
//   Only used if delegate is set and not using blocks.
- (void)didSelectActionButton:(UAModalPanel *)modalPanel {
	UADebugLog(@"didSelectActionButton called with modalPanel: %@", modalPanel);
}

// Optional: This is called before the close animations.
//   Only used if delegate is set.
- (void)willCloseModalPanel:(UAModalPanel *)modalPanel {
	UADebugLog(@"willCloseModalPanel called with modalPanel: %@", modalPanel);
}

// Optional: This is called after the close animations.
//   Only used if delegate is set.
- (void)didCloseModalPanel:(UAModalPanel *)modalPanel {
	UADebugLog(@"didCloseModalPanel called with modalPanel: %@", modalPanel);
}

#pragma mark - FriendRequestDelegate
-(void) requestCell:(FriendRequestCell *)cell withState:(FriendType)state
{
    NSIndexPath *curPath = [self.tableView indexPathForCell:cell];
    NSDictionary *dictPerson = [self.listRequest objectAtIndex:curPath.row];
    
    [[FunctionObject sharedInstance] responeRequestWithUser:[[UserManager sharedInstance] accID] person:[dictPerson valueForKey:@"accID"] preRelationship:[dictPerson valueForKey:@"rsID"] andState:[NSString stringWithFormat:@"%i", state] completion:^(BOOL success, NSError *error) {
        [self refreshRequest];
    }];
    [self.listRequest removeObject:dictPerson];
    
}

-(void) refreshRequest
{
    [[FunctionObject sharedInstance] setNewBadgeWithValue:[_listRequest count] forView:self.actionHeaderView.titleLabel];
    [self.tableView reloadData];
}

@end
