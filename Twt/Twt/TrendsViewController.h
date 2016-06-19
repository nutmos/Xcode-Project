//
//  TrendsViewController.h
//  Twt
//
//  Created by Nattapong Mos on 14/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(NSInteger, TrendsShowingType) {
    TrendsShowingTypeUserSuggestions,
    TrendsShowingTypeTrends
};

#import <UIKit/UIKit.h>
#import "UIViewController+RequiredObject.h"
#import "AppDelegate.h"

@interface TrendsViewController : UITableViewController

@property (strong, nonatomic) NSString *trendsLocation;
@property (nonatomic) NSInteger trendsWOEID;
@property (strong, nonatomic) NSArray *savedSearchArray;
@property (nonatomic) TrendsShowingType option;
- (IBAction)unwindToTrends:(UIStoryboardSegue *)segue;

@end
