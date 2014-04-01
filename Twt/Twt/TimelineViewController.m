//
//  TimelineViewController.m
//  Twt
//
//  Created by Nattapong Mos on 16/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "TimelineViewController.h"
#import "AppDelegate.h"
#import "NewTweetViewController.h"
#import <Social/Social.h>
#import "TweetCell.h"

@interface TimelineViewController ()

@property (strong, nonatomic) NSArray *tweetsArray;
@property (assign, nonatomic) BOOL ascending;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshMyTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self getTimeline];
}

- (void)getTimeline {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.account.count) {
        NSLog(@"account.count = %d",appDelegate.account.count);
        ACAccount *twitterAccount = [appDelegate.account objectAtIndex:0];
        NSURL *feed = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"50", @"count", nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = twitterAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            self.tweetsArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            if (self.tweetsArray.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userToNewTweet"]) {
        NewTweetViewController *vc = [segue destinationViewController];
        vc.segueID = @"userToNewTweet";
    }
}

- (void)unwindToList:(UIStoryboardSegue *)segue {
    NewTweetViewController *vc = [segue sourceViewController];
}

#pragma mark - Table View Delegate

- (void)refreshMyTable:(UIRefreshControl *)refresh {
    [self getTimeline];
    [refresh endRefreshing];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"self.tweetsArray.count = %d",self.tweetsArray.count);
    return [self.tweetsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath = %d",indexPath.row);
    NSString *cellID = @"cellID";
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSDictionary *tweet = [self.tweetsArray objectAtIndex:indexPath.row];
    if ([tweet objectForKey:@"retweeted_status"]) {
        tweet = [tweet objectForKey:@"retweeted_status"];
    }
    NSDictionary *user = [tweet objectForKey:@"user"];
    cell.tweetView.text = [tweet objectForKey:@"text"];
    CGRect rect = cell.tweetView.frame;
    cell.name.text = [user objectForKey:@"name"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]];
    cell.avatar.image = [UIImage imageWithData:imageData];
    CGSize constraintSize = CGSizeMake(212.0f, MAXFLOAT);
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];
    CGRect tweetViewSize = [[tweet objectForKey:@"text"] boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    tweetViewSize.origin = rect.origin;
    cell.tweetView.frame = tweetViewSize;
    NSLog(@"%f", cell.tweetView.frame.size.height);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *tweet = [self.tweetsArray objectAtIndex:indexPath.row];
    if ([tweet objectForKey:@"retweeted_status"]) {
        tweet = [tweet objectForKey:@"retweeted_status"];
    }
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];
    NSString *tweetText = [tweet objectForKey:@"text"];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    CGSize constraintSize = CGSizeMake(212.0f, MAXFLOAT);
    CGRect tweetViewSize = [tweetText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    return tweetViewSize.size.height + 76;
}

@end
