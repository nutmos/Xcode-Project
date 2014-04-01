//
//  UserViewController.m
//  Twt
//
//  Created by Nattapong Mos on 18/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "UserViewController.h"
#import "AppDelegate.h"
#import "NewTweetViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UserDetailViewController.h"
#define TWEETS_SELECTED 0
#define FOLLOWING_SELECTED 1
#define FOLLOWERS_SELECTED 2
#define LISTS_SELECTED 3

@interface UserViewController ()

//@property (strong, nonatomic) NSArray *detailArray;
@property (strong, nonatomic) NSDictionary *user;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];/*
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshMyTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;*/
    /*self.avatarImage = [[UIImageView alloc] init];
    self.coverImage = [[UIImageView alloc] init];
    self.usernameLabel = [[UILabel alloc] init];
    self.screenNameLabel = [[UILabel alloc] init];
    self.tableView = [[UITableView alloc] init];*/
    [self getDetail];
}

- (void)getDetail {
    NSLog(@"1");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    NSLog(@"2");
    if (appDelegate.account.count) {
        sharedApplication.networkActivityIndicatorVisible = YES;
        NSLog(@"3 account.count = %d",appDelegate.account.count);
        ACAccount *twitterAccount = [appDelegate.account objectAtIndex:0];
        NSLog(@"4");
        NSURL *feed = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/lookup.json"];
        NSLog(@"5");
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[twitterAccount accountDescription] stringByReplacingOccurrencesOfString:@"@" withString:@""], @"screen_name", nil];
        NSLog(@"6");
        //NSLog(@"Account Description = %@", [twitterAccount accountDescription]);
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        NSLog(@"7");
        request.account = twitterAccount;
        NSLog(@"8");
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSLog(@"8.1");
            NSArray *detailArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            //NSLog(@"%@",self.detailArray);
            NSLog(@"8.2");
            self.user = [detailArray objectAtIndex:0];
            NSLog(@"8.3");
            [self initDetail];
        }];
        sharedApplication.networkActivityIndicatorVisible = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UserDetailViewController *vc = [segue destinationViewController];
        vc.rowSelected = indexPath.row;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"userToNewTweet"]) {
        NewTweetViewController *vc = [segue destinationViewController];
        vc.segueID = @"userToNewTweet";
    }
}

- (void)initDetail {
    //NSLog(@"20 %@",self.user);
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    sharedApplication.networkActivityIndicatorVisible = YES;
    self.avatarImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.user objectForKey:@"profile_image_url"]]]];
    self.coverImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[self.user objectForKey:@"profile_banner_url"] stringByAppendingString:@"/mobile_retina"]]]];
    [self.tableView reloadData];
    self.usernameLabel.text = [self.user objectForKey:@"name"];
    self.screenNameLabel.text = [@"@" stringByAppendingString:[self.user objectForKey:@"screen_name"]];
    self.navigationBar.title = [self.user objectForKey:@"screen_name"];
    [self viewWillAppear:NO];
    sharedApplication.networkActivityIndicatorVisible = NO;
}

- (void)unwindToList:(UIStoryboardSegue *)segue {
    id vc = [segue sourceViewController];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"9");
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    NSLog(@"10");
    //NSLog(@"11 %@", self.user);
    NSNumberFormatter *fmtr = [[NSNumberFormatter alloc] init];
    [fmtr setGroupingSeparator:@","];
    [fmtr setGroupingSize:3];
    if (indexPath.row == TWEETS_SELECTED) {
        NSLog(@"12");
        cell.textLabel.text = @"Tweets";
        //NSLog(@"13 %@",self.user[@"statuses_count"]);
        if (self.user != nil) {
            cell.detailTextLabel.text = [fmtr stringFromNumber:[self.user objectForKey:@"statuses_count"]];
        }
    }
    else if (indexPath.row == FOLLOWING_SELECTED) {
        NSLog(@"14");
        cell.textLabel.text = @"Following";
        NSLog(@"15");
        if (self.user != nil) {
            cell.detailTextLabel.text = [fmtr stringFromNumber:[self.user objectForKey:@"friends_count"]];
        }
    }
    else if (indexPath.row == FOLLOWERS_SELECTED) {
        NSLog(@"16");
        cell.textLabel.text = @"Followers";
        NSLog(@"17");
        if (self.user != nil) {
            cell.detailTextLabel.text = [fmtr stringFromNumber:[self.user objectForKey:@"followers_count"]];
        }
    }
    else if (indexPath.row == LISTS_SELECTED) {
        NSLog(@"18");
        cell.textLabel.text = @"Listed";
        NSLog(@"19");
        if (self.user != nil) {
            cell.detailTextLabel.text = [fmtr stringFromNumber:[self.user objectForKey:@"listed_count"]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserDetailViewController *vc = [[UserDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.rowSelected = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
