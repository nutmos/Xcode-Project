//
//  ImageViewController.h
//  Twt
//
//  Created by Nattapong Mos on 9/7/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(NSInteger, ImageViewOption) {
    ImageViewOptionAvatar,
    ImageViewOptionImageWithEntities,
};

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *imageLink;
@property (strong, nonatomic) NSURL *shareLink;

@end
