//
//  ListCell.h
//  Twt
//
//  Created by Nattapong Mos on 18/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCell : UITableViewCell <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *listName;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *members;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *creater;
@property (strong, nonatomic) NSDictionary *userCreaterDetail;
@property (strong, nonatomic) NSDictionary *listDetail;

+ (CGFloat)descriptionWidth;
- (void)setListDataDictionary:(NSDictionary *)listData inViewController:(UITableViewController *)vc;
+ (CGFloat)calculateListCellHeightWithListDictionary:(NSDictionary *)list;

@end
