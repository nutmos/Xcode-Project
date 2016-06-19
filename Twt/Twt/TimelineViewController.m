//
//  TimelineViewController.m
//  Twt
//
//  Created by Nattapong Mos on 16/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//
/*
typedef NS_ENUM(NSUInteger, GetHomeTimelineOption) {
    GetHomeTimelineOptionGetAll,
    GetHomeTimelineOptionRecentThan,
    GetHomeTimelineOptionOlderThan,
    GetHomeTimelineOptionBetween,
};
*/
// if use GetHomeTimelineOptionBetween sent top of seperator as parameter

#import "TimelineViewController.h"
#import "UserViewController.h"
#import "NewTweetViewController.h"
#import "AppDelegate.h"
#import "UITableView+Extension.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UIViewController+RequiredObject.h"
#import "BrowserViewController.h"
#import "DetailViewController.h"
#import "SearchResultViewController.h"
#import "UIERealTimeBlurView.h"
#import "LoadMoreCell.h"
#import "ImageViewController.h"

@interface TimelineViewController ()

@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (strong, nonatomic) NSMutableArray *filteredDataArray;
@property (strong) AppDelegate *appDelegate;
@property (nonatomic) NSIndexPath *selectedRow;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.estimatedRowHeight = 88;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshMyTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    if (self.backBarButtonItemTitle != nil) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView.tableFooterView = self.appDelegate.clearTableFooterView;
    self.searchDisplayController.searchResultsTableView.tableFooterView = self.appDelegate.clearTableFooterView;
    [self getHomeTimelineOption:RequestGETOptionGetAll tweetID:nil];
}

- (void)refreshMyTable:(UIRefreshControl *)refresh {
    [self getHomeTimelineOption:RequestGETOptionGetAll tweetID:nil];
    [refresh endRefreshing];
}

#pragma mark - User Interactions

- (IBAction)didComposeButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
}

#pragma mark - Get Data

- (void)getHomeTimelineOption:(RequestGETOption) option tweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetHomeTimelineURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"count": @"50"};
        }
        else if (option == RequestGETOptionGetMoreThan) {
            parameters = @{@"max_id": tweetID.stringValue, @"count": @"51"};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        if (option == RequestGETOptionGetMoreThan) {
                            [self.tweetsArray removeLastObject];
                            [self.tweetsArray addObjectsFromArray:data];
                        }
                        else {
                            self.tweetsArray = data.mutableCopy;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }
                else if ([data isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"error = %@", ((NSDictionary *)data)[@"errors"]);
                    LoadMoreCell *cell = (LoadMoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0]];
                    [cell stopActivity];
                }
                
            }
            else {
                NSLog(@"%@", error.localizedDescription);
                LoadMoreCell *cell = (LoadMoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0]];
                [cell stopActivity];
            }
        }];
    }
}

#pragma mark - Navigation

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"UnwindChangeUser"]) {
        [self getHomeTimelineOption:RequestGETOptionGetAll tweetID:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    if ([segueID isEqualToString:@"ToUser"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.screenName = self.userSentToNextVC[@"screen_name"];
        vc.avatarImage = self.avatarSentToNextVC;
    }
    else if ([segueID isEqualToString:@"ToTweet"]) {
        TweetViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.tweetDictionary = self.tweetSentToNextVC;
    }
    else if ([segueID isEqualToString:@"ToNewTweet"]) {
        NewTweetViewController *vc = (NewTweetViewController *)[segue.destinationViewController visibleViewController];
        vc.option = NewTweetTypeNewTweet;
    }
    else if ([segueID isEqualToString:@"ToBrowser"]) {
        BrowserViewController *vc = segue.destinationViewController;
        vc.address = self.urlSentToNextVC;
        vc.hidesBottomBarWhenPushed = YES;
    }
    else if ([segueID isEqualToString:@"ToSearchResult"]) {
        SearchResultViewController *vc = segue.destinationViewController;
        vc.searchText = self.searchStringSentToNextVC;
        vc.showingType = SearchResultShowingTypeTweets;
    }
    else if ([segueID isEqualToString:@"ToImage"]) {
        ImageViewController *vc = segue.destinationViewController;
        vc.image = self.imageSentToNextVC;
        vc.imageLink = self.urlSentToNextVC;
        vc.shareLink = self.shareUrlSentToNextVC;
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = (TweetCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.tweetSentToNextVC = cell.tweetDict;
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"ToTweet" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.tweetsArray.count + 1;
    }
    else {
        return self.searchResultArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath.row == self.tweetsArray.count) {
        static NSString *cellID = @"loadMoreID";
        LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }*/
        [cell startActivity];
        return cell;
    }
    else {
        static NSString *cellID = @"cellID";
        TweetCell *cell = (TweetCell *)[self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }*/
        NSArray *dataArr = (tableView == self.tableView) ? self.tweetsArray : self.searchResultArray;
        [cell setTweetCellWithTweetDictionary:dataArr[indexPath.row] inViewController:self delegate:self];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (indexPath.row == self.tweetsArray.count - 1) {
            [self getHomeTimelineOption:RequestGETOptionGetMoreThan tweetID:((TweetCell *)cell).tweetDict[@"id"]];
        }
    }
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath.row == self.tweetsArray.count) {
        return 44.0f;
    }
    else {
        NSArray *dataArr = (tableView == self.tableView) ? self.tweetsArray : self.searchResultArray;
        return [TweetCell calculateTweetCellHeightWithTweetDictionary:dataArr[indexPath.row] option:TweetCellShowTweet];
    }
}*/

#pragma mark - Search Bar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

#pragma mark - Search Display Controller Delegate

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(text CONTAINS %@)", searchText];
    self.searchResultArray = [self.tweetsArray filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

#pragma mark - Tweet View Controller Delegate

- (void)tweetViewController:(TweetViewController *)vc tweetData:(NSDictionary *)tweet {
    //[self.tweetsArray replaceObjectAtIndex:self.selectedIndexPath.row withObject:tweet];
    self.tweetsArray[self.selectedIndexPath.row] = tweet;
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tweetViewController:(TweetViewController *)vc removeTweetData:(NSDictionary *)tweet {
    dispatch_group_t g1 = dispatch_group_create();
    dispatch_queue_t q1 = dispatch_queue_create("q1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(g1, q1, ^{
        [self.tweetsArray removeObjectAtIndex:self.selectedIndexPath.row];
    });
    dispatch_group_wait(g1, DISPATCH_TIME_FOREVER);
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - TweetCell Delegate

- (void)tweetCell:(TweetCell *)cell didTapAvatarImage:(UIImage *)image userEntities:(NSDictionary *)user {
    self.avatarSentToNextVC = image;
    self.userSentToNextVC = user;
    [self performSegueWithIdentifier:@"ToUser" sender:self];
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithHashtagEntities:(NSDictionary *)hashtag {
    self.searchStringSentToNextVC = [NSString stringWithFormat:@"#%@", hashtag[@"text"]];
    [self performSegueWithIdentifier:@"ToSearchResult" sender:self];
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithSymbolEntities:(NSDictionary *)symbol {
    self.searchStringSentToNextVC = [NSString stringWithFormat:@"$%@", symbol[@"text"]];
    [self performSegueWithIdentifier:@"ToSearchResult" sender:self];
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

@end
