//
//  ArticleCell.h
//  MacThai
//
//  Created by Nattapong Mos on 26/8/57.
//  Copyright (c) พ.ศ. 2557 Nutmos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleCell : UITableViewCell

- (void)setArticleWithDictionary:(NSDictionary *)data;
+ (CGFloat)calculateCellHeightWithArticleDictionary:(NSDictionary *)data;

@end
