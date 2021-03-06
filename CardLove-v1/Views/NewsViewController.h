//
//  NewsViewController.h
//  CardLove-v1
//
//  Created by FOLY on 2/24/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCollectionViewController.h"
#import "NKApiClient.h"
#import "AFNetworking.h"
#import "JSONKit.h"
#import "UserManager.h"
#import "FunctionObject.h"
#import "MBProgressHUD.h"
#import "HMGLTransitionManager.h"
#import "DoorsTransition.h"
#import "ViewGiftViewController.h"
#import "FriendsManager.h"
#import "CreateCardViewController.h"
#import "ChatViewController.h"
#import "MacroDefine.h"

@interface NewsViewController : SSCollectionViewController<UIAlertViewDelegate, ViewGiftControllerDelegate, SendGiftViewControllerDelegate>

@property (strong, nonatomic) ActionGiftBlock actionBlock;
@property (unsafe_unretained, nonatomic) NSMutableArray *sentArray;
@property (unsafe_unretained, nonatomic) NSMutableArray *recieveArray;


@end
