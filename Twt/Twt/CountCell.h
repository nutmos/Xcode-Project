//
//  CountCell.h
//  Twt
//
//  Created by Nattapong Mos on 27/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
- (void)setCountCellWithTweetDictionary:(NSDictionary *)tweet inViewController:(UITableViewController *)vc;

@end
