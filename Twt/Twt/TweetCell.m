//
//  TweetCell.m
//  Twt
//
//  Created by Nattapong Mos on 16/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "TweetCell.h"
#import <QuartzCore/QuartzCore.h>
#define TWEET_VIEW_WIDTH 212.0f
#define AVATAR_SIDE 60.0f
#import "UIImageView+Extension.h"
#import "AppDelegate.h"
#import "UIERealTimeBlurView.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TweetCell ()

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UIViewController *vc;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property id actionSheet;
@property (strong, nonatomic) NSDictionary *selectedUser;
@property (strong, nonatomic) NSMutableArray *entitiesInArray;

@end

@implementation TweetCell

+ (CGFloat)calculateTweetCellHeightWithTweetDictionary:(NSDictionary *)tweet option:(TweetCellShowOption)option {
    UILabel *retweetedByLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280.0f, 17.0f)];
    if (option == TweetCellShowTweet) {
        if (tweet[@"retweeted_status"]) {
            tweet = tweet[@"retweeted_status"];
            retweetedByLabel.text = @"Retweeted By";
        }
        else if ([tweet[@"retweeted"] boolValue]) {
            retweetedByLabel.text = @"Retweeted By";
        }
        else {
            retweetedByLabel.text = @"";
        }
    }
    else if (option == TweetCellShowRetweetOfMe) {
        retweetedByLabel.text = @"Retweeted By";
    }
    else {
        retweetedByLabel.text = @"";
    }
    __block NSString *tweetString = tweet[@"text"];
    NSArray *urls = tweet[@"entities"][@"urls"];
    NSArray *media = tweet[@"entities"][@"media"];
    NSDictionary *place = tweet[@"place"];
    dispatch_queue_t q1 = dispatch_queue_create("q1", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t g1 = dispatch_group_create();
    dispatch_group_async(g1, q1, ^{
        for (NSDictionary *url in urls) {
            tweetString = [tweetString stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
        }
        for (NSDictionary *medium in media) {
            tweetString = [tweetString stringByReplacingOccurrencesOfString:medium[@"url"] withString:medium[@"display_url"]];
        }
        if (place != nil && ![place isEqual:[NSNull null]]) {
            tweetString = [tweetString stringByAppendingString:[NSString stringWithFormat:@"\n%@", place[@"full_name"]]];
        }
    });
    dispatch_group_wait(g1, DISPATCH_TIME_FOREVER);
    CGRect rect = retweetedByLabel.frame;
    if ([retweetedByLabel.text isEqualToString:@""]) {
        rect.size = CGSizeMake(280.0f, 0.0f);
    } else {
        rect.size = [retweetedByLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}];
    }
    retweetedByLabel.frame = rect;
    UILabel *tweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 212.0f, 31.0f)];
    tweetLabel.text = tweetString;
    tweetLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tweetLabel.adjustsFontSizeToFitWidth = NO;
    tweetLabel.numberOfLines = 0;
    tweetLabel.font = [UIFont systemFontOfSize:14.0f];
    [tweetLabel sizeToFit];
    if (tweetLabel.frame.size.height <= 39.0f) {
        return retweetedByLabel.frame.size.height + 85.0f;
    }
    else {
        return 56.0f + tweetLabel.frame.size.height + retweetedByLabel.frame.size.height;
    }
}

+ (CGFloat)tweetViewWidth {
    return TWEET_VIEW_WIDTH;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

#pragma mark - Action Sheet Delegate

- (void)updateActionSheetAfterGetRelationship:(NSNotification *)notification {
    NSDictionary *relationship = notification.userInfo[@"relationship"];
    if ([self.actionSheet isKindOfClass:[UIActionSheet class]]) {
        for (id view in ((UIActionSheet *)self.actionSheet).subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                if ([relationship[@"source"][@"followed_by"] boolValue] == YES) {
                    label.text = [NSString stringWithFormat:@"@%@ is following you.", relationship[@"target"][@"screen_name"]];
                }
                else {
                    label.text = [NSString stringWithFormat:@"@%@ is not following you.", relationship[@"target"][@"screen_name"]];
                }
                [label setNeedsDisplay];
            }
            else if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if ([button.titleLabel.text isEqualToString:@"Follow"]) {
                    if ([relationship[@"source"][@"following"] boolValue] == YES) {
                        [button setTitle:@"Unfollow" forState:UIControlStateNormal];
                        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    }
                    button.enabled = YES;
                }
                else if ([button.titleLabel.text isEqualToString:@"Direct Message"]) {
                    if ([relationship[@"source"][@"can_dm"] boolValue]) {
                        button.enabled = YES;
                    }
                }
                [button setNeedsDisplay];
            }
        }
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (id view in actionSheet.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *buttonView = (UIButton *)view;
            if ([buttonView.titleLabel.text isEqualToString:@"Follow"] ||
                [buttonView.titleLabel.text isEqualToString:@"Direct Message"]) {
                buttonView.enabled = NO;
            }
            else if ([buttonView.titleLabel.text isEqualToString:@"Unfollow"]) {
                [buttonView setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"View Profile"]) {
        if ([self.delegate respondsToSelector:@selector(tweetCell:didTapAvatarImage:userEntities:)]) {
            [self.delegate tweetCell:self didTapAvatarImage:self.avatar userEntities:self.selectedUser];
        }
    }
    else if ([buttonTitle isEqualToString:@"Follow"]) {
        [self.appDelegate postFollowUser:self.selectedUser[@"screen_name"]];
    }
    else if ([buttonTitle isEqualToString:@"Unfollow"]) {
        [self.appDelegate postUnfollowUser:self.selectedUser[@"screen_name"]];
    }
}

#pragma mark - Get Data Method

- (void)getRelationShipBetweenSource:(NSString *)source andTarget:(NSString *)target {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetFriendshipURL stringParameter:nil];
        NSDictionary *parameters = @{@"source_screen_name": source, @"target_screen_name": target};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *relationDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([relationDict count] && relationDict[@"errors"] == nil) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Get Relationship In TweetCell Completed" object:nil userInfo:@{@"relationship": relationDict[@"relationship"]}];
                }
                else if (relationDict[@"errors"]) {
                    NSLog(@"error = %@", relationDict[@"errors"]);
                }
            }
            else {
                NSLog(@"%@",error.localizedDescription);
            }
        }];
    }
}

#pragma mark - User Interaction

- (void)tapAvatar:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(tweetCell:didTapAvatarImage:userEntities:)]) {
        [self.delegate tweetCell:self didTapAvatarImage:self.avatar userEntities:self.user];
    }
}

- (void)tapRetweetedByLabel:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(tweetCell:didTapRetweetedByUserEntities:)]) {
        [self.delegate tweetCell:self didTapRetweetedByUserEntities:self.retweetedByUser];
    }
}

- (void)longPressAvatar:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSString *user1 = self.appDelegate.currentAccount.username;
        NSString *user2 = self.user[@"screen_name"];
        if ([user1 isEqualToString:user2]) {
            self.selectedUser = self.user;
            NSDictionary *attributes = @{GetActionSheetAttributeDelegate: self, GetActionSheetAttributeViewController: self.vc};
            self.actionSheet = [self.appDelegate getActionSheetOption:GetActionSheetOptionLongPressNameOfAuthenticatedUser attributes:attributes];
            if ([self.appDelegate.majorSystemVersion isEqualToString:@"8"]) {
                [self.vc presentViewController:self.actionSheet animated:YES completion:nil];
            }
            else {
                [self.actionSheet showInView:self.vc.view];
            }
        }
        else {
            self.selectedUser = self.user;
            NSDictionary *attributes = @{GetActionSheetAttributeDelegate: self, GetActionSheetAttributeViewController: self.vc};
            self.actionSheet = [self.appDelegate getActionSheetOption:GetActionSheetOptionLongPressNameOfUser attributes:attributes];
            if ([self.appDelegate.majorSystemVersion isEqualToString:@"8"]) {
                [self.vc presentViewController:self.actionSheet animated:YES completion:nil];
            }
            else {
                [self.actionSheet showInView:self.vc.view];
            }
            [self getRelationShipBetweenSource:user1 andTarget:user2];
        }
    }
}

- (void)longPressRetweetedByLabel:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.vc.avatarSentToNextVC = nil;
        NSString *user1 = self.appDelegate.currentAccount.username;
        NSString *user2 = self.retweetedByUser[@"screen_name"];
        if ([user1 isEqualToString:user2]) {
            self.selectedUser = self.retweetedByUser;
            self.actionSheet = [self.appDelegate getActionSheetOption:GetActionSheetOptionLongPressNameOfAuthenticatedUser attributes:@{GetActionSheetAttributeDelegate: self, GetActionSheetAttributeViewController: self.vc}];
            if ([self.appDelegate.majorSystemVersion isEqualToString:@"8"]) {
                UIAlertController *actionSheet = self.actionSheet;
                [self.vc presentViewController:actionSheet animated:YES completion:nil];
            }
            else {
                UIActionSheet *actionSheet = self.actionSheet;
                [actionSheet showInView:self.vc.view];
            }
        }
        else {
            self.selectedUser = self.retweetedByUser;
            self.actionSheet = [self.appDelegate getActionSheetOption:GetActionSheetOptionLongPressNameOfUser attributes:@{GetActionSheetAttributeDelegate: self, GetActionSheetAttributeViewController: self.vc}];
            if ([self.appDelegate.majorSystemVersion isEqualToString:@"8"]) {
                [self.vc presentViewController:self.actionSheet animated:YES completion:nil];
            }
            else {
                [self.actionSheet showInView:self.vc.view];
            }
        }
    }
}

#pragma mark - Set Data

- (void)setTweetCellWithTweetDictionary:(NSDictionary *)tweet inViewController:(UIViewController *)vc delegate:(id<TweetCellDelegate>)delegate {
    self.vc = vc;
    self.delegate = delegate;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActionSheetAfterGetRelationship:) name:@"Get Relationship In TweetCell Completed" object:nil];
    self.tweetDict = tweet;
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Init data
    self.tweetID = tweet[@"id"];
    if (tweet[@"retweeted_status"]) {
        self.retweetedByUser = tweet[@"user"];
        tweet = tweet[@"retweeted_status"];
    }
    else {
        self.retweetedByUser = nil;
    }
    
    NSString *createdAt = tweet[@"created_at"];
    NSRange monthRange = {4,3}, dayRange = {8,2}, yearRange = {26, 4}, hourRange = {11,2}, minRange = {14,2};
    NSDateComponents *createdAtDate = [[NSDateComponents alloc] init];
    createdAtDate.year = [createdAt substringWithRange:yearRange].integerValue;
    createdAtDate.day = [createdAt substringWithRange:dayRange].integerValue;
    createdAtDate.month = [self.appDelegate.months[[createdAt substringWithRange:monthRange]] integerValue];
    createdAtDate.minute = [createdAt substringWithRange:minRange].integerValue;
    createdAtDate.hour = [createdAt substringWithRange:hourRange].integerValue;
    createdAtDate.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:createdAtDate];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    self.timeLabel.text =
    (interval < 60) ? [NSString stringWithFormat:@"%.0fs", interval] :
    (interval < 3600) ? [NSString stringWithFormat:@"%.0fm", interval/60] :
    (interval < 86400) ? [NSString stringWithFormat:@"%.0fh", interval/3600] :
    (interval < 31536000) ? [NSString stringWithFormat:@"%.0fd", interval/86400] : @">1y";
    [self.timeLabel sizeToFit];
    self.user = tweet[@"user"];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ @%@", self.user[@"name"], self.user[@"screen_name"]];
    NSMutableAttributedString *attStr = self.nameLabel.attributedText.mutableCopy;
    NSRange screenNameRange = {attStr.length - ([self.user[@"screen_name"] length] + 1), [self.user[@"screen_name"] length] + 1};
    [attStr addAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor], NSFontAttributeName: [UIFont systemFontOfSize:14.0f]} range:screenNameRange];
    self.nameLabel.attributedText = attStr.copy;
    self.countRetweetLabel.text =
    ([self.tweetDict[@"retweet_count"] integerValue] == 1)?
    @"1 Retweet":
    [NSString stringWithFormat:@"%@ Retweets", self.tweetDict[@"retweet_count"]];
    if (self.retweetedByUser != nil) {
        if ([tweet[@"retweeted"] boolValue]) {
            if ([self.retweetedByUser[@"screen_name"] isEqualToString:self.appDelegate.currentAccount.username]) {
                self.retweetedByLabel.text = @"Retweeted by you";
            }
            else {
                self.retweetedByLabel.text = [NSString stringWithFormat:@"Retweeted by %@ and you", self.retweetedByUser[@"screen_name"]];
            }
        }
        else {
            self.retweetedByLabel.text = [NSString stringWithFormat:@"Retweeted by %@", self.retweetedByUser[@"screen_name"]];
        }
    }
    else {
        if ([tweet[@"retweeted"] boolValue]) {
            self.retweetedByLabel.text = @"Retweeted by you";
        }
        else {
            self.retweetedByLabel.text = @"";
        }
    }
    self.retweetedByLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.retweetedByLabel.adjustsFontSizeToFitWidth = YES;
    self.retweetedByLabel.numberOfLines = 1;
    [self.retweetedByLabel sizeToFit];
    NSString *tweetString = tweet[@"text"];
    self.tweetLabel.delegate = self;
    [self setTweetViewWithTweetString:tweetString entities:tweet[@"entities"] place:tweet[@"place"]];
    // Calculate Tweet View Height
    self.tweetLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tweetLabel.adjustsFontSizeToFitWidth = NO;
    self.tweetLabel.numberOfLines = 0;
    [self.tweetLabel sizeToFit];
    // Calculate Retweeted by Label Height
    // Tap Avatar Image
    UITapGestureRecognizer *tapAvatarImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    tapAvatarImage.numberOfTapsRequired = 1;
    [tapAvatarImage setDelegate:self];
    [self.avatarImageView addGestureRecognizer:tapAvatarImage];
    // Tap Retweeted By Label
    UITapGestureRecognizer *tapRetweetedByLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRetweetedByLabel:)];
    tapRetweetedByLabel.numberOfTapsRequired = 1;
    tapRetweetedByLabel.delegate = self;
    [self.retweetedByLabel addGestureRecognizer:tapRetweetedByLabel];
    // Long Press Avatar Image
    UILongPressGestureRecognizer *longPressAvatarImage = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAvatar:)];
    longPressAvatarImage.minimumPressDuration = 0.5;
    longPressAvatarImage.delegate = self;
    longPressAvatarImage.allowableMovement = 0;
    [self.avatarImageView addGestureRecognizer:longPressAvatarImage];
    // Long Press Retweeted By Label
    UILongPressGestureRecognizer *longPressRetweetedByLabel = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRetweetedByLabel:)];
    longPressRetweetedByLabel.minimumPressDuration = 0.5;
    longPressRetweetedByLabel.delegate = self;
    longPressRetweetedByLabel.allowableMovement = 0;
    [self.retweetedByLabel addGestureRecognizer:longPressRetweetedByLabel];
    [self setAvatarImage:[UIImage imageNamed:@"white"]];
    dispatch_queue_t q = dispatch_queue_create("q1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(q, ^{
        NSDictionary *attributes = @{
            CallImageFileAttributeLink: [NSURL URLWithString:[tweet[@"user"][@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]],
            CallImageFileAttributeUserID: tweet[@"user"][@"id"]};
        [self setAvatarImage:[self.appDelegate callImageFileOption:CallImageFileOptionAvatar attributes:attributes]];
    });
}

- (void)setTweetViewWithTweetString:(NSString *)tweet entities:(NSDictionary *)entities place:(NSDictionary *)place {
    __block NSString *tweetString = [[[tweet
        stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
        stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"]
        stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    NSArray *urls = entities[@"urls"];
    NSArray *media = entities[@"media"];
    NSArray *userMentions = entities[@"user_mentions"];
    NSArray *hashtags = entities[@"hashtags"];
    NSArray *symbols = entities[@"symbols"];
    self.entitiesInArray = [NSMutableArray array];
    __block NSRange range;
    dispatch_group_t g1 = dispatch_group_create(), g2 = dispatch_group_create(), g3 = dispatch_group_create();
    dispatch_queue_t q1 = dispatch_queue_create("q1", DISPATCH_QUEUE_SERIAL), q2 = dispatch_queue_create("q2", DISPATCH_QUEUE_CONCURRENT), q3 = dispatch_queue_create("q3", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(g1, q1, ^{
        for (NSDictionary *url in urls) {
            tweetString = [tweetString stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
        }
        for (NSDictionary *medium in media) {
            tweetString = [tweetString stringByReplacingOccurrencesOfString:medium[@"url"] withString:medium[@"display_url"]];
        }
    });
    dispatch_group_wait(g1, DISPATCH_TIME_FOREVER);
    dispatch_group_async(g3, q3, ^{
        if (place != nil && ![place isEqual:[NSNull null]]) {
            NSString *placeStr = [NSString stringWithFormat:@"\n%@", place[@"full_name"]];
            NSRange range = NSMakeRange(tweetString.length, placeStr.length);
            NSMutableAttributedString *attTweet = [[NSMutableAttributedString alloc] initWithString:[tweetString stringByAppendingString:placeStr] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]]}];
            [attTweet addAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor]} range:range];
            self.tweetLabel.attributedText = attTweet.copy;
        }
        else {
            self.tweetLabel.text = tweetString;
        }
    });
    dispatch_group_wait(g3, DISPATCH_TIME_FOREVER);
    dispatch_group_async(g2, q2, ^{
        for (NSDictionary *url in urls) {
            range = [tweetString rangeOfString:url[@"display_url"]];
            [self.entitiesInArray addObject:url];
            [self.tweetLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"twt-url://%d", (int)[self.entitiesInArray indexOfObject:url]]] withRange:range];
        }
        for (NSDictionary *medium in media) {
            range = [tweetString rangeOfString:medium[@"display_url"]];
            [self.entitiesInArray addObject:medium];
            [self.tweetLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"twt-media://%d", (int)[self.entitiesInArray indexOfObject:medium]]] withRange:range];
        }
        for (NSDictionary *user in userMentions) {
            NSString *userName = user[@"screen_name"];
            range = [tweetString rangeOfString:[NSString stringWithFormat:@"@%@", userName] options:NSCaseInsensitiveSearch];
            [self.entitiesInArray addObject:user];
            [self.tweetLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"twt-user://%d", (int)[self.entitiesInArray indexOfObject:user]]] withRange:range];
        }
        for (NSDictionary *hashtag in hashtags) {
            NSString *tagName = hashtag[@"text"];
            range = [tweetString rangeOfString:[NSString stringWithFormat:@"#%@", tagName] options:NSCaseInsensitiveSearch];
            [self.entitiesInArray addObject:hashtag];
            [self.tweetLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"twt-hashtag://%d", (int)[self.entitiesInArray indexOfObject:hashtag]]] withRange:range];
        }
        for (NSDictionary *symbol in symbols) {
            NSString *symbolName = symbol[@"text"];
            range = [tweetString rangeOfString:[NSString stringWithFormat:@"$%@", symbolName] options:NSCaseInsensitiveSearch];
            [self.entitiesInArray addObject:symbol];
            [self.tweetLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"twt-symbol://%d", (int)[self.entitiesInArray indexOfObject:symbol]]] withRange:range];
        }
    });
    dispatch_group_wait(g2, DISPATCH_TIME_FOREVER);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)setAvatarImage:(UIImage *)image {
    self.avatarImageView.image = image;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.avatarImageView maskToCircleWithAvatarSide:AVATAR_SIDE];
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSDictionary *entities = self.entitiesInArray[url.host.intValue];
    if ([url.scheme isEqualToString:@"twt-user"]) {
        if ([self.delegate respondsToSelector:@selector(tweetCell:didTapLinkWithUserEntities:)]) {
            [self.delegate tweetCell:self didTapLinkWithUserEntities:entities];
        }
    }
    else if ([url.scheme isEqualToString:@"twt-hashtag"]) {
        if ([self.delegate respondsToSelector:@selector(tweetCell:didTapLinkWithHashtagEntities:)]) {
            [self.delegate tweetCell:self didTapLinkWithHashtagEntities:entities];
        }
    }
    else if ([url.scheme isEqualToString:@"twt-symbol"]) {
        if ([self.delegate respondsToSelector:@selector(tweetCell:didTapLinkWithSymbolEntities:)]) {
            [self.delegate tweetCell:self didTapLinkWithSymbolEntities:entities];
        }
    }
    else if ([url.scheme isEqualToString:@"twt-media"]) {
        if ([self.delegate respondsToSelector:@selector(tweetCell:didTapLinkWithMediaEntities:)]) {
            [self.delegate tweetCell:self didTapLinkWithMediaEntities:entities];
        }
    }
    else if ([url.scheme isEqual:@"twt-url"]) {
        if ([self.delegate respondsToSelector:@selector(tweetCell:didTapLinkWithURLEntities:)]) {
            [self.delegate tweetCell:self didTapLinkWithURLEntities:entities];
        }
    }
}

@end
