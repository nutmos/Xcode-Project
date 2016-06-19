//
//  UserViewController.m
//  Twt
//
//  Created by Nattapong Mos on 7/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(NSInteger, UpdateFriendship) {
    UpdateFriendshipGetNotifications,
    UpdateFriendshipStopNotifications,
    UpdateFriendshipGetRetweets,
    UpdateFriendshipStopRetweets
};

#import "UserViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "NewTweetViewController.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import "UIViewController+RequiredObject.h"
#import "EditProfileViewController.h"
#import "ImageViewController.h"

@interface UserViewController ()

@property (strong, nonatomic) NSDictionary *thisUserDetail;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic) NewTweetType newTweetType;
@property (nonatomic) NSInteger rowSelected;
@property (strong, nonatomic) NSDictionary *relation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *composeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *replyButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moreOptionsButton;
@property NSString *userScreenName;

@end

@implementation UserViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableMoreOptionButton) name:@"Get Relation Complete" object:nil];
    if (self.backBarButtonItemTitle != nil) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.userScreenName = self.appDelegate.currentAccount.username;
    if (self.screenName == nil) {
        self.screenName = self.userScreenName;
    }
    if ([self.screenName isEqualToString:self.userScreenName]) {
        self.navigationItem.rightBarButtonItems = @[self.composeButton, self.moreOptionsButton];
    }
    else {
        self.moreOptionsButton.enabled = NO;
        [self getFriendshipForSource:self.userScreenName target:self.screenName];
        self.navigationItem.rightBarButtonItems = @[self.replyButton, self.moreOptionsButton];
    }
    self.moreOptionsButton.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0, -20);
    self.navigationItem.title = self.screenName;
    [self getDataForUserScreenName:self.screenName];
}

- (void)enableMoreOptionButton {
    self.moreOptionsButton.enabled = YES;
}

#pragma mark - Get Data Method

- (void)postReportSpam:(NSString *)user {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostReportSpamURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": self.screenName};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.thisUserDetail = data;
                }
                else if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postUnblockUser:(NSString *)user {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostDestroyBlockURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": user};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.thisUserDetail = data;
                }
                else if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postBlockUser:(NSString *)user {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostCreateBlockURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": user};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.thisUserDetail = data;
                }
                else if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postFollowUser:(NSString *)user {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostFollowUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": user, @"follow": @"true"};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.thisUserDetail = data;
                }
                else if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postUnfollowUser:(NSString *)user {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostUnfollowUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": user};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.thisUserDetail = data;
                }
                else if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getFriendshipForSource:(NSString *)source target:(NSString *)target {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetFriendshipURL stringParameter:nil];
        NSDictionary *parameters = @{@"source_screen_name": source, @"target_screen_name": target};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.relation = data;
                    self.moreOptionsButton.enabled = YES;
                    //[self enableMoreOptionButton];
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Get Relation Complete" object:nil];
                }
                else if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postUpdateFriendshipWithUserScreenName:(NSString *)user option:(UpdateFriendship)option {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostUpdateFriendshipURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == UpdateFriendshipGetNotifications) {
            parameters = @{@"screen_name": self.screenName, @"device": @"true"};
        }
        else if (option == UpdateFriendshipGetRetweets) {
            parameters = @{@"screen_name": self.screenName, @"device": @"false"};
        }
        else if (option == UpdateFriendshipStopNotifications) {
            parameters = @{@"screen_name": self.screenName, @"retweets": @"true"};
        }
        else if (option == UpdateFriendshipStopRetweets) {
            parameters = @{@"screen_name": self.screenName, @"retweets": @"false"};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.relation = data;
                }
                else if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postUnmuteUserScreenName:(NSString *)user {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostUnmuteUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": user};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data count] && data[@"errors"] == nil) {
                    self.thisUserDetail = data;
                }
                else if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postMuteUserScreenName:(NSString *)user {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostMuteUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": user};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.thisUserDetail = data;
                }
                if (data[@"errors"]) {
                    NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getDataForUserScreenName:(NSString *)screenName {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetUserDataURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": screenName};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (data.count && data[@"errors"] == nil) {
                    self.thisUserDetail = data;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
                else if (data[@"errors"]) {
                    if (((NSNumber *)data[@"errors"][0][@"code"]).integerValue == 34) {
                        self.thisUserDetail = @{@"User Not Found": @"User Not Found"};
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                    else NSLog(@"error = %@", data[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - Press Button

- (IBAction)didMoreOptionsButtonPressed:(id)sender {
    if ([self.screenName isEqualToString:self.userScreenName]) {
        if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:self.userScreenName message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[self.appDelegate cancelAlertAction]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Edit Profile" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self performSegueWithIdentifier:@"ToEditProfile" sender:self];
            }]];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.userScreenName delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Profile", nil];
            [actionSheet showInView:self.view];
        }
    }
    else {
        NSDictionary *relationSource = self.relation[@"relationship"][@"source"];
        if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:self.screenName message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[self.appDelegate cancelAlertAction]];
            UIAlertAction *action;
            if ([self.thisUserDetail[@"protected"] boolValue] && [self.thisUserDetail[@"follow_request_sent"] boolValue]) {
                action = [UIAlertAction actionWithTitle:@"Requested" style:UIAlertActionStyleDefault handler:nil];
                action.enabled = NO;
            }
            else {
                if ([self.thisUserDetail[@"following"] boolValue]) {
                    action = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                        [self postUnfollowUser:self.screenName];
                    }];
                }
                else {
                    action = [UIAlertAction actionWithTitle:@"Follow" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self postFollowUser:self.screenName];
                    }];
                }
            }
            [actionSheet addAction:action];
            UIAlertAction *action2;
            if ([relationSource[@"blocking"] boolValue]) {
                action2 = [UIAlertAction actionWithTitle:@"Unblock" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self postUnblockUser:self.screenName];
                }];
            }
            else {
                action2 = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self postBlockUser:self.screenName];
                }];
            }
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Report Spam" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self postReportSpam:self.screenName];
            }]];
            if (relationSource[@"muting"] != nil) {
                UIAlertAction *action;
                if ([self.relation[@"relationship"][@"source"][@"muting"] boolValue]) {
                    action = [UIAlertAction actionWithTitle:@"Unmute" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self postUnmuteUserScreenName:self.screenName];
                    }];
                }
                else {
                    action = [UIAlertAction actionWithTitle:@"Mute" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self postMuteUserScreenName:self.screenName];
                    }];
                }
                [actionSheet addAction:action];
            }
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Add/Remove from List" style:UIAlertActionStyleDestructive handler:nil]];
            UIAlertAction *action3;
            if ([relationSource[@"notifications_enabled"] boolValue]) {
                action3 = [UIAlertAction actionWithTitle:@"Stop Notifications" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self postUpdateFriendshipWithUserScreenName:self.screenName option:UpdateFriendshipStopNotifications];
                }];
            }
            else {
                action3 = [UIAlertAction actionWithTitle:@"Get Notifications" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self postUpdateFriendshipWithUserScreenName:self.screenName option:UpdateFriendshipGetNotifications];
                }];
            }
            [actionSheet addAction:action3];
            UIAlertAction *action4;
            if ([relationSource[@"want_retweets"] boolValue]) {
                action4 = [UIAlertAction actionWithTitle:@"Stop Retweets" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self postUpdateFriendshipWithUserScreenName:self.screenName option:UpdateFriendshipStopRetweets];
                }];
            }
            else {
                action4 = [UIAlertAction actionWithTitle:@"Get Retweets" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self postUpdateFriendshipWithUserScreenName:self.screenName option:UpdateFriendshipGetRetweets];
                }];
            }
            [actionSheet addAction:action4];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
            actionSheet.delegate = self;
            actionSheet.title = self.screenName;
            NSString *buttonTitle;
            if ([self.thisUserDetail[@"protected"] boolValue] && [self.thisUserDetail[@"follow_request_sent"] boolValue]) {
                buttonTitle = @"Requested";
            }
            else {
                buttonTitle = ([self.thisUserDetail[@"following"] boolValue]) ? @"Unfollow" : @"Follow";
            }
            [actionSheet addButtonWithTitle:buttonTitle];
            [actionSheet addButtonWithTitle: ([relationSource[@"blocking"] boolValue]) ? @"Unblock" : @"Block"];
            [actionSheet addButtonWithTitle:@"Report Spam"];
            if (relationSource[@"muting"] != nil) {
                if ([self.relation[@"relationship"][@"source"][@"muting"] boolValue]) {
                    [actionSheet addButtonWithTitle:@"Unmute"];
                }
                else {
                    [actionSheet addButtonWithTitle:@"Mute"];
                }
            }
            [actionSheet addButtonWithTitle:@"Add/Remove from List"];
            [actionSheet addButtonWithTitle: ([relationSource[@"notifications_enabled"] boolValue]) ? @"Stop Notifications" : @"Get Notifications"];
            [actionSheet addButtonWithTitle: ([relationSource[@"want_retweets"] boolValue]) ? @"Stop Retweets" : @"Get Retweets"];
            actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
            [actionSheet showInView:self.view];
        }
    }
}

- (IBAction)didReplyButtonPressed:(id)sender {
    if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if ([self.relation[@"relationship"][@"source"][@"can_dm"] boolValue]) {
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Direct Message" style:UIAlertActionStyleDefault handler:nil]];
        }
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Public Reply" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        if ([self.relation[@"relationship"][@"source"][@"can_dm"] boolValue]) {
            [actionSheet addButtonWithTitle:@"Direct Message"];
        }
        [actionSheet addButtonWithTitle:@"Public Reply"];
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)didComposeButtonPressed:(id)sender {
    self.newTweetType = NewTweetTypeNewTweet;
    [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
}

#pragma mark - Action Sheet Delegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (id object in actionSheet.subviews) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            if ([button.titleLabel.text isEqualToString:@"Unfollow"] ||
                [button.titleLabel.text isEqualToString:@"Block"] ||
                [button.titleLabel.text isEqualToString:@"Report Spam"]) {
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
            else if ([button.titleLabel.text isEqualToString:@"Requested"]) {
                button.enabled = NO;
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonString = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonString isEqualToString:@"Public Reply"]) {
        self.newTweetType = NewTweetTypeReply;
        [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
    }
    else if ([buttonString isEqualToString:@"Mute"]) {
        [self postMuteUserScreenName:self.screenName];
    }
    else if ([buttonString isEqualToString:@"Unmute"]) {
        [self postUnmuteUserScreenName:self.screenName];
    }
    else if ([buttonString isEqualToString:@"Get Notifications"]) {
        [self postUpdateFriendshipWithUserScreenName:self.screenName option:UpdateFriendshipGetNotifications];
    }
    else if ([buttonString isEqualToString:@"Stop Notifications"]) {
        [self postUpdateFriendshipWithUserScreenName:self.screenName option:UpdateFriendshipStopNotifications];
    }
    else if ([buttonString isEqualToString:@"Get Retweets"]) {
        [self postUpdateFriendshipWithUserScreenName:self.screenName option:UpdateFriendshipGetRetweets];
    }
    else if ([buttonString isEqualToString:@"Stop Retweets"]) {
        [self postUpdateFriendshipWithUserScreenName:self.screenName option:UpdateFriendshipStopRetweets];
    }
    else if ([buttonString isEqualToString:@"Follow"]) {
        [self postFollowUser:self.screenName];
    }
    else if ([buttonString isEqualToString:@"Unfollow"]) {
        [self postUnfollowUser:self.screenName];
    }
    else if ([buttonString isEqualToString:@"Block"]) {
        [self postBlockUser:self.screenName];
    }
    else if ([buttonString isEqualToString:@"Unblock"]) {
        [self postUnblockUser:self.screenName];
    }
    else if ([buttonString isEqualToString:@"Edit Profile"]) {
        [self performSegueWithIdentifier:@"ToEditProfile" sender:self];
    }
    else if ([buttonString isEqualToString:@"Report Spam"]) {
        [self postReportSpam:self.screenName];
    }
    else if ([buttonString isEqualToString:@"Add/Remove from List"]) {
        
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToDetail"]) {
        DetailViewController *vc = segue.destinationViewController;
        vc.options = (DetailShowingType)self.rowSelected;
        vc.screenName = self.screenName;
        vc.backBarButtonItemTitle = @"User";
    }
    else if ([segue.identifier isEqualToString:@"ToNewTweet"]) {
        NewTweetViewController *vc = (NewTweetViewController *)[segue.destinationViewController visibleViewController];
        vc.option = self.newTweetType;
        if (self.newTweetType == NewTweetTypeReply) {
            vc.inReplyToUserScreenName = @[self.screenName];
        }
    }
    else if ([segue.identifier isEqualToString:@"ToEditProfile"]) {
        EditProfileViewController *vc = (EditProfileViewController *)[segue.destinationViewController visibleViewController];
        vc.userData = self.thisUserDetail;
    }
    else if ([segue.identifier isEqualToString:@"ToImage"]) {
        ImageViewController *vc = segue.destinationViewController;
        vc.image = self.imageSentToNextVC;
        vc.imageLink = self.urlSentToNextVC;
        vc.shareLink = self.shareUrlSentToNextVC;
        vc.backBarButtonItemTitle = @"User";
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

- (IBAction)unwindToUser:(UIStoryboardSegue *)segue {
    [self getDataForUserScreenName:self.screenName];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UserDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCellID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[UserDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userCellID"];
        }*/
        [cell setUserDetailDictionary:self.thisUserDetail avatarImage:self.avatarImage];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailID"];
        }*/
        if (self.thisUserDetail[@"User Not Found"]) {
            return cell;
        }
        else {
            if ([self.thisUserDetail[@"protected"] boolValue] == YES) {
                cell.userInteractionEnabled = NO;
            }
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.numberStyle = NSNumberFormatterNoStyle;
            numberFormatter.groupingSeparator = @",";
            numberFormatter.groupingSize = 3;
            numberFormatter.alwaysShowsDecimalSeparator = NO;
            numberFormatter.usesGroupingSeparator = YES;
            /*if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailID"];
            }*/
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Tweets";
                cell.detailTextLabel.text = [numberFormatter stringFromNumber:(NSNumber *)self.thisUserDetail[@"statuses_count"]];
            }
            else if (indexPath.row == 2) {
                cell.textLabel.text = @"Followers";
                cell.detailTextLabel.text = [numberFormatter stringFromNumber:(NSNumber *)self.thisUserDetail[@"followers_count"]];
            }
            else if (indexPath.row == 3) {
                cell.textLabel.text = @"Following";
                cell.detailTextLabel.text = [numberFormatter stringFromNumber:(NSNumber *)self.thisUserDetail[@"friends_count"]];
            }
            else if (indexPath.row == 4) {
                cell.textLabel.text = @"Lists";
                cell.detailTextLabel.text = [numberFormatter stringFromNumber:(NSNumber *)self.thisUserDetail[@"listed_count"]];
            }
            else if (indexPath.row == 5) {
                cell.textLabel.text = @"Favorite";
                cell.detailTextLabel.text = [numberFormatter stringFromNumber:(NSNumber *)self.thisUserDetail[@"favourites_count"]];
            }
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) {
        self.rowSelected = indexPath.row;
        [self performSegueWithIdentifier:@"ToDetail" sender:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 150.0f;
    }
    else {
        return 44.0f;
    }
}

#pragma mark - User Detail Cell Delegate

- (void)userDetailCell:(UserDetailCell *)cell tapAvatarImage:(UIImage *)avatarImage link:(NSURL *)link {
    self.imageSentToNextVC = avatarImage;
    self.urlSentToNextVC = link;
    [self performSegueWithIdentifier:@"ToImage" sender:self];
}

@end
