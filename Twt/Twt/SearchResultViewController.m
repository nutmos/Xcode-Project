//
//  SearchResultViewController.m
//  Twt
//
//  Created by Nattapong Mos on 1/7/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "SearchResultViewController.h"
#import "TweetCell.h"
#import "UserCell.h"
#import "LoadMoreCell.h"
#import "UserViewController.h"
#import "BrowserViewController.h"
#import "TweetViewController.h"
#import "BrowserViewController.h"
#import "ImageViewController.h"

@interface SearchResultViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSArray *savedSearchArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (nonatomic) NSInteger currentPage;

@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [self.appDelegate clearTableFooterView];
    if (self.backBarButtonItemTitle) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshMyTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    self.navigationItem.title = self.showingType == SearchResultShowingTypeUserSuggestions
    ?self.slug[@"slug"]
    :[self.searchText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (self.showingType == SearchResultShowingTypeTweets) {
        if (!self.isSaved) {
            //NSLog(@"isSaved");
            [self checkSavedSearchWithSearchString:self.searchText];
        }
    }
    [self refreshMyTable:refresh];
}

- (void)showSaveButton {
    NSLog(@"show save button");
    self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (void)refreshMyTable:(UIRefreshControl *)refresh {
    if (self.showingType == SearchResultShowingTypeUsers) {
        [self getSearchUsersWithSearchString:self.searchText];
    }
    else if (self.showingType == SearchResultShowingTypeTweets) {
        [self getSearchTweetsWithSearchString:self.searchText option:RequestGETOptionGetAll tweetID:nil];
    }
    else if (self.showingType == SearchResultShowingTypeUserSuggestions) {
        [self getUserSuggestionsBySlug:self.slug[@"slug"] language:self.lang];
    }
    [refresh endRefreshing];
}

#pragma mark - Get Data

- (void)getUserSuggestionsBySlug:(NSString *)slug language:(NSString *)lang {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetUserSuggestionBySlugURL stringParameter:slug];
        NSDictionary *parameters = @{@"slug": slug, @"lang": lang};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && data[@"errors"] == nil) {
                        self.dataArray = [data[@"users"] mutableCopy];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                    else if (data[@"errors"]) {
                        NSLog(@"error = %@", data[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

- (void)postSaveSearch:(NSString *)searchString {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostCreateSaveSearchURL stringParameter:nil];
        NSDictionary *parameters = @{@"query": searchString};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && data[@"errors"] == nil) {
                        self.navigationItem.rightBarButtonItem = nil;
                        [self viewWillAppear:NO];
                    }
                    else {
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

- (void)getSearchUsersWithSearchString:(NSString *)searchString {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetSearchUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"q": [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"count": @"20"};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        self.dataArray = [data mutableCopy];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }
                else if ([data isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"error = %@", ((NSDictionary *)data)[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getSearchTweetsWithSearchString:(NSString *)searchString option:(RequestGETOption)option tweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetSearchTweetURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"q": [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
        }
        else if (option == RequestGETOptionGetMoreThan) {
            parameters = @{@"q": [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"max_id": tweetID.stringValue};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([dataDict isKindOfClass:[NSDictionary class]]) {
                    if (dataDict.count && dataDict[@"errors"] == nil) {
                        NSArray *statuses = dataDict[@"statuses"];
                        if (statuses.count) {
                            //NSLog(@"statuses count");
                            if (option == RequestGETOptionGetAll) {
                                self.dataArray = statuses.mutableCopy;
                            }
                            else {
                                [self.dataArray removeLastObject];
                                [self.dataArray addObjectsFromArray:statuses];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }
                        else {
                            NSLog(@"stop load cell");
                            [self stopLoadMoreCellActivity];
                        }
                    }
                    else if (dataDict[@"errors"]) {
                        NSLog(@"error = %@", dataDict[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

- (void)checkSavedSearchWithSearchString:(NSString *)searchString {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetSavedSearchListURL stringParameter:nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:nil];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                //NSLog(@"data = %@",data);
                if ([data isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *savedSearch in data) {
                        if ([savedSearch[@"name"] isEqualToString:self.searchText]) {
                            return;
                        }
                    }
                    [self showSaveButton];
                }
                else if ([data isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"error = %@", ((NSDictionary *)data)[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - Navigation

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    if ([segueID isEqualToString:@"ToUser"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.screenName = self.userSentToNextVC[@"screen_name"];
        vc.avatarImage = self.avatarSentToNextVC;
        vc.backBarButtonItemTitle = @"Search";
    }
    else if ([segueID isEqualToString:@"ToTweet"]) {
        TweetViewController *vc = segue.destinationViewController;
        vc.tweetDictionary = self.tweetSentToNextVC;
        vc.backBarButtonItemTitle = @"Search";
    }
    else if ([segueID isEqualToString:@"ToBrowser"]) {
        BrowserViewController *vc = segue.destinationViewController;
        vc.address = self.urlSentToNextVC;
        vc.hidesBottomBarWhenPushed = YES;
        vc.backBarButtonItemTitle = @"Search";
    }
    else if ([segueID isEqualToString:@"ToSearchResult"]) {
        SearchResultViewController *vc = segue.destinationViewController;
        vc.searchText = self.searchStringSentToNextVC;
        vc.showingType = SearchResultShowingTypeTweets;
        vc.backBarButtonItemTitle = @"Search";
    }
    else if ([segueID isEqualToString:@"ToImage"]) {
        ImageViewController *vc = segue.destinationViewController;
        vc.image = self.imageSentToNextVC;
        vc.imageLink = self.urlSentToNextVC;
        vc.shareLink = self.shareUrlSentToNextVC;
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

#pragma mark - Search Display Controller Delegate

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *resultPredicate;
    if (self.showingType == SearchResultShowingTypeTweets) {
        resultPredicate = [NSPredicate predicateWithFormat:@"(text CONTAINS %@)", searchText];
    }
    else {
        resultPredicate = [NSPredicate predicateWithFormat:@"(name CONTAINS %@)", searchText];
    }
    self.searchResultArray = [self.dataArray filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

#pragma mark - User Interaction

- (IBAction)didSaveButtonPressed:(UIBarButtonItem *)saveButton {
    saveButton.enabled = NO;
    [self viewWillAppear:NO];
    [self postSaveSearch:self.searchText];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.dataArray.count + 1;
    }
    else {
        return self.searchResultArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showingType == SearchResultShowingTypeTweets) {
        if (indexPath.row == self.dataArray.count && tableView == self.tableView) {
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
            TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            /*if (!cell) {
                cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }*/
            NSDictionary *tweet = self.dataArray[indexPath.row];
            [cell setTweetCellWithTweetDictionary:tweet inViewController:self delegate:self];
            return cell;
        }
    }
    else if (self.showingType == SearchResultShowingTypeUsers ||
             self.showingType == SearchResultShowingTypeUserSuggestions) {
        static NSString *cellID = @"userCellID";
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }*/
        NSDictionary *user = self.dataArray[indexPath.row];
        [cell setUserDictionary:user inViewController:self];
        return cell;
    }
    else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath.row == self.dataArray.count) {
        return 44.0f;
    }
    else {
        if (self.showingType == SearchResultShowingTypeTweets) {
            // Init data
            NSArray *tweetsArr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
            return [TweetCell calculateTweetCellHeightWithTweetDictionary:tweetsArr[indexPath.row] option:TweetCellShowTweet];
        }
        else if (self.showingType == SearchResultShowingTypeUsers ||
                 self.showingType == SearchResultShowingTypeUserSuggestions) {
            NSArray *usersArr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
            return [UserCell calculateUserCellHeightWithUserDictionary:usersArr[indexPath.row]];
        }
        else return 0;
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    if (self.showingType == SearchResultShowingTypeUsers ||
        self.showingType == SearchResultShowingTypeUserSuggestions) {
        UserCell *cell = (UserCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        self.userSentToNextVC = cell.user;
        [self performSegueWithIdentifier:@"ToUser" sender:self];
    }
    else if (self.showingType == SearchResultShowingTypeTweets) {
        self.tweetSentToNextVC = ((TweetCell *)[self.tableView cellForRowAtIndexPath:indexPath]).tweetDict;
        [self performSegueWithIdentifier:@"ToTweet" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && self.showingType == SearchResultShowingTypeTweets) {
        if (indexPath.row == self.dataArray.count - 1) {
            //NSLog(@"will display last cell");
            [self getSearchTweetsWithSearchString:self.searchText option:RequestGETOptionGetMoreThan tweetID:(((TweetCell *)cell).tweetDict)[@"id"]];
        }
    }
}

- (void)stopLoadMoreCellActivity {
    LoadMoreCell *cell = (LoadMoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0]];
    [cell stopActivity];
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
    self.urlSentToNextVC = urlEntities[@"url"];
    [self performSegueWithIdentifier:@"ToBrowser" sender:self];
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithMediaEntities:(NSDictionary *)media {
    self.shareUrlSentToNextVC = media[@"display_url"];
    self.urlSentToNextVC = media[@"media_url"];
    [self performSegueWithIdentifier:@"ToImage" sender:self];
}

- (void)tweetCell:(TweetCell *)cell didTapLinkWithUserEntities:(NSDictionary *)user {
    self.userSentToNextVC = user;
    [self performSegueWithIdentifier:@"ToUser" sender:self];
}

@end
