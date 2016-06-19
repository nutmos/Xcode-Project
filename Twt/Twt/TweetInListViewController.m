//
//  TweetInListViewController.m
//  Twt
//
//  Created by Nattapong Mos on 24/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(unsigned int, GetTweetInListOption) {
    GetTweetInListOptionGetAll,
    GetTweetInListOptionOlderThan,
};

#import "TweetInListViewController.h"
#import "AppDelegate.h"
#import "UserViewController.h"
#import "UIViewController+RequiredObject.h"
#import "ListDetailViewController.h"
#import "BrowserViewController.h"
#import "ImageViewController.h"
#import "LoadMoreCell.h"

@interface TweetInListViewController ()

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *detailButton;

@end

@implementation TweetInListViewController

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
    self.title = self.listDetail[@"name"];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshMyTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    if (self.backBarButtonItemTitle) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.navigationItem.rightBarButtonItem = self.detailButton;
    NSNumber *listID = self.listDetail[@"id"];
    if (listID) {
        [self getTweetInListID:self.listDetail[@"id"] option:GetTweetInListOptionGetAll tweetID:nil];
    }
}

- (void)refreshMyTable:(UIRefreshControl *)refresh {
    [self getTweetInListID:self.listDetail[@"id"] option:GetTweetInListOptionGetAll tweetID:nil];
    [refresh endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interactions

- (IBAction)didDetailButtonPressed:(UIBarButtonItem *)sender {
    self.listDetailSentToNextVC = self.listDetail;
    [self performSegueWithIdentifier:@"ToListDetail" sender:self];
}

#pragma mark - Get Data Method

- (void)getTweetInListID:(NSNumber *)listID option:(GetTweetInListOption)option tweetID:(NSNumber *)tweetID {
    if (self.appDelegate.account.count) {
        NSDictionary *parameters;
        if (option == GetTweetInListOptionGetAll) {
            parameters = @{@"list_id": listID.stringValue, @"count": @"50"};
        }
        else if (option == GetTweetInListOptionOlderThan) {
            parameters = @{@"list_id": listID.stringValue, @"max_id": tweetID.stringValue, @"count": @"50"};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[self.appDelegate requestURLWithOption:RequestGetTweetInListURL stringParameter:nil] parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                id data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if ([data count] && [data isKindOfClass:[NSArray class]]) {
                        NSLog(@"data count");
                        if (option == GetTweetInListOptionOlderThan) {
                            [self.dataArray removeLastObject];
                            [self.dataArray addObjectsFromArray:data];
                        }
                        else {
                            self.dataArray = [data mutableCopy];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.dataArray.count + 1;
    }
    else {
        return self.searchResultArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count && tableView == self.tableView) {
        LoadMoreCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"loadMoreID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadMoreID"];
        }*/
        [cell startActivity];
        return cell;
    }
    else {
        TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        }*/
        NSArray *arr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
        [cell setTweetCellWithTweetDictionary:arr[indexPath.row] inViewController:self delegate:self];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init data
    if (indexPath.row == self.dataArray.count && tableView == self.tableView) {
        return 44.0f;
    }
    else {
        NSArray *arr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
        return [TweetCell calculateTweetCellHeightWithTweetDictionary:arr[indexPath.row] option:TweetCellShowTweet];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    self.tweetSentToNextVC = ((TweetCell *)[tableView cellForRowAtIndexPath:indexPath]).tweetDict;
    [self performSegueWithIdentifier:@"ToTweet" sender:self];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count - 1) {
        [self getTweetInListID:self.listDetail[@"id"] option:GetTweetInListOptionOlderThan tweetID:((TweetCell *)cell).tweetDict[@"id"]];
    }
}

#pragma mark - Navigation

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
    else if ([segueID isEqualToString:@"ToListDetail"]) {
        ListDetailViewController *vc = segue.destinationViewController;
        vc.listData = self.listDetail;
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
}

#pragma mark - Tweet View Controller Delegate

- (void)tweetViewController:(TweetViewController *)vc tweetData:(NSDictionary *)tweet {
    //[self.dataArray replaceObjectAtIndex:self.selectedIndexPath.row withObject:tweet];
    self.dataArray[self.selectedIndexPath.row] = tweet;
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    NSString *url = urlEntities[@"url"];
    if (url) {
        self.urlSentToNextVC = [NSURL URLWithString:url];
        [self performSegueWithIdentifier:@"ToBrowser" sender:self];
    }
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
