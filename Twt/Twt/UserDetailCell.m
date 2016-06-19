//
//  UserDetailCell.m
//  Twt
//
//  Created by Nattapong Mos on 7/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "UserDetailCell.h"
#import "UIImageView+Extension.h"
#import "AppDelegate.h"
#define AVATAR_SIDE 60

@interface UserDetailCell ()

@property (strong, nonatomic) NSURL *avatarLink;
@property (strong, nonatomic) NSURL *bannerLink;

@end

@implementation UserDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)tapAvatar:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(userDetailCell:tapAvatarImage:link:)]) {
        [self.delegate userDetailCell:self tapAvatarImage:self.avatar.image link:self.avatarLink];
    }
}

- (void)setUserDetailDictionary:(NSDictionary *)userDetail avatarImage:(UIImage *)image {
    if (userDetail == nil) {
        return;
    }
    else if (userDetail[@"User Not Found"]) {
        NSLog(@"user not found in userdetailcell");
        self.username.text = @"";
        self.fullname.text = @"User Not Found";
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (image != nil) {
        [self setAvatarImage:image];
    }
    else {
        NSDictionary *attributes = @{
            CallImageFileAttributeLink: [NSURL URLWithString:[userDetail[@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]],
            CallImageFileAttributeUserID: userDetail[@"id"]};
        [self setAvatarImage:[appDelegate callImageFileOption:CallImageFileOptionAvatar attributes:attributes]];
    }
    self.avatarLink = [NSURL URLWithString:[userDetail[@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]];
    NSString *profileBannerURL = userDetail[@"profile_banner_url"];
    self.bannerLink = [NSURL URLWithString:profileBannerURL];
    if (profileBannerURL) {
        NSDictionary *attributes = @{
            CallImageFileAttributeLink: [NSURL URLWithString:userDetail[@"profile_banner_url"]],
            CallImageFileAttributeUserID: userDetail[@"id"]};
        self.cover.image = [appDelegate callImageFileOption:CallImageFileOptionProfileBanner attributes:attributes];
    }
    self.cover.contentMode = UIViewContentModeScaleAspectFill;
    self.cover.layer.backgroundColor = [UIColor blackColor].CGColor;
    self.cover.layer.opacity = 0.7f;
    NSLog(@"screen name = %@", userDetail[@"screen_name"]);
    if (userDetail[@"screen_name"] == nil) {
        self.username.text = @"@";
    }
    else {
        self.username.text = [NSString stringWithFormat:@"@%@", userDetail[@"screen_name"]];
    }
    self.username.font = [UIFont systemFontOfSize:17.0f];
    self.username.numberOfLines = 1;
    self.fullname.text = userDetail[@"name"];
    self.fullname.font = [UIFont boldSystemFontOfSize:22.0f];
    self.fullname.numberOfLines = 1;
    // Tap Avatar Image
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.avatar addGestureRecognizer:tapGesture];
}

- (void)setAvatarImage:(UIImage *)image {
    self.avatar.image = image;
    [self.avatar setContentMode:UIViewContentModeScaleAspectFill];
    [self.avatar maskToCircleWithAvatarSide:AVATAR_SIDE];
}

@end
