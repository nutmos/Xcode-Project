//
//  UIImageView+Extension.m
//  Twt
//
//  Created by Nattapong Mos on 12/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "UIImageView+Extension.h"

@implementation UIImageView (Extension)

- (void)maskToCircleWithAvatarSide:(NSInteger)avatarSide {
    self.layer.cornerRadius = avatarSide/2.0;
    self.layer.borderWidth = 0.0f;
    self.layer.masksToBounds = NO;
    self.clipsToBounds = YES;
}

@end
