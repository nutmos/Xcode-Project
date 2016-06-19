//
//  TimelineViewController.h
//  Twt
//
//  Created by Nattapong Mos on 16/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetViewController.h"
#import "TweetCell.h"

@interface TimelineViewController : UITableViewController <UIActionSheetDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIScrollViewDelegate, TweetViewControllerDelegate, TweetCellDelegate>

@end
