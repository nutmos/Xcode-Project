//
//  UserDetailViewController.m
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//
/*
typedef NS_ENUM(NSInteger, GetRetweetsOfMeOption) {
    GetRetweetsOfMeOptionGetAll,
    GetRetweetsOfMeOptionOlderThan,
    GetRetweetsOfMeOptionRecentThan,
};
*/
#import "RetweetsTableViewController.h"
#import "AppDelegate.h"
#import "TweetCell.h"
#import "UserCell.h"
#import "LoadMoreCell.h"
#import "ListCell.h"
#import "UserViewController.h"
#import "TweetInListViewController.h"
#import "ListDetailViewController.h"
#import "CreateListViewController.h"
#import "UIViewController+RequiredObject.h"
#import "ImageViewController.h"
#import "NewTweetViewController.h"

@interface RetweetsTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) NSIndexPath *selectedRow;

@end

@implementation RetweetsTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.estimatedRowHeight = 88;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
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
    self.navigationItem.title = @"Retweets";
    [self refreshMyTable:refresh];
}

- (void)refreshMyTable:(UIRefreshControl *)refresh {
    [self getRetweetsOfMeOption:RequestGETOptionGetAll tweetID:nil];
    [refresh endRefreshing];
}

#pragma mark - Get Data Method

- (void)getRetweetsOfMeOption:(RequestGETOption)option tweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetRetweetsOfMeURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"count": @"50"};
        }
        else if (option == RequestGETOptionGetMoreThan) {
            parameters = @{@"max_id": [tweetID stringValue], @"count": @"51"};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        if (option == RequestGETOptionGetMoreThan) {
                            [self.dataArray removeLastObject];
                            [self.dataArray addObjectsFromArray:data];
                        }
                        else {
                            self.dataArray = data.mutableCopy;
                        }
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
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

#pragma mark - Navigation

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToUser"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.screenName = self.userSentToNextVC[@"screen_name"];
        vc.avatarImage = self.avatarSentToNextVC;
    }
    else if ([segue.identifier isEqualToString:@"ToTweet"]) {
        TweetViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.tweetDictionary = self.tweetSentToNextVC;
    }
    else if ([segue.identifier isEqualToString:@"ToImage"]) {
        ImageViewController *vc = segue.destinationViewController;
        vc.image = self.imageSentToNextVC;
        vc.imageLink = self.urlSentToNextVC;
        vc.shareLink = self.shareUrlSentToNextVC;
    }
    else if ([segue.identifier isEqualToString:@"ToNewTweet"]) {
        NewTweetViewController *vc = (NewTweetViewController *)[segue.destinationViewController visibleViewController];
        vc.option = NewTweetTypeNewTweet;
    }
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count - 1 && tableView != self.searchDisplayController.searchResultsTableView) {
        [self getRetweetsOfMeOption:RequestGETOptionGetMoreThan tweetID:(((TweetCell *)cell).tweetDict)[@"id"]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        NSArray *tweetArray;
        if (tableView == self.tableView) {
            tweetArray = self.dataArray;
        }
        else {
            tweetArray = self.searchResultArray;
        }
        [cell setTweetCellWithTweetDictionary:tweetArray[indexPath.row] inViewController:self delegate:self];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tweetSentToNextVC = ((TweetCell *)[self.tableView cellForRowAtIndexPath:indexPath]).tweetDict;
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"ToTweet" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count && tableView == self.tableView) {
        return 44.0f;
    }
    else {
        NSDictionary *tweet = self.dataArray[indexPath.row];
        return [TweetCell calculateTweetCellHeightWithTweetDictionary:tweet option:TweetCellShowRetweetOfMe];
    }
}

#pragma mark - Search Display Controller Delegate

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(text CONTAINS %@)", searchText];
    self.searchResultArray = [self.dataArray filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

#pragma mark - Tweet View Controller Deleagate

- (void)tweetViewController:(TweetViewController *)vc tweetData:(NSDictionary *)tweet {
    //[self.dataArray replaceObjectAtIndex:self.selectedIndexPath.row withObject:tweet];
    self.dataArray[self.selectedIndexPath.row] = tweet;
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tweetViewController:(TweetViewController *)vc removeTweetData:(NSDictionary *)tweet {
    [self.dataArray removeObjectAtIndex:self.selectedIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
