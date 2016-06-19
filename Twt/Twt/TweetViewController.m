//
//  TweetViewController.m
//  Twt
//
//  Created by Nattapong Mos on 30/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(unsigned int, GetTweetDataOption) {
    GetTweetDataOptionGetTweet,
    GetTweetDataOptionGetInReplyToStatus,
};

#import "TweetViewController.h"
#import "NewTweetViewController.h"
#import "BrowserViewController.h"
#import "DetailViewController.h"
#import "CountCell.h"
#import "AppDelegate.h"
#import "TweetToolCell.h"
#import "TweetDetailCell.h"
#import "UserViewController.h"
#import "UIViewController+RequiredObject.h"
#import "UITableView+Extension.h"
#import <SafariServices/SafariServices.h>
#import "SearchResultViewController.h"
#import "ImageViewController.h"

@interface TweetViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic) NewTweetType newTweetType;
@property (nonatomic) DetailShowingType detailShowingType;
@property UIActionSheet *actionSheet;
@property (strong, nonatomic) NSDictionary *retweetedTweet;
@property (strong, nonatomic) NSArray *inReplyTo;
@property (nonatomic) BOOL deleted;

@end

@implementation TweetViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.estimatedRowHeight = 88;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.deleted = NO;
    if (self.backBarButtonItemTitle != nil) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    [self getTweetDataWithTweetID:self.tweetDictionary[@"id"] option:GetTweetDataOptionGetTweet];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueGetInReplyTo) name:@"Continue Get In Reply To" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.inReplyTo.count) {
        [self continueGetInReplyTo];
    }
    else {
        NSNumber *tweetID = self.tweetDictionary[@"in_reply_to_status_id"];
        if (![tweetID isEqual:[NSNull null]] && tweetID != nil) {
            NSLog(@"tweetID = %@", tweetID);
            [self getTweetDataWithTweetID:tweetID option:GetTweetDataOptionGetInReplyToStatus];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.deleted) {
        if ([self.delegate respondsToSelector:@selector(tweetViewController:removeTweetData:)]) {
            [self.delegate tweetViewController:self removeTweetData:self.tweetDictionary];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(tweetViewController:tweetData:)]) {
            [self.delegate tweetViewController:self tweetData:self.tweetDictionary];
        }
    }
}

- (void)continueGetInReplyTo {
    NSNumber *inReplyToStatusID = self.inReplyTo.lastObject[@"in_reply_to_status_id"];
    if (![inReplyToStatusID isEqual:[NSNull null]] &&
        inReplyToStatusID != nil) {
        [self getTweetDataWithTweetID:inReplyToStatusID option:GetTweetDataOptionGetInReplyToStatus];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

#pragma mark - Get Data

- (void)getTweetDataWithTweetID:(NSNumber *)tweetID option:(GetTweetDataOption)option {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetStatusLookupURL stringParameter:[tweetID stringValue]];
        NSDictionary *parameters = @{@"id": [tweetID stringValue]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * tweet = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([tweet isKindOfClass:[NSDictionary class]]) {
                    if (tweet.count && tweet[@"errors"] == nil) {
                        if (option == GetTweetDataOptionGetTweet) {
                            self.tweetDictionary = tweet;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }
                        else {
                            if (self.inReplyTo) {
                                self.inReplyTo = [self.inReplyTo arrayByAddingObject:tweet];
                            }
                            else {
                                self.inReplyTo = @[tweet];
                            }
                            //NSLog(@"self.inReplyTo = %@", self.inReplyTo);
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"Continue Get In Reply To" object:nil];
                            //NSLog(@"test");
                        }
                    }
                    else if (tweet[@"errors"]) {
                        NSLog(@"error = %@", tweet[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postFavoriteTweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSDictionary *parameters = @{@"id": [tweetID stringValue]};
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostCreateFavouriteTweetURL stringParameter:nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * tweet = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([tweet isKindOfClass:[NSDictionary class]]) {
                    if (tweet[@"errors"] == nil && tweet.count) {
                        [self getTweetDataWithTweetID:tweetID option:GetTweetDataOptionGetTweet];
                    }
                    else {
                        NSLog(@"error = %@", tweet[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postDestroyFavoriteTweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSDictionary *parameters = @{@"id": [tweetID stringValue]};
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostDestroyFavouriteTweetURL stringParameter:nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * tweet = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([tweet isKindOfClass:[NSDictionary class]]) {
                    if (tweet[@"errors"] == nil && tweet.count) {
                        self.tweetDictionary = tweet;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                    else if (tweet[@"errors"]) {
                        NSLog(@"error = %@", tweet[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postRetweetTweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSURL *feedUrl = [self.appDelegate requestURLWithOption:RequestPostCreateRetweetURL stringParameter:[tweetID stringValue]];
        NSDictionary *parameters = @{@"id": [tweetID stringValue]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feedUrl parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (!data[@"errors"] && data.count) {
                        [self getTweetDataWithTweetID:self.tweetDictionary[@"id"] option:GetTweetDataOptionGetTweet];
                    }
                    else if (data[@"errors"]) {
                        NSLog(@"error = %@", data[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postRemoveTweetWithTweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostDestroyRetweetURL stringParameter:[tweetID stringValue]];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:nil];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && !data[@"errors"]) {
                        self.tweetDictionary = data;
                        self.deleted = YES;
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - User Interaction

- (IBAction)didRetweetCountButtonPressed:(id)sender {
    self.detailShowingType = DetailShowingTypeRetweetedBy;
    [self performSegueWithIdentifier:@"ToDetail" sender:self];
}

- (IBAction)didFaveButtonPressed:(UIBarButtonItem *)sender {
    if (sender.tag == 1) {
        sender.tag = 0;
        sender.image = [UIImage imageNamed:@"favourite"];
        sender.tintColor = [UIColor whiteColor];
        [self postDestroyFavoriteTweetID:self.tweetDictionary[@"id"]];
    }
    else {
        sender.tag = 1;
        sender.image = [UIImage imageNamed:@"favourite_pressed"];
        sender.tintColor = [UIColor yellowColor];
        [self postFavoriteTweetID:self.tweetDictionary[@"id"]];
    }
}

- (IBAction)didRetweetButtonPressed:(id)sender {
    if ([self.tweetDictionary[@"user"][@"screen_name"] isEqualToString:self.appDelegate.currentAccount.username] && self.tweetDictionary[@"retweeted_status"] == nil) {
        if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[self.appDelegate cancelAlertAction]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Quote Tweet" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.newTweetType = NewTweetTypeQuoteTweet;
                [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
            }]];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
        else {
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Quote Tweet", nil];
            [actionSheet showInView: self.view];
        }
    }
    else {
        if ([self.tweetDictionary[@"user"][@"protected"] boolValue] && !self.tweetDictionary[@"retweeted_status"]) {
            if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Protected User" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [actionSheet addAction:[self.appDelegate cancelAlertAction]];
                [self presentViewController:actionSheet animated:YES completion:nil];
            }
            else {
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Protected User" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
                [actionSheet showInView:self.view];
            }
        }
        else {
            if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [actionSheet addAction:[self.appDelegate cancelAlertAction]];
                if ([self.tweetDictionary[@"retweeted"] boolValue] && self.tweetDictionary[@"retweeted_status"] != nil) {
                    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove Retweet" style:UIAlertActionStyleDestructive handler:nil]];
                }
                else {
                    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Retweet" style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
                        [self postRetweetTweetID:self.tweetDictionary[@"id"]];
                    }]];
                }
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Quote Tweet" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    self.newTweetType = NewTweetTypeQuoteTweet;
                    [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
                }]];
                [self presentViewController:actionSheet animated:YES completion:nil];
            }
            else {
                UIActionSheet * actionSheet = [[UIActionSheet alloc] init];
                actionSheet.delegate = self;
                if ([self.tweetDictionary[@"retweeted"] boolValue] && self.tweetDictionary[@"retweeted_status"] != nil) {
                    [actionSheet addButtonWithTitle:@"Remove Retweet"];
                }
                else {
                    [actionSheet addButtonWithTitle:@"Retweet"];
                }
                [actionSheet addButtonWithTitle:@"Quote Tweet"];
                actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
                [actionSheet showInView:self.view];
            }
        }
    }
}

- (IBAction)didReplyButtonPressed:(id)sender {
    self.newTweetType = NewTweetTypeReply;
    [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
}

- (IBAction)didShareButtonPressed:(id)sender {
    if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Share via..." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Read It Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            SSReadingList *readList = [SSReadingList defaultReadingList];
            NSString *screenName = self.tweetDictionary[@"user"][@"screen_name"];
            NSString *tweetIDString;
            if (self.tweetDictionary[@"retweeted_status"]) {
                tweetIDString = self.tweetDictionary[@"retweeted_status"][@"id_str"];
            }
            else {
                tweetIDString = self.tweetDictionary[@"id_str"];
            }
            [readList addReadingListItemWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.twitter.com/%@/status/%@", screenName, tweetIDString]] title:self.tweetDictionary[@"user"][@"screen_name"] previewText:self.tweetDictionary[@"text"] error:nil];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Copy Link to Tweet" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *screenName = self.tweetDictionary[@"user"][@"screen_name"];
            NSString *tweetIDString;
            if (self.tweetDictionary[@"retweeted_status"]) {
                tweetIDString = self.tweetDictionary[@"retweeted_status"][@"id_str"];
            }
            else {
                tweetIDString = self.tweetDictionary[@"id_str"];
            }
            UIPasteboard *systemPasteboard = [UIPasteboard generalPasteboard];
            systemPasteboard.string = [NSString stringWithFormat:@"https://www.twitter.com/%@/status/%@", screenName, tweetIDString];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Copy Tweet" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIPasteboard *systemPasteboard = [UIPasteboard generalPasteboard];
            if (self.tweetDictionary[@"retweeted_status"]) {
                systemPasteboard.string = self.tweetDictionary[@"retweeted_status"][@"text"];
            }
            else {
                systemPasteboard.string = self.tweetDictionary[@"text"];
            }
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share via..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Read It Later", @"Copy Link to Tweet", @"Copy Tweet", nil];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)didTrashButtonPressed:(id)sender {
    if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Are you sure to delete this tweet?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self postRemoveTweetWithTweetID:self.tweetDictionary[@"id"]];
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure to delete this tweet?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - Action Sheet Delegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (id object in actionSheet.subviews) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            if ([button.titleLabel.text isEqualToString:@"Follow"]) {
                button.enabled = NO;
            }
            else if ([button.titleLabel.text isEqualToString:@"Delete"]) {
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Retweet"]) {
        [self postRetweetTweetID:self.tweetDictionary[@"id"]];
    }
    else if ([buttonTitle isEqualToString:@"Remove Retweet"]) {
        //[self postRemoveRetweetWithID:[self.tweetDictionary objectForKey:@"id"]];
    }
    else if ([buttonTitle isEqualToString:@"Quote Tweet"]) {
        self.newTweetType = NewTweetTypeQuoteTweet;
        [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
    }
    else if ([buttonTitle isEqualToString:@"Copy Link to Tweet"]) {
        NSString *screenName = self.tweetDictionary[@"user"][@"screen_name"];
        NSDictionary *retweeted = self.tweetDictionary[@"retweeted_status"];
        NSString *tweetIDString = ((retweeted) ? retweeted : self.tweetDictionary)[@"id_str"];
        UIPasteboard *systemPasteboard = [UIPasteboard generalPasteboard];
        systemPasteboard.string = [NSString stringWithFormat:@"https://www.twitter.com/%@/status/%@", screenName, tweetIDString];
    }
    else if ([buttonTitle isEqualToString:@"Copy Tweet"]) {
        UIPasteboard *systemPasteboard = [UIPasteboard generalPasteboard];
        NSDictionary *retweeted = self.tweetDictionary[@"retweeted_status"];
        systemPasteboard.string = ((retweeted) ? retweeted : self.tweetDictionary)[@"text"];
    }
    else if ([buttonTitle isEqualToString:@"Delete"]) {
        [self postRemoveTweetWithTweetID:self.tweetDictionary[@"id"]];
    }
    else if ([buttonTitle isEqualToString:@"Read It Later"]) {
        SSReadingList *readList = [SSReadingList defaultReadingList];
        NSString *screenName = self.tweetDictionary[@"user"][@"screen_name"];
        NSDictionary *retweeted = self.tweetDictionary[@"retweeted_status"];
        NSString *tweetIDString = ((retweeted) ? retweeted : self.tweetDictionary)[@"id_str"];
        [readList addReadingListItemWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.twitter.com/%@/status/%@", screenName, tweetIDString]] title:screenName previewText:self.tweetDictionary[@"text"] error:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.tweetDictionary[@"retweet_count"] intValue] > 0 ||
        [self.tweetDictionary[@"favourite_count"] intValue] > 0) {
        return self.inReplyTo.count + 4;
    }
    else {
        return self.inReplyTo.count + 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger retweetCount = [self.tweetDictionary[@"retweet_count"] integerValue];
    NSInteger faveCount = [self.tweetDictionary[@"favourite_count"] integerValue];
    if (indexPath.row < self.inReplyTo.count) {
        TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        }*/
        [cell setTweetCellWithTweetDictionary:self.inReplyTo[self.inReplyTo.count - indexPath.row - 1] inViewController:self delegate:self];
        cell.userInteractionEnabled = YES;
        return cell;
    }
    else if (indexPath.row == self.inReplyTo.count) {
        TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        }*/
        [cell setTweetCellWithTweetDictionary:self.tweetDictionary inViewController:self delegate:self];
        return cell;
    }
    else if (indexPath.row == self.inReplyTo.count+1) {
        TweetDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[TweetDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailID"];
        }*/
        [cell setTweetDictionary:self.tweetDictionary inTableViewController:self];
        return cell;
    }
    else if (indexPath.row == self.inReplyTo.count+2 && (retweetCount > 0 || faveCount > 0)) {
        CountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[CountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"countID"];
        }*/
        [cell setCountCellWithTweetDictionary:self.tweetDictionary inViewController:self];
        return cell;
    }
    else if (indexPath.row == self.inReplyTo.count+3 || (indexPath.row == self.inReplyTo.count+2 && !(retweetCount > 0 || faveCount > 0))) {
        TweetToolCell *cell = [tableView dequeueReusableCellWithIdentifier:@"toolID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[TweetToolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"toolID"];
        }*/
        [cell setTweetToolWithTweetDictionary:self.tweetDictionary];
        return cell;
    }
    else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.inReplyTo.count) {
        return [TweetCell calculateTweetCellHeightWithTweetDictionary:self.tweetDictionary option:TweetCellShowTweet];
    }
    else if (indexPath.row < self.inReplyTo.count) {
        return [TweetCell calculateTweetCellHeightWithTweetDictionary:self.inReplyTo[self.inReplyTo.count - indexPath.row - 1] option:TweetCellShowTweet];
    }
    else {
        return 44.0f;
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.inReplyTo.count) {
        self.tweetSentToNextVC = self.inReplyTo[self.inReplyTo.count - indexPath.row - 1];
        [self performSegueWithIdentifier:@"ToTweet" sender:self];
    }
}

#pragma mark - Navigation

- (IBAction)unwindToList:(UIStoryboardSegue *)sender {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToNewTweet"]) {
        NewTweetViewController *vc = (NewTweetViewController *)[segue.destinationViewController visibleViewController];
        if (self.newTweetType == NewTweetTypeQuoteTweet) {
            vc.option = NewTweetTypeQuoteTweet;
            vc.inReplyToStatus = self.tweetDictionary;
        }
        else if (self.newTweetType == NewTweetTypeReply) {
            vc.option = NewTweetTypeReply;
            vc.inReplyToStatus = self.tweetDictionary;
            NSArray *userMentions = self.tweetDictionary[@"entities"][@"user_mentions"];
            NSArray *array = @[self.tweetDictionary[@"user"][@"screen_name"]];
            for (NSDictionary *dict in userMentions) {
                array = [array arrayByAddingObject:dict[@"screen_name"]];
            }
            vc.inReplyToUserScreenName = array;
        }
    }
    else if ([segue.identifier isEqualToString:@"ToUser"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.screenName = self.userSentToNextVC[@"screen_name"];
        vc.avatarImage = self.avatarSentToNextVC;
    }
    else if ([segue.identifier isEqualToString:@"ToDetail"]) {
        DetailViewController *vc = segue.destinationViewController;
        vc.options = self.detailShowingType;
        if (self.detailShowingType == DetailShowingTypeRetweetedBy) {
            NSDictionary *retweeted = self.tweetDictionary[@"retweeted_status"];
            vc.tweetID = ((retweeted) ? retweeted : self.tweetDictionary)[@"id"];
        }
    }
    else if ([segue.identifier isEqualToString:@"ToBrowser"]) {
        BrowserViewController *vc = segue.destinationViewController;
        vc.address = self.urlSentToNextVC;
        vc.hidesBottomBarWhenPushed = YES;
    }
    else if ([segue.identifier isEqualToString:@"ToSearchResult"]) {
        SearchResultViewController *vc = segue.destinationViewController;
        vc.searchText = self.searchStringSentToNextVC;
        vc.showingType = SearchResultShowingTypeTweets;
    }
    else if ([segue.identifier isEqualToString:@"ToImage"]) {
        ImageViewController *vc = segue.destinationViewController;
        vc.image = self.imageSentToNextVC;
        vc.imageLink = self.urlSentToNextVC;
        vc.shareLink = self.shareUrlSentToNextVC;
    }
    else if ([segue.identifier isEqualToString:@"ToTweet"]) {
        TweetViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.tweetDictionary = self.tweetSentToNextVC;
    }
}

#pragma mark - TweetCell Delegate

- (void)tweetCell:(TweetCell *)cell didTapAvatarImage:(UIImage *)image userEntities:(NSDictionary *)user {
    self.avatarSentToNextVC = image;
    self.userSentToNextVC = user;
    [self performSegueWithIdentifier:@"ToUser" sender:self];
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithHashtagEntities:(NSDictionary *)hashtag {
    NSString *hashtagText = hashtag[@"text"];
    if (hashtagText) {
        self.searchStringSentToNextVC = [NSString stringWithFormat:@"#%@", hashtagText];
        [self performSegueWithIdentifier:@"ToSearchResult" sender:self];
    }
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithSymbolEntities:(NSDictionary *)symbol {
    NSString *symbolText = symbol[@"text"];
    if (symbolText) {
        self.searchStringSentToNextVC = [NSString stringWithFormat:@"$%@", symbolText];
        [self performSegueWithIdentifier:@"ToSearchResult" sender:self];
    }
}

- (void)tweetCell:(TweetCell *)cell didTapRetweetedByUserEntities:(NSDictionary *)user {
    self.userSentToNextVC = user;
    [self performSegueWithIdentifier:@"ToUser" sender:self];
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithURLEntities:(NSDictionary *)urlEntities {
    self.urlSentToNextVC = [NSURL URLWithString:urlEntities[@"url"]];
    [self performSegueWithIdentifier:@"ToBrowser" sender:self];
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithMediaEntities:(NSDictionary *)media {
    self.shareUrlSentToNextVC = [NSURL URLWithString:media[@"display_url"]];
    self.urlSentToNextVC = [NSURL URLWithString:media[@"media_url"]];
    [self performSegueWithIdentifier:@"ToImage" sender:self];
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithUserEntities:(NSDictionary *)user {
    self.userSentToNextVC = user;
    [self performSegueWithIdentifier:@"ToUser" sender:self];
}

#pragma mark - Tweet View Controller Delegate

- (void)tweetViewController:(TweetViewController *)vc removeTweetData:(NSDictionary *)tweet {
    
}

- (void)tweetViewController:(TweetViewController *)vc tweetData:(NSDictionary *)tweet {
    
}

@end
