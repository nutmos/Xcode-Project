//
//  UserDetailViewController.m
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "UserDetailViewController.h"
#import "AppDelegate.h"
#import "TweetCell.h"
#import "UserCell.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#define TWEETS_SELECTED 0
#define FOLLOWING_SELECTED 1
#define FOLLOWERS_SELECTED 2
#define LISTS_SELECTED 3

@interface UserDetailViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rowSelected = 0;
    if (self.rowSelected == TWEETS_SELECTED) {
        [self getUserTimeline];
        self.navigationItem.title = @"Tweets";
    }
    else if (self.rowSelected == FOLLOWERS_SELECTED) {
        [self getFollowersTimeline];
        self.navigationItem.title = @"Followers";
    }
}

- (void)getFollowersTimeline {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.account.count) {
        NSLog(@"account.count = %d",appDelegate.account.count);
        ACAccount *twitterAccount = [appDelegate.account objectAtIndex:0];
        NSURL *feed = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[twitterAccount accountDescription] stringByReplacingOccurrencesOfString:@"@" withString:@""], @"screen_name", @"50", @"count", nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = twitterAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            self.dataArray = [dataDict objectForKey:@"users"];
            NSLog(@"self.dataArray = %@", self.dataArray);
            if (self.dataArray.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    }
}

- (void)getUserTimeline {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.account.count) {
        NSLog(@"account.count = %d",appDelegate.account.count);
        ACAccount *twitterAccount = [appDelegate.account objectAtIndex:0];
        NSURL *feed = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"50", @"count", nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = twitterAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            self.dataArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            if (self.dataArray.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    }
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.rowSelected == TWEETS_SELECTED) {
        /*NSString *cellID = @"cellID";
        TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        NSDictionary *tweet = [self.dataArray objectAtIndex:indexPath.row];
        NSDictionary *user = [tweet objectForKey:@"user"];
        cell.tweetView.text = [tweet objectForKey:@"text"];
        cell.name.text = [user objectForKey:@"name"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]];
        cell.avatar.image = [UIImage imageWithData:data];
        NSLog(@"cell = %@", cell);
        return cell;*/
        NSString *cellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        NSDictionary *tweet = [self.dataArray objectAtIndex:indexPath.row];
        //NSDictionary *user = [tweet objectForKey:@"user"];
        cell.textLabel.text = [tweet objectForKey:@"text"];
        return cell;
    }
    else if (self.rowSelected == FOLLOWERS_SELECTED) {
        NSString *cellID = @"userCellID";
        UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        NSLog(@"%d",indexPath.row);
        NSDictionary *user = [self.dataArray objectAtIndex:indexPath.row];
        cell.followers.text = [user objectForKey:@"followers_count"];
        cell.following.text = [user objectForKey:@"friends_count"];
        cell.name.text = [user objectForKey:@"name"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]];
        cell.avatar.image = [UIImage imageWithData:data];
        return cell;
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
