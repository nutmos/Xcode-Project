//
//  TweetCell.m
//  Twt
//
//  Created by Nattapong Mos on 16/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "TweetCell.h"

@interface TweetCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name = %@, tweet = %@", self.name.text, self.tweetView.text];
}

@end
