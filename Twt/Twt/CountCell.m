//
//  CountCell.m
//  Twt
//
//  Created by Nattapong Mos on 27/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "CountCell.h"
#import "TweetCell.h"
#import "AppDelegate.h"

@interface CountCell ()

@property UITableViewController *vc;
@property AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *retweetsCount;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *favesCount;

@end

@implementation CountCell

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

- (UIBarButtonItem *)flexibleSpace {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
}

- (void)setCountCellWithTweetDictionary:(NSDictionary *)tweet inViewController:(UITableViewController *)vc {
    self.vc = vc;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterNoStyle;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.usesGroupingSeparator = YES;
    NSArray *array = @[self.flexibleSpace];
    NSInteger retweetedCount = [tweet[@"retweet_count"] integerValue];
    if (retweetedCount > 0) {
        self.retweetsCount.title = (retweetedCount == 1)?@"1 Retweet":[NSString stringWithFormat:@"%@ Retweets", [numberFormatter stringFromNumber:@(retweetedCount)]];
        array = [array arrayByAddingObjectsFromArray:@[self.retweetsCount, self.flexibleSpace]];
    }
    NSInteger favesCount = [tweet[@"favorite_count"] integerValue];
    if (favesCount > 0) {
        self.favesCount.title = (favesCount == 1)?@"1 Fave":[NSString stringWithFormat:@"%@ Faves", [numberFormatter stringFromNumber:@(favesCount)]];
        array = [array arrayByAddingObjectsFromArray:@[self.favesCount, self.flexibleSpace]];
    }
    self.toolBar.items = array;
}

@end
