//
//  SearchViewController.h
//  Twt
//
//  Created by Nattapong Mos on 23/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RowSelected) {
    RowGoToUserSelected = 0,
    RowSearchTweetsSelected,
    RowSearchUsersSelected
};

typedef NS_ENUM(NSInteger, UseType) {
    UseSavedSearch,
    UseTypingText
};

@interface SearchViewController : UITableViewController <UISearchBarDelegate, UIScrollViewDelegate>

@end
