//
//  CountCell.m
//  Twt
//
//  Created by Nattapong Mos on 23/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "TweetDetailCell.h"
#import "UIViewController+RequiredObject.h"
#import "AppDelegate.h"

@interface TweetDetailCell ()

@property UITableViewController *vc;
@property (nonatomic, strong) NSDictionary *tweetDictionary;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property NSURL *appURL;

@end

@implementation TweetDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - User Interaction

- (void)didTimeLabelPressed:(UITapGestureRecognizer *)sender {
    self.vc.urlSentToNextVC = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.twitter.com/%@/status/%@", self.tweetDictionary[@"user"][@"screen_name"], self.tweetDictionary[@"id_str"]]];
    [self.vc performSegueWithIdentifier:@"ToBrowser" sender:self];
}

- (void)didViaLabelPressed:(UITapGestureRecognizer *)sender {
    self.vc.urlSentToNextVC = self.appURL;
    [self.vc performSegueWithIdentifier:@"ToBrowser" sender:self];
}

- (void)setTweetDictionary:(NSDictionary *)tweetDictionary inTableViewController:(UITableViewController *)vc {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.vc = vc;
    if (tweetDictionary[@"retweeted_status"]) {
        self.tweetDictionary = tweetDictionary[@"retweeted_status"];
    }
    else {
        self.tweetDictionary = tweetDictionary;
    }
    NSString *createdAt = self.tweetDictionary[@"created_at"];
    NSRange monthRange = {4,3}, dayRange = {8,2}, yearRange = {26, 4}, hourRange = {11,2}, minRange = {14,2};
    NSDateComponents *createdAtDate = [[NSDateComponents alloc] init];
    createdAtDate.year = [createdAt substringWithRange:yearRange].integerValue;
    createdAtDate.day = [createdAt substringWithRange:dayRange].integerValue;
    createdAtDate.month = [self.appDelegate.months[[createdAt substringWithRange:monthRange]] integerValue];
    createdAtDate.minute = [createdAt substringWithRange:minRange].integerValue;
    createdAtDate.hour = [createdAt substringWithRange:hourRange].integerValue;
    createdAtDate.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:createdAtDate];
    dateFormatter.dateFormat = @"dd MMM YYYY HH:mm";
    self.textLabel.text = [dateFormatter stringFromDate:date];
    NSString *appURLString, *appNameString;
    NSScanner *scanner = [[NSScanner alloc] initWithString:self.tweetDictionary[@"source"]];
    [scanner scanUpToString:@"<a href=\"" intoString:nil];
    [scanner scanString:@"<a href=\"" intoString:nil];
    [scanner scanUpToString:@"\"" intoString:&appURLString];
    [scanner scanUpToString:@">" intoString:nil];
    [scanner scanString:@">" intoString:nil];
    [scanner scanUpToString:@"</a>" intoString:&appNameString];
    self.appURL = [NSURL URLWithString:appURLString];
    self.detailTextLabel.text = appNameString;
    self.textLabel.font = [UIFont systemFontOfSize:14.0f];
    self.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
    //Add Tap Textlabel
    self.textLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTimeLabelPressed:)];
    tapGesture1.numberOfTapsRequired = 1;
    tapGesture1.delegate = self;
    [self.textLabel addGestureRecognizer:tapGesture1];
    //Add Tap DetailTextLabel
    self.detailTextLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didViaLabelPressed:)];
    tapGesture2.numberOfTapsRequired = 1;
    tapGesture2.delegate = self;
    [self.detailTextLabel addGestureRecognizer:tapGesture2];
}

@end
