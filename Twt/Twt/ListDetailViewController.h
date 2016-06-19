//
//  ListDetailViewController.h
//  Twt
//
//  Created by Nattapong Mos on 25/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListDetailViewController : UITableViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSDictionary *listData;

@end
