//
//  DMOverallCell.h
//  Twt
//
//  Created by Nattapong Mos on 12/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMOverallCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong ,nonatomic) IBOutlet UILabel *DMWithUser;
@property (strong, nonatomic) IBOutlet UILabel *lastestText;

@end
