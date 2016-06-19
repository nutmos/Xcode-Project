//
//  UserDetailViewController.h
//  Twt
//
//  Created by Nattapong Mos on 22/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(NSInteger, DetailShowingType) {
    DetailShowingTypeTweets=1,
    DetailShowingTypeFollowers,
    DetailShowingTypeFollowing,
    DetailShowingTypeLists,
    DetailShowingTypeFavourites,
    DetailShowingTypeMutedUsers,
    DetailShowingTypeListFollowers,
    DetailShowingTypeListMembers,
    DetailShowingTypeRetweetedBy
};

#import <UIKit/UIKit.h>
#import "TweetViewController.h"
#import "AppDelegate.h"
#import "TweetCell.h"

@interface DetailViewController : UITableViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, UIToolbarDelegate, UISearchBarDelegate, UISearchDisplayDelegate, TweetViewControllerDelegate, TweetCellDelegate>

@property (nonatomic, strong) NSString *screenName;
@property (nonatomic) DetailShowingType options;
@property (nonatomic, strong) NSNumber *listID;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSDictionary *listDetail;
@property (strong, nonatomic) NSNumber *tweetID;
//@property (nonatomic) BOOL showSaveButton;
//@property (strong, nonatomic) NSDictionary *slug;
//@property (strong, nonatomic) NSString *lang;
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
