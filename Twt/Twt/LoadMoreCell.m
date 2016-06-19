//
//  LoadMoreCell.m
//  Twt
//
//  Created by Nattapong Mos on 14/7/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "LoadMoreCell.h"

@interface LoadMoreCell ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoadMoreCell

- (void)startActivity {
    [self.activityIndicator startAnimating];
}

- (void)stopActivity {
    [self.activityIndicator stopAnimating];
}

@end
