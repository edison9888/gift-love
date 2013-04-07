//
//  GiftElementsViewController.m
//  CardLove-v1
//
//  Created by FOLY on 4/7/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "GiftElementsViewController.h"

@interface GiftElementsViewController ()
{
    id _selectedItem;
}
@end

@implementation GiftElementsViewController

@synthesize delegate;
@synthesize tableView = _tableView;
@synthesize dictDataSource = _dictDataSource;

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
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelViewController)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.title = @"Element for card";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self prepareDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cancelViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) doneAction
{
    [self.delegate giftElementsViewControllerDidSelected:_selectedItem];
    [self dismissModalViewControllerAnimated:YES];
}

-(NSMutableDictionary *) prepareDataSource
{
    _dictDataSource = [[NSMutableDictionary alloc] init];
    
    NSArray *arFlowers = [NSArray arrayWithObjects:
                          @"Flower_divider.gif",
                          @"Flower_vine.gif",
                          @"flower02.gif",
                          @"flower01.gif",
                          @"flower32.gif", nil];
    NSArray *arXmas = [NSArray arrayWithObjects:
                          @"anixmas.gif",
                           nil];
    
    [_dictDataSource setObject:arFlowers forKey:@"Flowers"];
    [_dictDataSource setObject:arXmas forKey:@"XMas"];
    
    return _dictDataSource;
}

#pragma mark - TableView DataSource & Delegate
-(NSInteger)  numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_dictDataSource allKeys] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = [[_dictDataSource allKeys] objectAtIndex:section];
    return key;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[_dictDataSource allKeys] objectAtIndex:section];
    NSArray *arr = [_dictDataSource valueForKey:key];
    return ceil([arr count]/4.0f);
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoThumbnailsCell";
    
    GifThumbnailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[GifThumbnailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger section = indexPath.section;
    NSString *key = [[_dictDataSource allKeys] objectAtIndex:section];
    NSArray *value = [_dictDataSource valueForKey:key];
    
    int startIndex = indexPath.row * 4;
    int endIndex = startIndex + 4;
    if (endIndex > [value count])
        endIndex = [value count];
    
    for (int i = startIndex; i < endIndex; i++) {
       
        NSString *imageName = [value objectAtIndex:i];
        UIImage *image = [OLImage imageNamed:imageName];

        GifThumbnailView *gtv = [cell gifViewByTag:(endIndex - 1 - i)];
        [gtv setImage:image];
        gtv.hidden = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
    return view;
}
#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}




- (void)viewDidUnload {
    [self setTableView:nil];
    [self setDictDataSource:nil];
    [super viewDidUnload];
}
@end
