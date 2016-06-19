//
//  UserViewController.h
//  Twt
//
//  Created by Nattapong Mos on 7/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDetailCell.h"

@interface UserViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UserDetailCellDelegate>

@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) UIImage *avatarImage;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
