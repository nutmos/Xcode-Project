//
//  UITableViewController+RequiredTweetCellObject.h
//  Twt
//
//  Created by Nattapong Mos on 21/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AppDelegate.h"

@interface UIViewController (RequiredObject)

@property (strong, nonatomic) NSString *locationNameSentToNextVC;
@property (strong, nonatomic) NSNumber *woeidSentToNextVC;
@property (strong, nonatomic) NSString *searchStringSentToNextVC;
@property (strong, nonatomic) NSDictionary *userSentToNextVC;
@property (strong, nonatomic) UIImage *avatarSentToNextVC;
@property (strong, nonatomic) NSString * screenNameSentToNextVC;
@property (strong, nonatomic) NSDictionary *tweetSentToNextVC;
@property (nonatomic, strong) NSDictionary *listDetailSentToNextVC;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSNumber *selectedRowNumber;
@property (strong, nonatomic) NSString *backBarButtonItemTitle;
@property (strong, nonatomic) NSURL *urlSentToNextVC;
@property (strong, nonatomic) NSURL *shareUrlSentToNextVC;
@property (strong, nonatomic) UIImage *imageSentToNextVC;

@end
