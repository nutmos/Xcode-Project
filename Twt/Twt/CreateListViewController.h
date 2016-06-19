//
//  CreateListViewController.h
//  Twt
//
//  Created by Nattapong Mos on 30/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

typedef NS_ENUM(NSInteger, CreateListType) {
    CreateListTypeCreate,
    CreateListTypeEdit,
};

#import <UIKit/UIKit.h>

@interface CreateListViewController : UITableViewController <UITextViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSDictionary *listData;
@property CreateListType option;

@end
