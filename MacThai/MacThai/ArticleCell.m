//
//  ArticleCell.m
//  MacThai
//
//  Created by Nattapong Mos on 26/8/57.
//  Copyright (c) พ.ศ. 2557 Nutmos. All rights reserved.
//

#import "ArticleCell.h"

@interface ArticleCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *articleImage;
@property (strong, nonatomic) NSURL *articleLink;
@property (strong, nonatomic) NSDictionary *article;

@end

@implementation ArticleCell

+ (CGFloat)calculateCellHeightWithArticleDictionary:(NSDictionary *)data {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 210, 0)];
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    //CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    titleLabel.text = [data objectForKey:@"title"];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 0;
    [titleLabel sizeToFit];
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 210, 0)];
    descriptionLabel.font = [UIFont systemFontOfSize:14.0f];
    descriptionLabel.text = [data objectForKey:@"description"];
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    //NSLog(@"title = %.2f, description = %.2f", titleLabel.frame.size.height, descriptionLabel.frame.size.height);
    if (descriptionLabel.frame.size.height <= 49) {
        //NSLog(@"100");
        return 100;
    }
    else {
        //NSLog(@"%.3f", 51+descriptionLabel.frame.size.height);
        return 28 + titleLabel.frame.size.height + descriptionLabel.frame.size.height;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setArticleWithDictionary:(NSDictionary *)data {
    self.article = [data copy];
    self.titleLabel.text = [data objectForKey:@"title"];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.titleLabel sizeToFit];
    self.descriptionLabel.text = [data objectForKey:@"description"];
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.descriptionLabel sizeToFit];
    self.articleLink = [NSURL URLWithString:[data objectForKey:@"link"]];
}

@end
