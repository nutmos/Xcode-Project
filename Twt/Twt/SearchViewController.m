//
//  SearchViewController.m
//  Twt
//
//  Created by Nattapong Mos on 23/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "SearchViewController.h"
#import "UserViewController.h"
#import "DetailViewController.h"
#import "TrendsViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UIViewController+RequiredObject.h"
#import "SearchResultViewController.h"

@interface SearchViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *oldSearchText;
@property (nonatomic) RowSelected rowSelected;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *savedSearchArray;
@property UseType typeToUse;

@end

@implementation SearchViewController

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
    self.searchBar.delegate = self;
    self.oldSearchText = self.searchBar.text;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.backBarButtonItemTitle) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    [self getSavedSearch];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Data Method

- (void)postDestroySavedSearchWithID:(NSNumber *)savedSearchID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostDestroySavedSearchURL stringParameter:[savedSearchID stringValue]];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:nil];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && !data[@"errors"]) {
                        [self getSavedSearch];
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

- (void)getSavedSearch {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetSavedSearchListURL stringParameter:nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:nil];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        self.savedSearchArray = data;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    else if (section == 1) {
        return @"Saved Search";
    }
    else {
        return @"Browse";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([self.searchBar.text isEqualToString:@""]) {
            return 0;
        }
        else {
            return 3;
        }
    }
    else if (section == 1) {
        return self.savedSearchArray.count == 0 ? 1 : self.savedSearchArray.count;
    }
    else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"searchID";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"Go to user @%@", self.searchBar.text];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"Search tweets about \"%@\"", self.searchBar.text];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"Search users about \"%@\"", self.searchBar.text];
        }
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell;
        if (self.savedSearchArray.count == 0) {
            static NSString *cellID = @"searchID2";
            cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            cell.textLabel.text = @"No Saved Search";
            cell.textLabel.textColor = [UIColor grayColor];
            cell.userInteractionEnabled = NO;
        }
        else {
            static NSString *cellID = @"searchID";
            cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            cell.textLabel.text = self.savedSearchArray[indexPath.row][@"query"];
        }
        return cell;
    }
    else {
        static NSString *cellID = @"searchID";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Trends";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Users";
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rowSelected = (RowSelected)indexPath.row;
    if (indexPath.section == 0) {
        self.typeToUse = UseTypingText;
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"ToUser" sender:self];
        }
        else if (indexPath.row == 1 || indexPath.row == 2) {
            self.searchStringSentToNextVC = self.searchBar.text;
            [self performSegueWithIdentifier:@"ToSearchResult" sender:self];
        }
    }
    else if (indexPath.section == 1) {
        self.typeToUse = UseSavedSearch;
        self.searchStringSentToNextVC = self.savedSearchArray[indexPath.row][@"query"];
        [self performSegueWithIdentifier:@"ToSearchResult" sender:self];
    }
    else {
        self.rowSelected = (RowSelected)indexPath.row;
        [self performSegueWithIdentifier:@"ToTrends" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    }
    else {
        return NO;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        @synchronized (self) {
            [self postDestroySavedSearchWithID:self.savedSearchArray[indexPath.row][@"id"]];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    if ([segueID isEqualToString:@"ToUser"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.screenName = self.searchBar.text;
    }
    else if ([segueID isEqualToString:@"ToSearchResult"]) {
        SearchResultViewController *vc = segue.destinationViewController;
        vc.searchText = self.searchStringSentToNextVC;
        if (self.typeToUse == UseSavedSearch) {
            vc.showingType = SearchResultShowingTypeTweets;
            vc.isSaved = YES;
        }
        else {
            if (self.rowSelected == RowSearchTweetsSelected) {
                vc.showingType = SearchResultShowingTypeTweets;
                vc.isSaved = NO;
                for (NSDictionary *savedSearch in self.savedSearchArray) {
                    if ([self.searchStringSentToNextVC isEqualToString:savedSearch[@"query"]]) {
                        vc.isSaved = YES;
                        break;
                    }
                }
            }
            else if (self.rowSelected == RowSearchUsersSelected) {
                vc.showingType = SearchResultShowingTypeUsers;
            }
        }
    }
    else if ([segueID isEqualToString:@"ToTrends"]) {
        TrendsViewController *vc = segue.destinationViewController;
        if (self.rowSelected == 0) {
            vc.trendsLocation = @"Worldwide";
            vc.trendsWOEID = 1;
            vc.savedSearchArray = self.savedSearchArray;
            vc.option = TrendsShowingTypeTrends;
        }
        else {
            vc.option = TrendsShowingTypeUserSuggestions;
        }
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Search Display Controller and Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([self.oldSearchText isEqualToString:@""] || [searchBar.text isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    self.oldSearchText = searchBar.text;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
