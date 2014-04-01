//
//  NewTweetViewController.h
//  Twt
//
//  Created by Nattapong Mos on 26/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTweetViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) UIViewController *fromVc;
@property (nonatomic, strong) NSString *segueID;

@end
