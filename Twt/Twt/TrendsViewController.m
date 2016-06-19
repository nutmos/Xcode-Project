//
//  TrendsViewController.m
//  Twt
//
//  Created by Nattapong Mos on 14/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "AppDelegate.h"
#import "TrendsViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "DetailViewController.h"
#import "SearchResultViewController.h"

@interface TrendsViewController ()

@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSString *lang;
@property (nonatomic) NSInteger rowSelected;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *slugSentToNextVC;

@end

@implementation TrendsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    if (self.backBarButtonItemTitle) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    if (self.option == TrendsShowingTypeTrends) {
        self.navigationItem.title = self.trendsLocation;
        [self getTrendsAtWOEID:@(self.trendsWOEID)];
    }
    else if (self.option == TrendsShowingTypeUserSuggestions) {
        self.navigationItem.title = @"Browse User";
        self.navigationItem.rightBarButtonItem = nil;
        [self getUserLang];
    }
}

- (IBAction)didLocationButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ToAllLocations" sender:self];
}

#pragma mark - Get Data Method

- (void)getUserLang {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetUserLanguageURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": self.appDelegate.currentAccount.username};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && !(data[@"errors"])) {
                        self.lang = data[@"lang"];
                        [self getUserSuggestions:self.lang];
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

- (void)getUserSuggestions:(NSString *)lang {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetUserSuggestionURL stringParameter:nil];
        NSDictionary *parameters = @{@"lang": lang};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        self.dataArray = data;
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

- (void)getTrendsAtWOEID:(NSNumber *)woeid {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetTrendsAtPlaceURL stringParameter:nil];
        NSDictionary *parameters = @{@"id": [woeid stringValue]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error][0][@"trends"];
                if ([data isKindOfClass:[NSArray class]]) {
                    NSArray * trendsData = data[0][@"trends"];
                    if (trendsData.count && [trendsData isKindOfClass:[NSArray class]]) {
                        self.dataArray = trendsData;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }
                else if ([data isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"errors = %@", ((NSDictionary *)data)[@"errors"]);
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trendID" forIndexPath:indexPath];
    /*if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"trendID"];
    }*/
    if (self.option == TrendsShowingTypeTrends) {
        cell.textLabel.text = self.dataArray[indexPath.row][@"name"];
    }
    else if (self.option == TrendsShowingTypeUserSuggestions) {
        cell.textLabel.text = self.dataArray[indexPath.row][@"name"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rowSelected = indexPath.row;
    if (self.option == TrendsShowingTypeTrends) {
        self.searchStringSentToNextVC = self.dataArray[indexPath.row][@"name"];
    }
    else {
        self.slugSentToNextVC = self.dataArray[indexPath.row];
    }
    [self performSegueWithIdentifier:@"ToSearchResult" sender:self];
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSearchResult"]) {
        SearchResultViewController *vc = segue.destinationViewController;
        vc.backBarButtonItemTitle = @"Trends";
        if (self.option == TrendsShowingTypeTrends) {
            vc.showingType = SearchResultShowingTypeTweets;
            vc.searchText = self.searchStringSentToNextVC;
            vc.isSaved = NO;
            for (NSDictionary *savedSearch in self.savedSearchArray) {
                if ([self.searchStringSentToNextVC isEqualToString:savedSearch[@"query"]]) {
                    vc.isSaved = YES;
                    break;
                }
            }
        }
        else if (self.option == TrendsShowingTypeUserSuggestions) {
            vc.showingType = SearchResultShowingTypeUserSuggestions;
            vc.slug = self.slugSentToNextVC;
            vc.lang = self.lang;
        }
    }
}

- (IBAction)unwindToTrends:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"ToTrends"]) {
        self.navigationItem.title = self.trendsLocation;
        [self getTrendsAtWOEID:@(self.trendsWOEID)];
    }
    else if ([segue.identifier isEqualToString:@"CancelPressToTrends"]) {
        
    }
}

@end
