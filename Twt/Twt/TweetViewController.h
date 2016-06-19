//
//  TweetViewController.h
//  Twt
//
//  Created by Nattapong Mos on 30/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetCell.h"
@class TweetViewController;

@protocol TweetViewControllerDelegate <NSObject>

@optional
- (void)tweetViewController:(TweetViewController *)vc tweetData:(NSDictionary *)tweet;
- (void)tweetViewController:(TweetViewController *)vc removeTweetData:(NSDictionary *)tweet;

@end

@interface TweetViewController : UITableViewController <UIActionSheetDelegate, UIGestureRecognizerDelegate, TweetCellDelegate, TweetViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *tweetDictionary;
@property (assign, nonatomic) id<TweetViewControllerDelegate> delegate;

@end
