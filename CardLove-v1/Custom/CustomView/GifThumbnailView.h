//
//  GifThumbnailView.h
//  CardLove-v1
//
//  Created by FOLY on 4/7/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MacroDefine.h"


@interface GifThumbnailView : OLImageView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *imageName;

-(void) selected: (BOOL) select;

@end
