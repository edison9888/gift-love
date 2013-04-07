//
//  StoredCardsViewController.m
//  CardLove-v1
//
//  Created by FOLY on 2/25/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "StoredCardsViewController.h"
#import "SSCollectionView.h"
#import "SSCollectionViewItem.h"
#import "CollectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@interface StoredCardsViewController ()

@end

@implementation StoredCardsViewController

@synthesize listGifts = _listGifts;

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
    _listGifts = [[NSMutableArray alloc] init];
}

-(void) viewDidUnload
{
    [self setListGifts:nil];
    [super viewDidUnload];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *pathProjects = [self dataFilePath:kGift];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *subDirs = [fileMgr contentsOfDirectoryAtPath:pathProjects error:&error];
    
    _listGifts = [NSMutableArray arrayWithArray:subDirs];
    if ([_listGifts count] >0) {
        if ([[_listGifts objectAtIndex:0] isEqual:@".DS_Store"]) {
            [_listGifts removeObjectAtIndex:0];
        }
    }
    
    [self.collectionView reloadData];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) dataFilePath: (NSString *) comp
{
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    return  [docsDir stringByAppendingPathComponent:comp];
}

#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
	return 1;
}


- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
	return [_listGifts count];
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
	static NSString *const itemIdentifier = @"itemIdentifier";
    
    //    SSCollectionViewItem *item  = (SSCollectionViewItem *)[aCollectionView dequeueReusableItemWithIdentifier:itemIdentifier];
    //	if(!item)
    //    {
    //        item = [[SSCollectionViewItem alloc] initWithStyle:SSCollectionViewItemStyleSubtitle reuseIdentifier:itemIdentifier];
    //
    //
    //        item.layer.borderColor = [UIColor blackColor].CGColor;
    //        item.layer.borderWidth = 2.0f;
    //        item.layer.cornerRadius = 10.0f;
    //
    //        item.layer.masksToBounds = NO;
    //        item.layer.shadowColor = [UIColor blackColor].CGColor;
    //        item.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    //        item.layer.shadowOpacity = 1.0f;
    //        item.layer.shadowRadius = 4.5f;
    //        item.layer.shadowPath = [UIBezierPath bezierPathWithRect:item.bounds].CGPath;
    //
    //    }
    //
    //    item.textLabel.frame  = CGRectMake(90, 36, 66, 21);
    //    item.textLabel.text = @"FOLY MEN";
    //    item.textLabel.backgroundColor = [UIColor clearColor];
    //
    //    item.imageView.frame = CGRectMake(10, 10, 60, 80);
    //    item.imageView.image = [UIImage imageNamed:@"list-item-cover-men1.png"];
    //
    //    item.imageView.layer.masksToBounds = NO;
    //    item.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    //    item.imageView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    //    item.imageView.layer.shadowOpacity = 1.0f;
    //    item.imageView.layer.shadowRadius = 4.5f;
    //    item.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:item.imageView.bounds].CGPath;
    
    SSCollectionViewItem *item = [aCollectionView dequeueReusableItemWithIdentifier:itemIdentifier];
    if(!item)
    {
        item = (SSCollectionViewItem *)[[[NSBundle mainBundle] loadNibNamed:@"SSCollectionViewItem" owner:self options:nil] objectAtIndex:0];
        item.reuseIdentifier = [itemIdentifier copy];
    }
    NSString *gift = [_listGifts objectAtIndex:indexPath.row];
    item.titleLabel.text = gift;
    
	return item;
}

- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
	
    //    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
    //	header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //	header.text = [NSString stringWithFormat:@"Section %i", section + 1];
    //	header.shadowColor = [UIColor whiteColor];
    //	header.shadowOffset = CGSizeMake(0.0f, 1.0f);
    //	header.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    
	//return header;
    
    CollectionHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:@"CollectionHeaderView" owner:self options:nil] objectAtIndex:0];
    header.lbTitle.text = [NSString stringWithFormat:@"Favorite"];
    
    return header;
}


#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
	return CGSizeMake(150, 120);
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
    NSString *gift = [_listGifts objectAtIndex:indexPath.row];
    
    CreateCardViewController *ccvc = [[CreateCardViewController alloc] initWithNibName:@"CreateCardViewController" bundle:nil];
    ccvc.giftName = gift;
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ccvc animated:YES];
    self.tabBarController.hidesBottomBarWhenPushed = NO;
}


- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
	return 40.0f;
}



@end
