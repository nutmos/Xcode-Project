//
//  TweetInListViewController.h
//  Twt
//
//  Created by Nattapong Mos on 24/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetViewController.h"
#import "TweetCell.h"

@interface TweetInListViewController : UITableViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, TweetViewControllerDelegate, TweetCellDelegate>

@property (strong, nonatomic) NSDictionary *listDetail;

@end
