//
//  SendGiftViewController.m
//  CardLove-v1
//
//  Created by FOLY on 5/13/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "SendGiftViewController.h"
#import "UIColor+Hex.h"
#import "FunctionObject.h"
#import <QuartzCore/QuartzCore.h>

@interface SendGiftViewController ()

@end

@implementation SendGiftViewController

@synthesize cell = _cell;
@synthesize toFriend = _toFriend;
@synthesize pathGift = _pathGift;

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
    self.navigationItem.title = [NSString stringWithFormat:@"SendTo: %@", _toFriend.displayName];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    
    UIBarButtonItem* btnSend = [[UIBarButtonItem alloc]
           initWithTitle:NSLocalizedString(@"Send", @"")
           style:UIBarButtonItemStyleBordered
           target:self
           action:@selector(sendGift:)];
    self.navigationItem.rightBarButtonItem = btnSend;
    
     self.tableView.backgroundColor = [UIColor colorWithHex:0xE1E6EF];
    
    self.viewContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewContainer.layer.borderWidth = 3.0f;
    self.viewContainer.layer.cornerRadius = 10.0f;
    
    self.txtGiftName.text = [[_pathGift lastPathComponent] uppercaseString];
    
    if (self.datePicker == nil) {
        self.datePicker = [[UIDatePicker alloc] init];
        [self.datePicker addTarget:self action:@selector(birthdayDatePickerChanged:) forControlEvents:UIControlEventValueChanged];
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        NSDate *currentDate = [NSDate date];
        
        [self.datePicker setDate:currentDate animated:NO];
    }
    
    self.txtDateChoose.inputView = self.datePicker;

}

- (void)birthdayDatePickerChanged:(id)sender
{
     self.txtDateChoose.text = [[FunctionObject sharedInstance] stringFromDateTime:self.datePicker.date];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setViewStyle];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
    [self setViewStyle];
    [[self.cell viewWithTag:111] becomeFirstResponder];
}

- (void)setViewStyle{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHex:0x2C4287];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setCell:nil];
    [self setPathGift:nil];
    [self setToFriend:nil];
    [self setViewContainer:nil];
    [self setBtnPhoto:nil];
    [self setTxtTitle:nil];
    [self setTxtDate:nil];
    [self setTxtGiftName:nil];
    [self setTxtDateChoose:nil];
    [super viewDidUnload];
}

-(void) dismissView: (id) sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) sendGift:(id) sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - TableView
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self.cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  self.cell.bounds.size.height;
}



@end