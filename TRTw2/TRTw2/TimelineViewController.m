//
//  TimelineViewController.m
//  TRTw2
//
//  Created by Nattapong Mos on 9/2/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "TweetCell.h"
#import "AppDelegate.h"
#import <Social/Social.h>
#import "TimelineViewController.h"

@interface TimelineViewController ()

@property (strong, nonatomic) NSArray *tweetsArray;

@end

@implementation TimelineViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweetsArray count];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.userAccount) {
        [self viewTimeline];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewTimeline) name:@"TwitterAccountAcquiredNotification" object:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"in selector");
    static NSString *cellID = @"cellID";
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        //NSLog(@"in if");
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSDictionary *tweets = self.tweetsArray[indexPath.row];
    cell.tweetLabel.text = tweets[@"text"];
    NSDictionary *user = tweets[@"user"];
    cell.usernameLabel.text = user[@"name"];
    cell.avatarImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"profile_image_url"]]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewTimeline {
    NSURL *feedURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"15", @"count", nil];
    
    SLRequest *twitterFeed = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feedURL parameters:parameters];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    twitterFeed.account = appDelegate.userAccount;
    
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    sharedApplication.networkActivityIndicatorVisible = YES;
    
    [twitterFeed performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error) {
            NSError *jsonError = nil;
            self.tweetsArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            if (!jsonError) {
                [self.tableView reloadData];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[jsonError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    sharedApplication.networkActivityIndicatorVisible = NO;
    
    /*
    ACAccountStore *accounts = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [accounts accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accounts requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *arrayOfAccounts = [accounts accountsWithAccountType:twitterType];
            if (arrayOfAccounts > 0) {
                ACAccount *twitterAccount = arrayOfAccounts[0];
                NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                [parameters setObject:@"100" forKey:@"count"];
                [parameters setObject:@"1" forKey:@"include_entities"];
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
                posts.account = twitterAccount;
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    self.tweetsArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                    //NSLog(@"%@",self.tweetsArray[0]);
                    if (self.tweetsArray.count != 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }];
            }
        } else {
            NSLog(@"Error %@",error);
        }
    }];*/
}

@end
