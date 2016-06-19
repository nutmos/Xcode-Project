//
//  NewTweetViewController.h
//  Twt
//
//  Created by Nattapong Mos on 26/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(NSInteger, NewTweetType) {
    NewTweetTypeNewTweet,
    NewTweetTypeReply,
    NewTweetTypeQuoteTweet,
    NewTweetTypeNewTweetWithText,
};

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface NewTweetViewController : UIViewController <UIActionSheetDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIToolbarDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) NSDictionary *inReplyToStatus;
@property (nonatomic) NewTweetType option;
@property (nonatomic, strong) NSArray *inReplyToUserScreenName;
@property (strong, nonatomic) NSString *tweetString;

@end
