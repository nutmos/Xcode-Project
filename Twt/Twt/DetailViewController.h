//
//  UserDetailViewController.h
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSInteger rowSelected;
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
