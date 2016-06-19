//
//  UITableViewController+RequiredTweetCellObject.m
//  Twt
//
//  Created by Nattapong Mos on 21/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "UIViewController+RequiredObject.h"

@implementation UIViewController (RequiredObject)

@dynamic woeidSentToNextVC;

- (void)setWoeidSentToNextVC:(NSNumber *)woeidSentToNextVC {
    objc_setAssociatedObject(self, @selector(woeidSentToNextVC), woeidSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)woeidSentToNextVC {
    return objc_getAssociatedObject(self, @selector(woeidSentToNextVC));
}

@dynamic locationNameSentToNextVC;

- (void)setLocationNameSentToNextVC:(NSString *)locationNameSentToNextVC {
    objc_setAssociatedObject(self, @selector(locationNameSentToNextVC), locationNameSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)locationNameSentToNextVC {
    return objc_getAssociatedObject(self, @selector(locationNameSentToNextVC));
}

@dynamic searchStringSentToNextVC;

- (void)setSearchStringSentToNextVC:(NSString *)searchStringSentToNextVC {
    objc_setAssociatedObject(self, @selector(searchStringSentToNextVC), searchStringSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)searchStringSentToNextVC {
    return objc_getAssociatedObject(self, @selector(searchStringSentToNextVC));
}

@dynamic avatarSentToNextVC;

- (void)setAvatarSentToNextVC:(UIImage *)avatarSentToNextVC {
    objc_setAssociatedObject(self, @selector(avatarSentToNextVC), avatarSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)avatarSentToNextVC {
    return objc_getAssociatedObject(self, @selector(avatarSentToNextVC));
}

@dynamic imageSentToNextVC;

- (void)setImageSentToNextVC:(UIImage *)imageSentToNextVC {
    objc_setAssociatedObject(self, @selector(imageSentToNextVC), imageSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)imageSentToNextVC {
    return objc_getAssociatedObject(self, @selector(imageSentToNextVC));
}

@dynamic userSentToNextVC;

- (void)setUserSentToNextVC:(NSDictionary *)userSentToNextVC {
    objc_setAssociatedObject(self, @selector(userSentToNextVC), userSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)userSentToNextVC {
    return objc_getAssociatedObject(self, @selector(userSentToNextVC));
}

@dynamic screenNameSentToNextVC;

- (void)setScreenNameSentToNextVC:(NSString *)screenNameSentToNextVC {
    objc_setAssociatedObject(self, @selector(screenNameSentToNextVC), screenNameSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)screenNameSentToNextVC {
    return objc_getAssociatedObject(self, @selector(screenNameSentToNextVC));
}

@dynamic tweetSentToNextVC;

- (void)setTweetSentToNextVC:(NSDictionary *)tweetSentToNextVC {
    objc_setAssociatedObject(self, @selector(tweetSentToNextVC), tweetSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)tweetSentToNextVC {
    return objc_getAssociatedObject(self, @selector(tweetSentToNextVC));
}

@dynamic listDetailSentToNextVC;

- (void)setListDetailSentToNextVC:(NSDictionary *)listDetailSentToNextVC {
    objc_setAssociatedObject(self, @selector(listDetailSentToNextVC), listDetailSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)listDetailSentToNextVC {
    return objc_getAssociatedObject(self, @selector(listDetailSentToNextVC));
}

@dynamic selectedIndexPath;

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    objc_setAssociatedObject(self, @selector(selectedIndexPath), selectedIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSIndexPath *)selectedIndexPath {
    return objc_getAssociatedObject(self, @selector(selectedIndexPath));
}

@dynamic selectedRowNumber;

- (void)setSelectedRowNumber:(NSNumber *)selectedRowNumber {
    objc_setAssociatedObject(self, @selector(selectedRowNumber), selectedRowNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)selectedRowNumber {
    return objc_getAssociatedObject(self, @selector(selectedRowNumber));
}

@dynamic backBarButtonItemTitle;

- (void)setBackBarButtonItemTitle:(NSString *)backBarButtonItemTitle {
    objc_setAssociatedObject(self, @selector(backBarButtonItemTitle), backBarButtonItemTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)backBarButtonItemTitle {
    return objc_getAssociatedObject(self, @selector(backBarButtonItemTitle));
}

@dynamic urlSentToNextVC;

- (void)setUrlSentToNextVC:(NSURL *)urlSentToNextVC {
    objc_setAssociatedObject(self, @selector(urlSentToNextVC), urlSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)urlSentToNextVC {
    return objc_getAssociatedObject(self, @selector(urlSentToNextVC));
}

@dynamic shareUrlSentToNextVC;

- (void)setShareUrlSentToNextVC:(NSURL *)shareUrlSentToNextVC {
    objc_setAssociatedObject(self, @selector(shareUrlSentToNextVC), shareUrlSentToNextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)shareUrlSentToNextVC {
    return objc_getAssociatedObject(self, @selector(shareUrlSentToNextVC));
}

@end
