//
//  UserDetailCell.h
//  Twt
//
//  Created by Nattapong Mos on 7/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserDetailCell;

@protocol UserDetailCellDelegate <NSObject>

- (void)userDetailCell:(UserDetailCell *)cell tapAvatarImage:(UIImage *)avatarImage link:(NSURL *)link;

@end

@interface UserDetailCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UIImageView *cover;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *fullname;
@property (strong, nonatomic) IBOutlet id<UserDetailCellDelegate> delegate;

- (void)setAvatarImage:(UIImage *)image;
- (void)setUserDetailDictionary:(NSDictionary *)userDetail avatarImage:(UIImage *)image;

@end
