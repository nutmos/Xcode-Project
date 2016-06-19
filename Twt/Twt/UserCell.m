//
//  UserCell.m
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "UserCell.h"
#import "UIImageView+Extension.h"
#import "AppDelegate.h"
#import "UIViewController+RequiredObject.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#define AVATAR_SIDE 60.0f

@interface UserCell ()

@property UITableViewController *vc;
@property id actionSheet;
@property AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *relationDict;

@end

@implementation UserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        return self;
    }
    else {
        return nil;
    }
}

+ (CGFloat)calculateUserCellHeightWithUserDictionary:(NSDictionary *)user {
    return 80.0f;
}

#pragma mark - Get Data Method
/*
- (void)postFollowUser:(NSString *)screenName {
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
}
*/
- (void)getRelationShipBetweenSource:(NSString *)source andTarget:(NSString *)target {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetFriendshipURL stringParameter:nil];
        NSDictionary *parameters = @{@"source_screen_name": source, @"target_screen_name": target};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *relationDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (relationDict.count && relationDict[@"errors"] == nil) {
                    self.relationDict = relationDict[@"relationship"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Get Relationship In UserCell Completed" object:nil];
                }
                else if (relationDict[@"errors"]) {
                    NSLog(@"error = %@", relationDict[@"errors"]);
                }
            }
            else {
                NSLog(@"%@",error.localizedDescription);
            }
        }];
    }
}

#pragma mark - User Interaction

- (void)tapAvatar:(UITapGestureRecognizer *)sender {
    self.vc.userSentToNextVC = self.user;
    self.vc.avatarSentToNextVC = self.avatar.image;
    [self.vc performSegueWithIdentifier:@"ToUser" sender:self];
}

- (void)longPressAvatar:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [sender locationInView:self.vc.view];
        self.vc.selectedIndexPath = [self.vc.tableView indexPathForRowAtPoint:point];
        self.vc.userSentToNextVC = self.user;
        self.vc.avatarSentToNextVC = self.avatar.image;
        NSString *user1 = self.appDelegate.currentAccount.username;
        NSString *user2 = self.vc.userSentToNextVC[@"screen_name"];
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
            [self getRelationShipBetweenSource:user1 andTarget:user2];
        }
    }
}

- (void)setUserDictionary:(NSDictionary *)user inViewController:(UITableViewController *)vc {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActionSheetAfterGetRelationship) name:@"Get Relationship In UserCell Completed" object:nil];
    NSDictionary *attributes = @{
        CallImageFileAttributeLink: [NSURL URLWithString:[user[@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]],
        CallImageFileAttributeUserID: user[@"id"]};
    [self setAvatarImage:[self.appDelegate callImageFileOption:CallImageFileOptionAvatar attributes:attributes]];
    self.vc = vc;
    self.user = user;
    self.name.text = [NSString stringWithFormat:@"%@ @%@", self.user[@"name"], self.user[@"screen_name"]];
    NSMutableAttributedString *attStr = [self.name.attributedText mutableCopy];
    NSRange screenNameRange = {attStr.length - ([self.user[@"screen_name"] length] + 1), [self.user[@"screen_name"] length] + 1};
    [attStr addAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor], NSFontAttributeName: [UIFont systemFontOfSize:14.0f]} range:screenNameRange];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterNoStyle;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.usesGroupingSeparator = YES;
    self.name.attributedText = [attStr copy];
    self.followers.text = [NSString stringWithFormat:@"Followers: %@", [numberFormatter stringFromNumber:(NSNumber *)user[@"followers_count"]]];
    self.following.text = [NSString stringWithFormat:@"Following: %@", [numberFormatter stringFromNumber:(NSNumber *)user[@"friends_count"]]];
    self.screenName = user[@"screen_name"];
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.screenName];
    // Tap Avatar Image
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.avatar addGestureRecognizer:tapGesture];
    // Long Press Avatar Image
    UILongPressGestureRecognizer *longPressAvatar = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAvatar:)];
    longPressAvatar.delegate = self;
    longPressAvatar.minimumPressDuration = 0.5;
    longPressAvatar.allowableMovement = 0;
    [self.avatar addGestureRecognizer:longPressAvatar];
}

- (void)setAvatarImage:(UIImage *)image {
    self.avatar.image = image;
    self.avatar.contentMode = UIViewContentModeScaleAspectFill;
    [self.avatar maskToCircleWithAvatarSide:AVATAR_SIDE];
}

#pragma mark - Action Sheet Delegate

- (void)updateActionSheetAfterGetRelationship {
    if ([self.actionSheet isKindOfClass:[UIActionSheet class]]) {
        for (id view in ((UIActionSheet *)self.actionSheet).subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                if ([self.relationDict[@"source"][@"followed_by"] boolValue] == YES) {
                    label.text = [NSString stringWithFormat:@"@%@ is following you.", self.relationDict[@"target"][@"screen_name"]];
                }
                else {
                    label.text = [NSString stringWithFormat:@"@%@ is not following you.", self.relationDict[@"target"][@"screen_name"]];
                }
                [label setNeedsDisplay];
            }
            else if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if ([button.titleLabel.text isEqualToString:@"Follow"]) {
                    if ([self.relationDict[@"source"][@"following"] boolValue] == YES) {
                        [button setTitle:@"Unfollow" forState:UIControlStateNormal];
                        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    }
                    button.enabled = YES;
                }
                else if ([button.titleLabel.text isEqualToString:@"Direct Message"]) {
                    if ([self.relationDict[@"source"][@"can_dm"] boolValue]) {
                        button.enabled = YES;
                    }
                }
                [button setNeedsDisplay];
            }
        }
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (id view in actionSheet.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *buttonView = (UIButton *)view;
            if ([buttonView.titleLabel.text isEqualToString:@"Follow"] ||
                [buttonView.titleLabel.text isEqualToString:@"Direct Message"]) {
                buttonView.enabled = NO;
            }
            else if ([buttonView.titleLabel.text isEqualToString:@"Unfollow"]) {
                [buttonView setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonStr = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonStr isEqualToString:@"View Profile"]) {
        [self.vc performSegueWithIdentifier:@"ToUser" sender:self];
    }
    else if ([buttonStr isEqualToString:@"Follow"]) {
        [self.appDelegate postFollowUser:self.vc.userSentToNextVC[@"screen_name"]];
    }
    else if ([buttonStr isEqualToString:@"Unfollow"]) {
        [self.appDelegate postUnfollowUser:self.vc.userSentToNextVC[@"screen_name"]];
    }
}

@end
