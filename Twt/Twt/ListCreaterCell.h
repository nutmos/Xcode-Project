//
//  ListCreaterCell.h
//  Twt
//
//  Created by Nattapong Mos on 24/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCreaterCell : UITableViewCell <UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *createrAvatar;
@property (nonatomic, strong) IBOutlet UILabel *listName;
@property (nonatomic, strong) IBOutlet UILabel *listCreater;
@property (nonatomic, strong) NSString *screenName;
- (void)setListDataDictionary:(NSDictionary *)listData inViewController:(UITableViewController *)vc tableView:(UITableView *)tableView;

@end
