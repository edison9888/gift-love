//
//  ModalPanelPickerView.h
//  CardLove-v1
//
//  Created by FOLY on 4/19/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "UATitledModalPanel.h"
#import "MacroDefine.h"
#import "FriendsManager.h"
#import "FunctionObject.h"

typedef enum {
    ModalPickerGifts,
    ModalPickerFriends,
    ModalPickerFriendsToSend
}ModalPickerMode;

@class ModalPanelPickerView;
@protocol ModalPanelDelegate <UAModalPanelDelegate>

@optional
-(void) modalPanel:(ModalPanelPickerView *)panelView didAddFriendToSendGift:(Friend *)sF;

@end

@interface ModalPanelPickerView : UATitledModalPanel <UITableViewDataSource,UITableViewDelegate, UAModalPanelDelegate>

@property (unsafe_unretained, nonatomic) id<ModalPanelDelegate> delegate;
@property (unsafe_unretained, nonatomic) id <UAModalPanelDelegate> delegate2;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (nonatomic) ModalPickerMode mode;
@property (strong, nonatomic) NSMutableArray *result;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title mode: (ModalPickerMode) mode;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title mode: (ModalPickerMode) mode subArray:(NSArray *) array;

@end
