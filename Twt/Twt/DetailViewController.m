//
//  UserDetailViewController.m
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "DetailViewController.h"
#import "SearchResultViewController.h"
#import "TweetViewController.h"
#import "AppDelegate.h"
#import "UserCell.h"
#import "LoadMoreCell.h"
#import "ListCell.h"
#import "UserViewController.h"
#import "TweetInListViewController.h"
#import "ListDetailViewController.h"
#import "CreateListViewController.h"
#import "UIViewController+RequiredObject.h"
#import "BrowserViewController.h"
#import "ImageViewController.h"
#import "AddListMemberViewController.h"

@interface DetailViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *dataArray2;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIToolbar *listSegmented;
@property (weak, nonatomic) IBOutlet UISegmentedControl *listSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMemberButton;
@property (nonatomic, strong) NSIndexPath *selectedRow;
@property (strong, nonatomic) NSNumber *nextCursor;

@end

@implementation DetailViewController

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
    self.tableView2.hidden = YES;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [self.appDelegate clearTableFooterView];
    if (self.backBarButtonItemTitle != nil) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshMyTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    if (self.options == DetailShowingTypeTweets) {
        self.navigationItem.title = @"Tweets";
    }
    else if (self.options == DetailShowingTypeFollowers) {
        self.navigationItem.title = @"Followers";
    }
    else if (self.options == DetailShowingTypeFollowing) {
        self.navigationItem.title = @"Following";
    }
    else if (self.options == DetailShowingTypeLists) {
        [self.view addSubview:self.listSegmented];
        self.navigationItem.rightBarButtonItem = self.addButton;
        self.navigationItem.title = @"Lists";
    }
    else if (self.options == DetailShowingTypeFavourites) {
        self.navigationItem.title = @"Favorite";
    }
    else if (self.options == DetailShowingTypeListFollowers) {
        self.navigationItem.title = @"List Followers";
    }
    else if (self.options == DetailShowingTypeListMembers) {
        self.navigationItem.title = @"List Members";
        if ([self.listDetail[@"user"][@"screen_name"] isEqualToString:self.appDelegate.currentAccount.username]) {
            self.navigationItem.rightBarButtonItem = self.addMemberButton;
        }
    }
    else if (self.options == DetailShowingTypeRetweetedBy) {
        self.navigationItem.title = @"Retweeted By";
    }
    [self refreshMyTable:refresh];
}

- (void)refreshMyTable:(UIRefreshControl *)refresh {
    if (self.options == DetailShowingTypeTweets) {
        [self getUserTimelineForUserScreenName:self.screenName option:RequestGETOptionGetAll tweetID:nil];
    }
    else if (self.options == DetailShowingTypeFollowers) {
        [self getFollowersListForUserScreenName:self.screenName option:RequestGETOptionGetAll];
    }
    else if (self.options == DetailShowingTypeFollowing) {
        [self getFriendsListForUserScreenName:self.screenName option:RequestGETOptionGetAll];
    }
    else if (self.options == DetailShowingTypeLists) {
        [self getSubscribedListForUserScreenName:self.screenName];
    }
    else if (self.options == DetailShowingTypeFavourites) {
        [self getFavoritesForUserScreenName:self.screenName option:RequestGETOptionGetAll tweetID:nil];
    }
    else if (self.options == DetailShowingTypeListFollowers) {
        [self getListSubscribersForListID:self.listID option:RequestGETOptionGetAll];
    }
    else if (self.options == DetailShowingTypeListMembers) {
        [self getListMembersForListID:self.listID option:RequestGETOptionGetAll];
    }
    else if (self.options == DetailShowingTypeRetweetedBy) {
        [self getRetweetedByTweetID:self.tweetID];
    }
    [refresh endRefreshing];
}

#pragma mark - Get Data Method

- (void)postRemoveListMemberScreenName:(NSString *)screenName listID:(NSNumber *)listID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostDestroyListMemberURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": screenName, @"list_id": [listID stringValue]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getListMembersForListID:self.listID option:RequestGETOptionGetAll];
                });
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getRetweetedByTweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetRetweetedByURL stringParameter:[tweetID stringValue]];
        NSDictionary *parameters = @{@"id": tweetID.stringValue, @"count": @"50"};
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

- (void)postSaveSearch:(NSString *)searchString {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostCreateSaveSearchURL stringParameter:nil];
        NSDictionary *parameters = @{@"query": searchString};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            //NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            self.navigationItem.rightBarButtonItem = nil;
            [self viewWillAppear:NO];
        }];
    }
}

- (void)getListSubscribersForListID:(NSNumber *)listID option:(RequestGETOption)option {
    if (self.appDelegate.account.count) {
        ACAccount *twitterAccount = self.appDelegate.currentAccount;
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetListFollowersURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"list_id": listID.stringValue};
        }
        else {
            parameters = @{@"list_id": listID.stringValue, @"cursor": self.nextCursor.stringValue};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = twitterAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([dataDict isKindOfClass:[NSDictionary class]]) {
                    if (dataDict.count && !dataDict[@"errors"]) {
                        self.nextCursor = dataDict[@"next_cursor"];
                        NSArray *usersArr = dataDict[@"users"];
                        if (usersArr.count) {
                            if (option == RequestGETOptionGetAll) {
                                self.dataArray = usersArr.mutableCopy;
                            }
                            else {
                                [self.dataArray addObjectsFromArray:usersArr];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }
                    }
                    else if (dataDict[@"errors"]) {
                        NSLog(@"error = %@", dataDict[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getListMembersForListID:(NSNumber *)listID option:(RequestGETOption)option {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetListMembersURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"list_id": listID.stringValue};
        }
        else {
            parameters = @{@"list_id": listID.stringValue, @"cursor": self.nextCursor.stringValue};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([dataDict isKindOfClass:[NSDictionary class]]) {
                    if (dataDict.count && dataDict[@"errors"] == nil) {
                        self.nextCursor = dataDict[@"next_cursor"];
                        NSArray *usersArr = dataDict[@"users"];
                        if (usersArr.count) {
                            if (option == RequestGETOptionGetAll) {
                                self.dataArray = usersArr.mutableCopy;
                            }
                            else {
                                [self.dataArray addObjectsFromArray:usersArr];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }
                    }
                    else if (dataDict[@"errors"]) {
                        NSLog(@"error = %@", dataDict[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getFollowersListForUserScreenName:(NSString *)screenName option:(RequestGETOption)option {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetFollowersListURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"screen_name": screenName, @"count": @"50"};
        }
        else {
            parameters = @{@"screen_name": screenName, @"count": @"50", @"cursor": self.nextCursor.stringValue};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([dataDict isKindOfClass:[NSDictionary class]]) {
                    if (dataDict.count && dataDict[@"errors"] == nil) {
                        self.nextCursor = dataDict[@"next_cursor"];
                        NSArray *usersArr = dataDict[@"users"];
                        if (usersArr.count) {
                            if (option == RequestGETOptionGetAll) {
                                self.dataArray = usersArr.mutableCopy;
                            }
                            else {
                                [self.dataArray addObjectsFromArray:usersArr];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getFriendsListForUserScreenName:(NSString *)screenName option:(RequestGETOption)option {
    if (self.appDelegate.account.count) {
        ACAccount *twitterAccount = self.appDelegate.currentAccount;
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetFriendsListURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"screen_name": screenName, @"count": @"50"};
        }
        else {
            parameters = @{@"screen_name": screenName, @"count": @"50", @"cursor": self.nextCursor.stringValue};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = twitterAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([dataDict isKindOfClass:[NSDictionary class]]) {
                    if (dataDict.count && dataDict[@"errors"] == nil) {
                        self.nextCursor = dataDict[@"next_cursor"];
                        NSArray *dataArr = dataDict[@"users"];
                        if (dataArr.count) {
                            if (option == RequestGETOptionGetAll) {
                                self.dataArray = dataArr.mutableCopy;
                            }
                            else {
                                [self.dataArray addObjectsFromArray:dataArr];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }
                        else {
                            
                        }
                    }
                    else if (dataDict[@"errors"]) {
                        NSLog(@"error = %@", dataDict[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getUserTimelineForUserScreenName:(NSString *)screenName option:(RequestGETOption)option tweetID:(NSNumber *)tweetID {
    NSLog(@"get user timeline");
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetUserTimelineURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"screen_name": screenName, @"50": @"count"};
        }
        else {
            parameters = @{@"screen_name": screenName, @"50": @"count", @"max_id": tweetID.stringValue};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        if (option == RequestGETOptionGetAll) {
                            self.dataArray = data.mutableCopy;
                        }
                        else {
                            [self.dataArray removeLastObject];
                            [self.dataArray addObjectsFromArray:data];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                    else if (data.count == 0) {
                        NSLog(@"data count = 0");
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0];
                        LoadMoreCell *cell = (LoadMoreCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                        [cell stopActivity];
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

- (void)getFavoritesForUserScreenName:(NSString *)screenName option:(RequestGETOption)option tweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetFavouritesListURL stringParameter:nil];
        NSDictionary *parameters;
        if (option == RequestGETOptionGetAll) {
            parameters = @{@"screen_name": screenName, @"count": @"50"};
        }
        else {
            parameters = @{@"screen_name": screenName, @"count": @"50", @"max_id": tweetID.stringValue};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        if (option == RequestGETOptionGetAll) {
                            self.dataArray = data.mutableCopy;
                        }
                        else {
                            [self.dataArray removeLastObject];
                            [self.dataArray addObjectsFromArray:data];
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
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)getSubscribedListForUserScreenName:(NSString *)screenName {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetSubscribedListURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": screenName, @"count": @"20"};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        self.dataArray = data.mutableCopy;
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

- (void)getMemberOfListsForUserScreenName:(NSString *)screenName option:(RequestGETOption)option {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetMemberOfListsURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": screenName};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && data[@"errors"] == nil) {
                        //NSLog(@"data count");
                        NSArray *listsArray = data[@"lists"];
                        self.nextCursor = data[@"next_cursor"];
                        if (listsArray.count) {
                            if (option == RequestGETOptionGetAll) {
                                self.dataArray2 = listsArray.mutableCopy;
                            }
                            else {
                                [self.dataArray2 addObjectsFromArray:listsArray];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView2 reloadData];
                            });
                        }
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

#pragma mark - Navigation

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    if ([segueID isEqualToString:@"ToUser"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.screenName = self.userSentToNextVC[@"screen_name"];
        vc.avatarImage = self.avatarSentToNextVC;
    }
    else if ([segueID isEqualToString:@"ToTweetInList"]) {
        TweetInListViewController *vc = segue.destinationViewController;
        vc.listDetail = self.listDetailSentToNextVC;
    }
    else if ([segueID isEqualToString:@"ToListDetail"]) {
        ListDetailViewController *vc = segue.destinationViewController;
        vc.listData = self.listDetailSentToNextVC;
    }
    else if ([segueID isEqualToString:@"ToTweet"]) {
        TweetViewController *vc = segue.destinationViewController;
        vc.tweetDictionary = self.tweetSentToNextVC;
    }
    else if ([segueID isEqualToString:@"ToCreateList"]) {
        CreateListViewController *vc = (CreateListViewController *)[segue.destinationViewController visibleViewController];
        vc.option = CreateListTypeCreate;
    }
    else if ([segueID isEqualToString:@"ToBrowser"]) {
        BrowserViewController *vc = segue.destinationViewController;
        vc.address = self.urlSentToNextVC;
        vc.hidesBottomBarWhenPushed = YES;
    }
    else if ([segueID isEqualToString:@"ToImage"]) {
        ImageViewController *vc = segue.destinationViewController;
        vc.image = self.imageSentToNextVC;
        vc.imageLink = self.urlSentToNextVC;
        vc.shareLink = self.shareUrlSentToNextVC;
    }
    else if ([segueID isEqualToString:@"ToSearchResult"]) {
        SearchResultViewController *vc = segue.destinationViewController;
        vc.searchText = self.searchStringSentToNextVC;
        vc.showingType = SearchResultShowingTypeTweets;
    }
    else if ([segueID isEqualToString:@"ToAddListMember"]) {
        AddListMemberViewController *vc = (AddListMemberViewController *)[segue.destinationViewController visibleViewController];
    }
}

#pragma mark - User Interaction

- (IBAction)didAddMemberButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ToAddListMember" sender:self];
}

- (IBAction)didSegmentedControlPressed:(UISegmentedControl *)sender {
    // Select Following Lists
    if (sender.selectedSegmentIndex == 0) {
        self.tableView2.hidden = YES;
        self.tableView.hidden = NO;
        if (!self.dataArray.count) {
            [self getSubscribedListForUserScreenName:self.screenName];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
    else {
        if (self.tableView2 == nil) {
            self.tableView2 = [[UITableView alloc] initWithFrame:self.tableView.frame];
        }
        self.tableView.hidden = YES;
        self.tableView2.hidden = NO;
        if (!self.dataArray2.count) {
            [self getMemberOfListsForUserScreenName:self.screenName option:RequestGETOptionGetAll];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView2 reloadData];
            });
        }
    }
}

- (IBAction)didSaveButtonPressed:(UIBarButtonItem *)saveButton {
    saveButton.enabled = NO;
    [self viewWillAppear:NO];
    [self postSaveSearch:self.searchText];
}

- (IBAction)didAddButtonPressed:(UIBarButtonItem *)sender {
    if (self.options == DetailShowingTypeLists) {
        [self performSegueWithIdentifier:@"ToCreateList" sender:self];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count - 1) {
        if (self.options == DetailShowingTypeTweets) {
            [self getUserTimelineForUserScreenName:self.screenName option:RequestGETOptionGetMoreThan tweetID:((TweetCell *)cell).tweetDict[@"id"]];
        }
        else if (self.options == DetailShowingTypeFavourites) {
            [self getFavoritesForUserScreenName:self.screenName option:RequestGETOptionGetMoreThan tweetID:(((TweetCell *)cell).tweetDict)[@"id"]];
        }
        else if (self.options == DetailShowingTypeFollowing) {
            [self getFriendsListForUserScreenName:self.screenName option:RequestGETOptionGetMoreThan];
        }
        else if (self.options == DetailShowingTypeListFollowers) {
            [self getListSubscribersForListID:self.listID option:RequestGETOptionGetMoreThan];
        }
        else if (self.options == DetailShowingTypeLists) {
            if (self.listSegmentedControl.selectedSegmentIndex == 1) {
                [self getMemberOfListsForUserScreenName:self.screenName option:RequestGETOptionGetMoreThan];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    if (self.options == DetailShowingTypeLists) {
        ListCell *cell = (ListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        self.listDetailSentToNextVC = cell.listDetail;
        [self performSegueWithIdentifier:@"ToTweetInList" sender:self];
    }
    else if (self.options == DetailShowingTypeFollowing ||
             self.options == DetailShowingTypeFollowers ||
             self.options == DetailShowingTypeListMembers ||
             self.options == DetailShowingTypeListFollowers ||
             self.options == DetailShowingTypeRetweetedBy) {
        UserCell *cell = (UserCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        self.userSentToNextVC = cell.user;
        [self performSegueWithIdentifier:@"ToUser" sender:self];
    }
    else if (self.options == DetailShowingTypeFavourites ||
             self.options == DetailShowingTypeTweets) {
        self.tweetSentToNextVC = ((TweetCell *)[self.tableView cellForRowAtIndexPath:indexPath]).tweetDict;
        [self performSegueWithIdentifier:@"ToTweet" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    ListCell *cell = (ListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.listDetailSentToNextVC = cell.listDetail;
    [self performSegueWithIdentifier:@"ToListDetail" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.options == DetailShowingTypeListMembers) {
        if ([self.listDetail[@"user"][@"screen_name"] isEqualToString:self.appDelegate.currentAccount.username]) {
            return YES;
        }
        else return NO;
    }
    else return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UserCell *cell = (UserCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [self postRemoveListMemberScreenName:cell.screenName listID:self.listID];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return self.searchResultArray.count;
    }
    else {
        return self.dataArray.count + 1;
    }
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count && (tableView == self.tableView || tableView == self.tableView2)) {
        return 44.0f;
    }
    else {
        if (self.options == DetailShowingTypeTweets ||
            self.options == DetailShowingTypeFavourites) {
            // Init data
            NSArray *dataArr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
            return [TweetCell calculateTweetCellHeightWithTweetDictionary:dataArr[indexPath.row] option:TweetCellShowTweet];
        }
        else if (self.options == DetailShowingTypeFollowing ||
                 self.options == DetailShowingTypeFollowers ||
                 self.options == DetailShowingTypeListMembers ||
                 self.options == DetailShowingTypeListFollowers ||
                 self.options == DetailShowingTypeRetweetedBy) {
            NSArray *usersArr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
            return [UserCell calculateUserCellHeightWithUserDictionary:usersArr[indexPath.row]];
        }
        else if (self.options == DetailShowingTypeLists) {
            NSArray *listArr = (tableView != self.tableView) ? self.searchResultArray : (self.listSegmentedControl.selectedSegmentIndex == 0) ? self.dataArray : self.dataArray2;
            return [ListCell calculateListCellHeightWithListDictionary:listArr[indexPath.row]];
        }
        else return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count && tableView == self.tableView) {
        static NSString *cellID = @"loadMoreID";
        LoadMoreCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }*/
        [cell startActivity];
        return cell;
    }
    else {
        if (self.options == DetailShowingTypeTweets ||
            self.options == DetailShowingTypeFavourites) {
            static NSString *cellID = @"cellID";
            TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            /*if (!cell) {
                cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }*/
            NSArray *tweetArray = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
            [cell setTweetCellWithTweetDictionary:tweetArray[indexPath.row] inViewController:self delegate:self];
            return cell;
        }
        else if (self.options == DetailShowingTypeFollowing ||
                 self.options == DetailShowingTypeFollowers ||
                 self.options == DetailShowingTypeListMembers ||
                 self.options == DetailShowingTypeListFollowers ||
                 self.options == DetailShowingTypeRetweetedBy) {
            static NSString *cellID = @"userCellID";
            UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            /*if (!cell) {
                cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }*/
            NSArray *dataArr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
            NSDictionary *user = dataArr[indexPath.row];
            if (self.options == DetailShowingTypeRetweetedBy) {
                user = user[@"user"];
            }
            [cell setUserDictionary:user inViewController:self];
            return cell;
        }
        else if (self.options == DetailShowingTypeLists) {
            static NSString *cellID = @"listCellID";
            ListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            NSArray *listArray = (tableView == self.tableView) ? ((self.listSegmentedControl.selectedSegmentIndex == 0) ? self.dataArray : self.dataArray2) : self.searchResultArray;
            [cell setListDataDictionary:listArray[indexPath.row] inViewController:self];
            return cell;
        }
        else {
            return nil;
        }
    }
}

#pragma mark - Search Display Controller Delegate

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *resultPredicate;
    if (self.options == DetailShowingTypeLists) {
        resultPredicate = [NSPredicate predicateWithFormat:@"(description CONTAINS %@) || (name CONTAINS %@)", searchText, searchText];
        self.searchResultArray = [(self.listSegmentedControl.selectedSegmentIndex == 0)?self.dataArray:self.dataArray2 filteredArrayUsingPredicate:resultPredicate];
    }
    else {
        if (self.options == DetailShowingTypeTweets ||
            self.options == DetailShowingTypeFavourites) {
            resultPredicate = [NSPredicate predicateWithFormat:@"(text CONTAINS %@)", searchText];
        }
        else if (self.options == DetailShowingTypeFollowing ||
                 self.options == DetailShowingTypeFollowers ||
                 self.options == DetailShowingTypeListMembers ||
                 self.options == DetailShowingTypeListFollowers ||
                 self.options == DetailShowingTypeRetweetedBy) {
            resultPredicate = [NSPredicate predicateWithFormat:@"(name CONTAINS %@) || (screen_name CONTAINS %@)", searchText, searchText];
        }
        self.searchResultArray = [self.dataArray filteredArrayUsingPredicate:resultPredicate];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

#pragma mark - Search Bar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

#pragma mark - Tool Bar Delegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - Tweet View Controller Delegate

- (void)tweetViewController:(TweetViewController *)vc tweetData:(NSDictionary *)tweet {
    //[self.dataArray replaceObjectAtIndex:self.selectedIndexPath.row withObject:tweet];
    self.dataArray[self.selectedIndexPath.row] = tweet;
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tweetViewController:(TweetViewController *)vc removeTweetData:(NSDictionary *)tweet {
    dispatch_group_t g1 = dispatch_group_create();
    dispatch_queue_t q1 = dispatch_queue_create("q1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(g1, q1, ^{
        [self.dataArray removeObjectAtIndex:self.selectedIndexPath.row];
    });
    dispatch_group_wait(g1, DISPATCH_TIME_FOREVER);
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
