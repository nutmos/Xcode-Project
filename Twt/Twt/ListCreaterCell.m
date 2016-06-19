//
//  ListCreaterCell.m
//  Twt
//
//  Created by Nattapong Mos on 24/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "ListCreaterCell.h"
#import "UIImageView+Extension.h"
#import "AppDelegate.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "UIViewController+RequiredObject.h"
#define AVATAR_SIDE 60.0f

@interface ListCreaterCell ()

@property UITableViewController *vc;
@property id actionSheet;
@property AppDelegate *appDelegate;
@property UITableView *tableView;

@end

@implementation ListCreaterCell

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

#pragma mark - Get Data Method

/*- (void)postFollowUser:(NSString *)screenName {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostFollowUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": screenName, @"follow": @"true"};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            //NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        }];
    }
}

- (void)postUnfollowUser:(NSString *)screenName {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostUnfollowUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": screenName};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            //NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        }];
    }
}*/

- (void)getRelationShipBetweenUser1:(NSString *)user1ScreenName andUser2:(NSString *)user2ScreenName {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetFriendshipURL stringParameter:nil];
        NSDictionary *parameters = @{@"source_screen_name": user1ScreenName, @"target_screen_name": user2ScreenName};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSDictionary *relationDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error][@"relationship"];
            if (relationDict.count && relationDict[@"error"] == nil) {
                if ([self.actionSheet isKindOfClass:[UIActionSheet class]]) {
                    for (id view in ((UIActionSheet *)self.actionSheet).subviews) {
                        if ([view isKindOfClass:[UILabel class]]) {
                            UILabel *label = (UILabel *)view;
                            if ([relationDict[@"source"][@"followed_by"] boolValue] == YES) {
                                label.text = [NSString stringWithFormat:@"@%@ is following you.", user2ScreenName];
                            }
                            else {
                                label.text = [NSString stringWithFormat:@"@%@ is not following you.", user2ScreenName];
                            }
                            [label setNeedsDisplay];
                        }
                        else if ([view isKindOfClass:[UIButton class]]) {
                            UIButton *button = (UIButton *)view;
                            if ([button.titleLabel.text isEqualToString:@"Follow"]) {
                                if ([relationDict[@"source"][@"following"] boolValue] == YES) {
                                    [button setTitle:@"Unfollow" forState:UIControlStateNormal];
                                    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                }
                                
                                button.enabled = YES;
                            }
                            else if ([button.titleLabel.text isEqualToString:@"Direct Message"]) {
                                if ([relationDict[@"source"][@"can_dm"] boolValue]) {
                                    button.enabled = YES;
                                }
                            }
                            [button setNeedsDisplay];
                        }
                    }
                }
            }
            else {
                NSLog(@"%@",error.localizedDescription);
            }
        }];
    }
}

#pragma mark - User Interaction

- (void)tapListNameLabel:(UITapGestureRecognizer *)sender {
    self.vc.selectedRowNumber = @-1;
    [self.vc performSegueWithIdentifier:@"ToTweetInList" sender:self];
}

- (void)tapAvatar:(UITapGestureRecognizer *)sender {
    self.vc.screenNameSentToNextVC = self.screenName;
    self.vc.avatarSentToNextVC = self.createrAvatar.image;
    [self.vc performSegueWithIdentifier:@"ToUser" sender:self];
}

- (void)longPressAvatar:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.vc.selectedRowNumber = @-1;
        self.vc.screenNameSentToNextVC = self.screenName;
        self.vc.avatarSentToNextVC = self.createrAvatar.image;
        NSString *user1 = self.appDelegate.currentAccount.username;
        NSString *user2 = self.vc.screenNameSentToNextVC;
        if ([user1 isEqualToString:user2]) {
            self.actionSheet = [self.appDelegate getActionSheetOption:GetActionSheetOptionLongPressNameOfAuthenticatedUser attributes:@{GetActionSheetAttributeDelegate: self, GetActionSheetAttributeViewController: self.vc}];
            if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
                [self.vc presentViewController:self.actionSheet animated:YES completion:nil];
            }
            else {
                [self.actionSheet showInView:self.vc.view];
            }
        }
        else {
            self.actionSheet = [self.appDelegate getActionSheetOption:GetActionSheetOptionLongPressNameOfUser attributes:@{GetActionSheetAttributeDelegate: self, GetActionSheetAttributeViewController: self.vc}];
            if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
                [self.vc presentViewController:self.actionSheet animated:YES completion:nil];
            }
            else {
                [self.actionSheet showInView:self.vc.view];
            }
            [self getRelationShipBetweenUser1:user1 andUser2:user2];
        }
    }
}

#pragma mark - Action Sheet Delegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (id view in actionSheet.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *buttonView = (UIButton *)view;
            if ([buttonView.titleLabel.text isEqualToString:@"Follow"] ||
                [buttonView.titleLabel.text isEqualToString:@"Direct Message"]) {
                buttonView.enabled = NO;
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonString = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonString isEqualToString:@"View Profile"]) {
        [self.vc performSegueWithIdentifier:@"ToUser" sender:self];
    }
    else if ([buttonString isEqualToString:@"Follow"]) {
        [self.appDelegate postFollowUser:self.vc.userSentToNextVC[@"screen_name"]];
    }
    else if ([buttonString isEqualToString:@"Unfollow"]) {
        [self.appDelegate postUnfollowUser:self.vc.userSentToNextVC[@"screen_name"]];
    }
}

#pragma mark - Set Data

- (void)setListDataDictionary:(NSDictionary *)listData inViewController:(UITableViewController *)vc tableView:(UITableView *)tableView {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.tableView = tableView;
    self.vc = vc;
    NSDictionary *user = listData[@"user"];
    self.screenName = user[@"screen_name"];
    NSDictionary *attributes = @{
        CallImageFileAttributeUserID: listData[@"user"][@"id"],
        CallImageFileAttributeLink: [NSURL URLWithString:[listData[@"user"][@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]]};
    [self setAvatarImage:[self.appDelegate callImageFileOption:CallImageFileOptionAvatar attributes:attributes]];
    self.listCreater.text = [@"Created by " stringByAppendingString:user[@"name"]];
    self.listName.text = listData[@"name"];
    // Tap Avatar Image
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.createrAvatar addGestureRecognizer:tapGesture];
    // Long Press Avatar Image
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAvatar:)];
    longPressGesture.delegate = self;
    longPressGesture.minimumPressDuration = 0.5;
    longPressGesture.allowableMovement = 0;
    [self.createrAvatar addGestureRecognizer:longPressGesture];
    // Tap List Name Label
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapListNameLabel:)];
    tapGesture2.delegate = self;
    tapGesture2.numberOfTapsRequired = 1;
    [self.listName addGestureRecognizer:tapGesture2];
}

- (void)setAvatarImage:(UIImage *)image {
    self.createrAvatar.image = image;
    self.createrAvatar.contentMode = UIViewContentModeScaleAspectFill;
    [self.createrAvatar maskToCircleWithAvatarSide:AVATAR_SIDE];
}

@end
