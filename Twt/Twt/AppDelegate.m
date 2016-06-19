//
//  AppDelegate.m
//  Twt
//
//  Created by Nattapong Mos on 16/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSCache *cache;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _months = @{@"Jan": @"1", @"Feb": @"2", @"Mar": @"3", @"Apr": @"4",
                @"May": @"5", @"Jun": @"6", @"Jul": @"7", @"Aug": @"8",
                @"Sep": @"9", @"Oct": @"10",@"Nov": @"11",@"Dec": @"12"};
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            self.account = [accountStore accountsWithAccountType:twitterType];
            if (self.account.count) {
                //[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TwitterAccountAcquiredNotification" object:nil]];
                NSString *currentPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lastUsedUsername.txt"];
                //NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:currentPath];
                NSString *fileSaved = [NSString stringWithContentsOfFile:currentPath encoding:NSUTF8StringEncoding error:nil];
                self.currentAccount = self.account[0];
                for (ACAccount *account in self.account) {
                    if ([account.username isEqualToString:fileSaved]) {
                        self.currentAccount = account;
                    }
                }
            }
            else {
                NSLog(@"No Twitter Account");
                [[[UIAlertView alloc] initWithTitle:@"No Twitter Account" message:@"You can add Twitter account in device settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
    self.cache = [[NSCache alloc] init];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //NSString *currentPath = [[NSBundle mainBundle] resourcePath];
    //[currentPath stringByAppendingPathComponent:@"Save Data.txt"];
    //NSDictionary *saveData = @{@"Username": self.currentAccount.userFullName};
    //[saveData writeToFile:currentPath atomically:NO];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString *)majorSystemVersion {
    return [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0];
}

- (UIAlertAction *)cancelAlertAction {
    return [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
}

- (id)getActionSheetOption:(GetActionSheetOption)option attributes:(NSDictionary *)attributes {
    if ([self.majorSystemVersion isEqualToString:@"8"]) {
        //NSLog(@"iOS 8");
        if (option == GetActionSheetOptionLongPressNameOfAuthenticatedUser) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"View Profile" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                id v = attributes[GetActionSheetAttributeViewController];
                if ([v isKindOfClass:[UIViewController class]]) {
                    UIViewController *vc = v;
                    [vc performSegueWithIdentifier:@"ToUser" sender:vc];
                }
            }]];
            return actionSheet;
        }
        else if (option == GetActionSheetOptionLongPressNameOfUser) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Getting follow status..." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Follow" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *user = attributes[GetActionSheetAttributeUsername];
                if ([user isKindOfClass:[NSString class]]) {
                    [self postFollowUser:user];
                }
            }]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Direct Message" style:UIAlertActionStyleDefault handler:nil]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"View Profile" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                id object = attributes[GetActionSheetAttributeViewController];
                if ([object isKindOfClass:[UIViewController class]]) {
                    UIViewController *vc = object;
                    [vc performSegueWithIdentifier:@"ToUser" sender:vc];
                }
            }]];
            return actionSheet;
        }
        else return nil;
    }
    else {
        if (option == GetActionSheetOptionLongPressNameOfAuthenticatedUser) {
            return [[UIActionSheet alloc] initWithTitle:nil delegate:attributes[GetActionSheetAttributeDelegate] cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Profile", nil];
        }
        else if (option == GetActionSheetOptionLongPressNameOfUser) {
            return [[UIActionSheet alloc] initWithTitle:@"Getting follow status..." delegate:attributes[GetActionSheetAttributeDelegate] cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Follow", @"Direct Message", @"View Profile", nil];
        }
        else return nil;
    }
}

- (NSURL *)requestURLWithOption:(RequestURL)option stringParameter:(NSString *)parameter {
    if (option == RequestGetHomeTimelineURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    }
    else if (option == RequestGetMentionsTimelineURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/mentions_timeline.json"];
    }
    else if (option == RequestGetUserTimelineURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
    }
    else if (option == RequestPostFollowUserURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"];
    }
    else if (option == RequestPostUnfollowUserURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/destroy.json"];
    }
    else if (option == RequestGetFriendshipURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/show.json"];
    }
    else if (option == RequestPostUpdateFriendshipURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/update.json"];
    }
    else if (option == RequestPostMuteUserURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/mutes/users/create.json"];
    }
    else if (option == RequestPostUnmuteUserURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/mutes/users/destroy.json"];
    }
    else if (option == RequestGetUserDataURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    }
    else if (option == RequestGetBlocksListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/blocks/list.json"];
    }
    else if (option == RequestGetMutedUserListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/mutes/users/list.json"];
    }
    else if (option == RequestGetTweetInListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/statuses.json"];
    }
    else if (option == RequestGetUserSuggestionBySlugURL) {
        return [NSURL URLWithString:[[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/suggestions/%@.json", parameter] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else if (option == RequestGetSearchUserURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/users/search.json"];
    }
    else if (option == RequestGetSearchTweetURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    }
    else if (option == RequestGetListFollowersURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/subscribers.json"];
    }
    else if (option == RequestGetListMembersURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/members.json"];
    }
    else if (option == RequestGetFollowersListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
    }
    else if (option == RequestGetFriendsListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
    }
    else if (option == RequestGetFavouritesListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/favorites/list.json"];
    }
    else if (option == RequestGetMemberOfListsURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/memberships.json"];
    }
    else if (option == RequestGetSubscribedListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/list.json"];
    }
    else if (option == RequestPostTweetURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    }
    else if (option == RequestPostTweetWithMediaURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
    }
    else if (option == RequestPostDestroySavedSearchURL) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/saved_searches/destroy/%@.json", parameter]];
    }
    else if (option == RequestPostCreateSaveSearchURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/saved_searches/create.json"];
    }
    else if (option == RequestGetSavedSearchListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/saved_searches/list.json"];
    }
    else if (option == RequestPostCreateFavouriteTweetURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/favorites/create.json"];
    }
    else if (option == RequestPostDestroyFavouriteTweetURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/favorites/destroy.json"];
    }
    else if (option == RequestPostCreateRetweetURL) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", parameter]];;
    }
    else if (option == RequestPostDestroyRetweetURL) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/destroy/%@.json", parameter]];
    }
    else if (option == RequestGetUserLanguageURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    }
    else if (option == RequestGetUserSuggestionURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/users/suggestions.json"];
    }
    else if (option == RequestGetTrendsAtPlaceURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json"];
    }
    else if (option == RequestGetWOEIDAtLocationURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/closest.json"];
    }
    else if (option == RequestPostCreateBlockURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/blocks/create.json"];
    }
    else if (option == RequestPostDestroyBlockURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/blocks/destroy.json"];
    }
    else if (option == RequestPostUpdateProfileURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/account/update_profile.json"];
    }
    else if (option == RequestGetStatusLookupURL) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/show/%@.json", parameter]];
    }
    else if (option == RequestGetRetweetedByURL) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweets/%@.json",parameter]];
    }
    else if (option == RequestGetRetweetsOfMeURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/retweets_of_me.json"];
    }
    else if (option == RequestPostReportSpamURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/users/report_spam.json"];
    }
    else if (option == RequestGetLookupUserURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/users/lookup.json"];
    }
    else if (option == RequestPostCreateListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/create.json"];
    }
    else if (option == RequestPostUpdateListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/update.json"];
    }
    else if (option == RequestGetShowListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/show.json"];
    }
    else if (option == RequestPostDestroyListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/destroy.json"];
    }
    else if (option == RequestPostDestroySubscribeListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/subscribers/destroy.json"];
    }
    else if (option == RequestPostSubscribeListURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/subscribers/create.json"];
    }
    else if (option == RequestPostAddListMemberURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/members/create.json"];
    }
    else if (option == RequestPostDestroyListMemberURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/members/destroy.json"];
    }
    else if (option == RequestPostUpdateProfileImageURL) {
        return [NSURL URLWithString:@"https://api.twitter.com/1.1/account/update_profile_image.json"];
    }
    else {
        NSLog(@"call fail");
        return nil;
    }
}

- (UIImage *)callImageFileOption:(CallImageFileOption)option attributes:(NSDictionary *)attributes {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *currentPath = [NSBundle mainBundle].resourcePath;
    NSString *avatarPath;
    UIImage *imageCache;
    if (option == CallImageFileOptionAvatar) {
        imageCache = [self.cache objectForKey:[NSString stringWithFormat:@"avatar_%@",[attributes[CallImageFileAttributeUserID] stringValue]]];
    }
    else if (option == CallImageFileOptionProfileBanner) {
        imageCache = [self.cache objectForKey:[NSString stringWithFormat:@"cover_%@",[attributes[CallImageFileAttributeUserID] stringValue]]];
    }
    if (imageCache) {
        return imageCache;
    }
    else {
        if (option == CallImageFileOptionAvatar) {
            avatarPath = [currentPath stringByAppendingPathComponent:@"Avatar"];
        }
        else if (option == CallImageFileOptionProfileBanner) {
            avatarPath = [currentPath stringByAppendingPathComponent:@"Cover"];
        }
        BOOL isDirectory = NO;
        if (!([fileMgr fileExistsAtPath:avatarPath isDirectory:&isDirectory] && isDirectory)) {
            [fileMgr createDirectoryAtPath:avatarPath withIntermediateDirectories:YES attributes:@{NSFileType: NSFileTypeDirectory} error:nil];
        }
        NSData *imageData;
        BOOL isDirectory2 = YES;
        NSString *avatarImageFile = [avatarPath stringByAppendingPathComponent:[NSString stringWithFormat:@"user_%@", [attributes[CallImageFileAttributeUserID] stringValue]]];
        if ([fileMgr fileExistsAtPath:avatarImageFile isDirectory:&isDirectory2] && !isDirectory2) {
            if ([fileMgr attributesOfItemAtPath:avatarImageFile error:nil].fileModificationDate.timeIntervalSinceNow <= -100.0f) {
                imageData = [NSData dataWithContentsOfURL:attributes[CallImageFileAttributeLink]];
                [fileMgr createFileAtPath:avatarImageFile contents:imageData attributes:@{NSFileType: NSFileTypeRegular}];
            }
            else {
                imageData = [NSData dataWithContentsOfFile:avatarImageFile];
            }
        }
        else {
            imageData = [NSData dataWithContentsOfURL:attributes[CallImageFileAttributeLink]];
            [fileMgr createFileAtPath:avatarImageFile contents:imageData attributes:@{NSFileType: NSFileTypeRegular}];
        }
        UIImage *image = [UIImage imageWithData:imageData];
        if (option == CallImageFileOptionAvatar) {
            [self.cache setObject:image forKey:[NSString stringWithFormat:@"avatar_%@", [attributes[CallImageFileAttributeUserID] stringValue]]];
        }
        else if (option == CallImageFileOptionProfileBanner) {
            [self.cache setObject:image forKey:[NSString stringWithFormat:@"cover_%@", [attributes[CallImageFileAttributeUserID] stringValue]]];
        }
        return image;
    }
}

- (void)postFollowUser:(NSString *)screenName {
    if (self.account.count) {
        NSURL *feed = [self requestURLWithOption:RequestPostFollowUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": screenName, @"follow": @"true"};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            //NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        }];
    }
}

- (void)postUnfollowUser:(NSString *)screenName {
    if (self.account.count) {
        NSURL *feed = [self requestURLWithOption:RequestPostUnfollowUserURL stringParameter:nil];
        NSDictionary *parameters = @{@"screen_name": screenName};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            //NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        }];
    }
}

- (UIView *)clearTableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return view;
}

@end
