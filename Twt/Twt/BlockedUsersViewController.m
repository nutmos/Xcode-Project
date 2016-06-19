//
//  UserDetailViewController.m
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "BlockedUsersViewController.h"
#import "TweetViewController.h"
#import "AppDelegate.h"
#import "UserCell.h"
#import "LoadMoreCell.h"
#import "UserViewController.h"
#import "TweetInListViewController.h"
#import "ListDetailViewController.h"
#import "UIViewController+RequiredObject.h"

@interface BlockedUsersViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) NSIndexPath *selectedRow;
@property (strong, nonatomic) NSNumber *nextCursor;
@property (strong, nonatomic) NSArray *searchResultArray;

@end

@implementation BlockedUsersViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.backBarButtonItemTitle) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [self.appDelegate clearTableFooterView];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshMyTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self refreshMyTable:refresh];
}

- (void)refreshMyTable:(UIRefreshControl *)refresh {
    [self getBlockedListOption:RequestGETOptionGetAll];
    [refresh endRefreshing];
}

#pragma mark - Get Data Method

- (void)getBlockedListOption:(RequestGETOption)option {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetBlocksListURL stringParameter:nil];
        NSDictionary *parameters = nil;
        if (option == RequestGETOptionGetMoreThan) {
            parameters = @{@"cursor": self.nextCursor};
        }
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && !data[@"errors"]) {
                        NSArray *usersArray = data[@"users"];
                        self.nextCursor = data[@"next_cursor"];
                        if (usersArray.count) {
                            if (option == RequestGETOptionGetAll) {
                                self.dataArray = [usersArray mutableCopy];
                            }
                            else {
                                [self.dataArray addObjectsFromArray:usersArray];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
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
    if ([segue.identifier isEqualToString:@"ToUser"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.screenName = self.userSentToNextVC[@"screen_name"];
        vc.avatarImage = self.avatarSentToNextVC;
    }
}

#pragma mark - Table View Data Source

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
        static NSString *cellID = @"loadMoreID";
        LoadMoreCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }*/
        [cell startActivity];
        return cell;
    }
    else {
        static NSString *cellID = @"userCellID";
        UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        /*if (!cell) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }*/
        NSArray *userArr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
        [cell setUserDictionary:userArr[indexPath.row] inViewController:self];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath.row == self.dataArray.count - 1) {
        //NSLog(@"next curser = %li", (long)self.nextCursor.integerValue);
        if (self.nextCursor.integerValue == 0) {
            //NSLog(@"next curser is 0");
            LoadMoreCell *cell = (LoadMoreCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0]];
            [cell stopActivity];
        }
        else {
            [self getBlockedListOption:RequestGETOptionGetMoreThan];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath.row == self.dataArray.count) {
        return 44.0f;
    }
    else {
        NSArray *usersArr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
        return [UserCell calculateUserCellHeightWithUserDictionary:usersArr[indexPath.row]];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = (UserCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.userSentToNextVC = cell.user;
    [self performSegueWithIdentifier:@"ToUser" sender:self];
}

#pragma mark - Search Display Controller Delegate

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(name CONTAINS %@)", searchText];
    self.searchResultArray = [self.dataArray filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

@end
