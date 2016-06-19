//
//  UserDetailViewController.m
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "MutedUsersViewController.h"
#import "TweetViewController.h"
#import "AppDelegate.h"
#import "LoadMoreCell.h"
#import "UserCell.h"
#import "UserViewController.h"
#import "TweetInListViewController.h"
#import "ListDetailViewController.h"
#import "UIViewController+RequiredObject.h"

@interface MutedUsersViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) NSIndexPath *selectedRow;
@property (strong, nonatomic) NSNumber *nextCursor;

@end

@implementation MutedUsersViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    //NSLog(@"view did load");
    [super viewDidLoad];
    if (self.backBarButtonItemTitle != nil) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshMyTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [self.appDelegate clearTableFooterView];
    [self refreshMyTable:refresh];
}

- (void)refreshMyTable:(UIRefreshControl *)refresh {
    [self getMutedListOption:RequestGETOptionGetAll];
    [refresh endRefreshing];
}

#pragma mark - Get Data Method

- (void)getMutedListOption:(RequestGETOption)option {
    if (self.appDelegate.account.count) {
        NSDictionary *parameters = nil;
        if (option == RequestGETOptionGetMoreThan) {
            parameters = @{@"cursor": [self.nextCursor stringValue]};
        }
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetMutedUserListURL stringParameter:nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && data[@"errors"] == nil) {
                        NSArray *usersArray = data[@"users"];
                        NSLog(@"data = %@", data);
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
        NSArray *dataArr = (tableView == self.tableView) ? self.dataArray : self.searchResultArray;
        [cell setUserDictionary:dataArr[indexPath.row] inViewController:self];
        return cell;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count - 1 && tableView == self.tableView) {
        if (self.nextCursor.integerValue == 0) {
            LoadMoreCell *cell = (LoadMoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0]];
            [cell stopActivity];
        }
        else {
            [self getMutedListOption:RequestGETOptionGetMoreThan];
        }
    }
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
