//
//  EditProfileTableViewController.h
//  Twt
//
//  Created by Nattapong Mos on 22/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UITableViewController <UIActionSheetDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property NSDictionary *userData;

@end
