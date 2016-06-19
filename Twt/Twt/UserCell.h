//
//  UserCell.h
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ACAccount;

@interface UserCell : UITableViewCell <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *followers;
@property (strong, nonatomic) IBOutlet UILabel *following;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSDictionary *user;

- (void)setUserDictionary:(NSDictionary *)user inViewController:(UITableViewController *)vc;
+ (CGFloat)calculateUserCellHeightWithUserDictionary:(NSDictionary *)user;

@end
