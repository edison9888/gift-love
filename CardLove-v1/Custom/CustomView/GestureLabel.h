//
//  GestureLabel.h
//  CardLove-v1
//
//  Created by FOLY on 3/20/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+dynamicSizeMe.h"
#import <QuartzCore/QuartzCore.h>

@interface GestureLabel : UILabel <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *resizeImage;
@property (strong, nonatomic) UIGestureRecognizer *panRecognizer;

-(void) labelSelected;
-(void) labelDeselected;

@end