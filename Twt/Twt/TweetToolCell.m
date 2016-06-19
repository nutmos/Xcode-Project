//
//  TweetToolCell.m
//  Twt
//
//  Created by Nattapong Mos on 10/6/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "TweetToolCell.h"
#import "AppDelegate.h"

@interface TweetToolCell ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *replyButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *faveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *retweetButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *tweet;

@end

@implementation TweetToolCell

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

- (void)setTweetToolWithTweetDictionary:(NSDictionary *)tweet {
    self.tweet = tweet;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([tweet[@"favorited"] boolValue]) {
        self.faveButton.image = [UIImage imageNamed:@"favourite_pressed"];
        self.faveButton.tag = 1;
        self.faveButton.tintColor = [UIColor yellowColor];
    }
    if ([tweet[@"retweeted"] boolValue]) {
        self.retweetButton.image = [UIImage imageNamed:@"retweet_pressed"];
        self.retweetButton.tag = 1;
        self.retweetButton.tintColor = [UIColor greenColor];
    }
    NSArray *toolItemsArray = @[self.flexibleSpace, self.replyButton, self.flexibleSpace, self.faveButton, self.flexibleSpace, self.retweetButton, self.flexibleSpace, self.actionButton, self.flexibleSpace];
    if ([tweet[@"user"][@"screen_name"] isEqualToString:self.appDelegate.currentAccount.username] && tweet[@"retweeted_status"] == nil) {
        toolItemsArray = [toolItemsArray arrayByAddingObjectsFromArray:@[self.trashButton, self.flexibleSpace]];
    }
    self.toolbar.items = toolItemsArray;
}

@end
