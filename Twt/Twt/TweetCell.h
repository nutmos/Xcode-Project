//
//  TweetCell.h
//  Twt
//
//  Created by Nattapong Mos on 16/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(NSInteger, TweetCellShowOption) {
    TweetCellShowTweet,
    TweetCellShowRetweetOfMe,
    TweetCellShowTweetAndMap,
};

#import <UIKit/UIKit.h>
#import "UIViewController+RequiredObject.h"
#import "TTTAttributedLabel.h"
@class TweetCell;

@protocol TweetCellDelegate <NSObject>

@optional
- (void)tweetCell:(TweetCell *)cell didTapLinkWithMediaEntities:(NSDictionary *)media;
- (void)tweetCell:(TweetCell *)cell didTapLinkWithURLEntities:(NSDictionary *)urlEntities;
- (void)tweetCell:(TweetCell *)cell didTapLinkWithSymbolEntities:(NSDictionary *)symbol;
- (void)tweetCell:(TweetCell *)cell didTapLinkWithHashtagEntities:(NSDictionary *)hashtag;
- (void)tweetCell:(TweetCell *)cell didTapLinkWithUserEntities:(NSDictionary *)user;
- (void)tweetCell:(TweetCell *)cell didTapAvatarImage:(UIImage *)image userEntities:(NSDictionary *)user;
// didTapAvatarImage use both tap avatar and press view profile button
- (void)tweetCell:(TweetCell *)cell didTapRetweetedByUserEntities:(NSDictionary *)user;

@end

@interface TweetCell : UITableViewCell <UITextViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *retweetedByLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *tweetLabel;
@property (strong, nonatomic) IBOutlet UILabel *countRetweetLabel;
@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) NSDictionary *retweetedByUser;
@property (strong, nonatomic) NSDictionary *tweetDict;
@property (strong, nonatomic) NSNumber *tweetID;
@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) id<TweetCellDelegate> delegate;
+ (CGFloat)tweetViewWidth;
//- (void)setAvatarImage:(UIImage *)image;
- (void)setTweetCellWithTweetDictionary:(NSDictionary *)tweet inViewController:(UIViewController *)vc delegate:(id<TweetCellDelegate>)delegate;
+ (CGFloat)calculateTweetCellHeightWithTweetDictionary:(NSDictionary *)tweet option:(TweetCellShowOption)option;

@end
