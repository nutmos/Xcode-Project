//
//  AppDelegate.h
//  TRTw2
//
//  Created by Nattapong Mos on 9/2/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ACAccount *userAccount;
@property (strong, nonatomic) ACAccountStore *accountStore;

@end
