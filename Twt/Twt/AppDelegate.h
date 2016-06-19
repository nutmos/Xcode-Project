//
//  AppDelegate.h
//  Twt
//
//  Created by Nattapong Mos on 16/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

typedef NS_ENUM(NSInteger, RequestURL) {
    RequestGetHomeTimelineURL,
    RequestGetMentionsTimelineURL,
    RequestGetUserTimelineURL,
    RequestGetUserDataURL,
    RequestGetLookupUserURL,
    RequestGetBlocksListURL,
    RequestGetMutedUserListURL,
    RequestGetTweetInListURL,
    RequestGetUserSuggestionBySlugURL,
    RequestGetSearchUserURL,
    RequestGetSearchTweetURL,
    RequestGetListFollowersURL,
    RequestGetListMembersURL,
    RequestGetMemberOfListsURL,
    RequestGetSubscribedListURL,
    RequestGetFollowersListURL,
    RequestGetFriendsListURL,
    RequestGetFavouritesListURL,
    RequestGetSavedSearchListURL,
    RequestGetUserLanguageURL,
    RequestGetUserSuggestionURL,
    RequestGetTrendsAtPlaceURL,
    RequestGetWOEIDAtLocationURL,
    RequestGetStatusLookupURL,
    RequestGetRetweetedByURL,
    RequestGetFriendshipURL,
    RequestGetRetweetsOfMeURL,
    RequestGetShowListURL,
    RequestPostReportSpamURL,
    RequestPostFollowUserURL,
    RequestPostUnfollowUserURL,
    RequestPostUpdateFriendshipURL,
    RequestPostUnmuteUserURL,
    RequestPostMuteUserURL,
    RequestPostTweetURL,
    RequestPostTweetWithMediaURL,
    RequestPostDestroySavedSearchURL,
    RequestPostCreateFavouriteTweetURL,
    RequestPostDestroyFavouriteTweetURL,
    RequestPostCreateRetweetURL,
    RequestPostDestroyRetweetURL,
    RequestPostCreateBlockURL,
    RequestPostDestroyBlockURL,
    RequestPostUpdateProfileURL,
    RequestPostCreateListURL,
    RequestPostUpdateListURL,
    RequestPostDestroyListURL,
    RequestPostDestroySubscribeListURL,
    RequestPostSubscribeListURL,
    RequestPostAddListMemberURL,
    RequestPostDestroyListMemberURL,
    RequestPostCreateSaveSearchURL,
    RequestPostUpdateProfileImageURL,
};

typedef NS_ENUM(NSInteger, RequestGETOption) {
    RequestGETOptionGetAll,
    RequestGETOptionGetMoreThan,
};

typedef NS_ENUM(NSInteger, GetActionSheetOption) {
    GetActionSheetOptionLongPressNameOfUser,
    GetActionSheetOptionLongPressNameOfAuthenticatedUser,
};

typedef NS_ENUM(NSInteger, CallImageFileOption) {
    CallImageFileOptionAvatar,
    CallImageFileOptionProfileBanner,
};

#define GetActionSheetAttributeDelegate @"Delegate"
#define GetActionSheetAttributeUsername @"Username"
#define GetActionSheetAttributeViewController @"ViewController"
#define CallImageFileAttributeLink @"Link" // pass NSURL data for this attribute
#define CallImageFileAttributeUserID @"UserID" // pass NSNumber data for this attribute

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *account;
@property (strong, nonatomic) ACAccount *currentAccount;
@property NSInteger selectedTabBarItemIndex;
@property (readonly) NSDictionary *months;
- (UIAlertAction *)cancelAlertAction;
- (NSURL *)requestURLWithOption:(RequestURL)option stringParameter:(NSString *)parameter;
- (id)getActionSheetOption:(GetActionSheetOption)option attributes:(NSDictionary *)attributes;
- (UIImage *)callImageFileOption:(CallImageFileOption)option attributes:(NSDictionary *)attributes;
- (void)postFollowUser:(NSString *)screenName;
- (void)postUnfollowUser:(NSString *)screenName;
- (UIView *)clearTableFooterView;
- (NSString *)majorSystemVersion;

@end
