//
//  CountCell.h
//  Twt
//
//  Created by Nattapong Mos on 23/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetDetailCell : UITableViewCell <UIGestureRecognizerDelegate>

- (void)setTweetDictionary:(NSDictionary *)tweetDictionary inTableViewController:(UITableViewController *)vc;

@end
