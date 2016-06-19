//
//  ListCell.m
//  Twt
//
//  Created by Nattapong Mos on 18/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "ListCell.h"
#import "UIImageView+Extension.h"
#import "UIViewController+RequiredObject.h"
#import "AppDelegate.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#define AVATAR_SIDE 60.0f
#define DESCRIPTION_WIDTH 212.0f

@interface ListCell ()

@property UITableViewController *vc;
@property id actionSheet;
@property AppDelegate *appDelegate;

@end

@implementation ListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CGFloat)descriptionWidth {
    return DESCRIPTION_WIDTH;
}

+ (CGFloat)calculateListCellHeightWithListDictionary:(NSDictionary *)list {
    NSString *descriptionText = list[@"description"];
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 212.0f, 31.0f)];
    descriptionLabel.text = descriptionText;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.adjustsFontSizeToFitWidth = NO;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont systemFontOfSize:14.0f];
    [descriptionLabel sizeToFit];
    return descriptionLabel.frame.size.height + 130.0f;
}

#pragma mark - Get Data Method

- (void)getRelationShipBetweenSource:(NSString *)source andTarget:(NSString *)target {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetFriendshipURL stringParameter:nil];
        NSDictionary *parameters = @{@"source_screen_name": source, @"target_screen_name": target};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *relationDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([relationDict isKindOfClass:[NSDictionary class]]) {
                    if (relationDict.count && relationDict[@"errors"] == nil) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"Get Relationship In ListCell Completed" object:nil userInfo:@{@"relationship": relationDict[@"relationship"]}];
                    }
                    else if (relationDict[@"errors"]) {
                        NSLog(@"error = %@", relationDict[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@",[error localizedDescription]);
            }
        }];
    }
}

#pragma mark - User Interaction

- (void)tapAvatar:(UITapGestureRecognizer *)sender {
    self.vc.userSentToNextVC = self.userCreaterDetail;
    self.vc.avatarSentToNextVC = self.avatar.image;
    [self.vc performSegueWithIdentifier:@"ToUser" sender:self];
}

- (void)longPressAvatar:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.vc.userSentToNextVC = self.userCreaterDetail;
        self.vc.avatarSentToNextVC = self.avatar.image;
        NSString *user1 = self.appDelegate.currentAccount.username;
        NSString *user2 = self.vc.userSentToNextVC[@"screen_name"];
        if ([user1 isEqualToString:user2]) {
            id actionSheet = [self.appDelegate getActionSheetOption:GetActionSheetOptionLongPressNameOfAuthenticatedUser attributes:@{GetActionSheetAttributeDelegate: self, GetActionSheetAttributeViewController: self.vc}];
            if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
                [self.vc presentViewController:actionSheet animated:YES completion:nil];
            }
            else {
                [actionSheet showInView:self.vc.view];
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

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAvatarImage:(UIImage *)image {
    self.avatar.image = image;
    self.avatar.contentMode = UIViewContentModeScaleAspectFill;
    [self.avatar maskToCircleWithAvatarSide:AVATAR_SIDE];
}

#pragma mark - Set Data

- (void)setListDataDictionary:(NSDictionary *)listData inViewController:(UITableViewController *)vc {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActionSheetAfterGetRelationship:) name:@"Get Relationship In ListCell Completed" object:nil];
    self.vc = vc;
    self.userCreaterDetail = listData[@"user"];
    self.listName.text = listData[@"name"];
    NSDictionary *attributes = @{
        CallImageFileAttributeLink: [NSURL URLWithString:[listData[@"user"][@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]],
        CallImageFileAttributeUserID: listData[@"user"][@"id"]};
    [self setAvatarImage:[self.appDelegate callImageFileOption:CallImageFileOptionAvatar attributes:attributes]];
    self.creater.text = self.userCreaterDetail[@"name"];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterNoStyle;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.usesGroupingSeparator = YES;
    self.members.text = [[numberFormatter stringFromNumber:(NSNumber *)listData[@"member_count"]] stringByAppendingString:@" members"];
    self.descriptionLabel.text = listData[@"description"];
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.descriptionLabel.adjustsFontSizeToFitWidth = NO;
    self.descriptionLabel.numberOfLines = 0;
    [self.descriptionLabel setNeedsDisplay];
    self.listDetail = listData;
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

#pragma mark - Action Sheet Delegate

- (void)updateActionSheetAfterGetRelationship:(NSNotification *)notification {
    NSDictionary *relationship = notification.userInfo[@"relationship"];
    if ([self.actionSheet isKindOfClass:[UIActionSheet class]]) {
        for (id view in ((UIActionSheet *)self.actionSheet).subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                if ([relationship[@"source"][@"followed_by"] boolValue] == YES) {
                    label.text = [NSString stringWithFormat:@"@%@ is following you.", relationship[@"target"][@"screen_name"]];
                }
                else {
                    label.text = [NSString stringWithFormat:@"@%@ is not following you.", relationship[@"target"][@"screen_name"]];
                }
                [label setNeedsDisplay];
            }
            else if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if ([button.titleLabel.text isEqualToString:@"Follow"]) {
                    if ([relationship[@"source"][@"following"] boolValue] == YES) {
                        [button setTitle:@"Unfollow" forState:UIControlStateNormal];
                        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    }
                    button.enabled = YES;
                }
                else if ([button.titleLabel.text isEqualToString:@"Direct Message"]) {
                    if ([relationship[@"source"][@"can_dm"] boolValue]) {
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

@end
