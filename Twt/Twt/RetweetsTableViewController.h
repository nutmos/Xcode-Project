//
//  RetweetsTableViewController.h
//  Twt
//
//  Created by Nattapong Mos on 10/6/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetViewController.h"
#import "TweetCell.h"

@interface RetweetsTableViewController : UITableViewController <TweetViewControllerDelegate,TweetCellDelegate>

@end
