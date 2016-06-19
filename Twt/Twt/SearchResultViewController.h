//
//  SearchResultViewController.h
//  Twt
//
//  Created by Nattapong Mos on 1/7/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(NSInteger, SearchResultShowingType) {
    SearchResultShowingTypeTweets,
    SearchResultShowingTypeUsers,
    SearchResultShowingTypeUserSuggestions,
};

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TweetCell.h"

@interface SearchResultViewController : UITableViewController <TweetCellDelegate>

@property (nonatomic) SearchResultShowingType showingType;
@property (nonatomic) BOOL isSaved;
@property (strong, nonatomic) NSDictionary *slug;
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) NSString *searchText;

@end
