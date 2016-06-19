//
//  NewTweetViewController.m
//  Twt
//
//  Created by Nattapong Mos on 26/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

/*typedef enum {
    PostLocationNotPost,
    PostLocationPost
}PostLocation;*/

#import "NewTweetViewController.h"
#import "AppDelegate.h"
#import "Base64.h"

@interface NewTweetViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *tweetButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIImage *imageToTweet;
@property (weak, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *tweetSent;
@property (nonatomic) CLLocationCoordinate2D location2D;
//@property (nonatomic) PostLocation postLocationStatus;
@property (nonatomic, getter = isPostLocation) BOOL postLocation;

@end

@implementation NewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *text;
    if (self.option == NewTweetTypeReply) {
        text = @"";
        for (NSString *screenName in self.inReplyToUserScreenName) {
            text = [text stringByAppendingString:[NSString stringWithFormat:@"@%@ ", screenName]];
        }
    }
    else if (self.option == NewTweetTypeNewTweet) {
        text = @"";
    }
    else if (self.option == NewTweetTypeQuoteTweet) {
        NSString *screenName, *tweet;
        if (self.inReplyToStatus[@"retweeted_status"]) {
            screenName = self.inReplyToStatus[@"retweeted_status"][@"user"][@"screen_name"];
            tweet = self.inReplyToStatus[@"retweeted_status"][@"text"];
        }
        else {
            screenName = self.inReplyToStatus[@"user"][@"screen_name"];
            tweet = self.inReplyToStatus[@"text"];
        }
        text = [NSString stringWithFormat:@"RT @%@: %@",screenName, tweet];
    }
    else if (self.option == NewTweetTypeNewTweetWithText) {
        text = self.tweetString;
    }
    self.tweetText.text = text;
    self.tweetText.inputAccessoryView = self.toolbar;
    [self textViewDidChange:self.tweetText];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tweetText becomeFirstResponder];
}

#pragma mark - Get Data Method

- (void)postTweetWithMediaParameters:(NSDictionary *)parameters {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostTweetWithMediaURL stringParameter:nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * tweetSent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (tweetSent.count && tweetSent[@"errors"] == nil) {
                    self.tweetSent = tweetSent;
                }
                else if (tweetSent[@"errors"]) {
                    NSLog(@"error = %@", tweetSent[@"errors"]);
                }
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

- (void)postTweetWithParameters:(NSDictionary *)parameters {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostTweetURL stringParameter:nil];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * tweetSent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if (tweetSent.count && tweetSent[@"errors"] == nil) {
                    self.tweetSent = tweetSent;
                }
                else if (tweetSent[@"errors"]) {
                    NSLog(@"error = %@", tweetSent[@"errors"]);
                }
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

#pragma mark - Press Button

- (IBAction)didLocationButtonPressed:(UIBarButtonItem *)sender {
    if (self.isPostLocation) {
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        lm.delegate = self;
        lm.desiredAccuracy = kCLLocationAccuracyBest;
        lm.distanceFilter = kCLDistanceFilterNone;
        [lm startUpdatingLocation];
        
        CLLocation *location = [lm location];
        
        self.location2D = [location coordinate];
        NSLog(@"%lf %lf", self.location2D.longitude, self.location2D.latitude);
        sender.image = [UIImage imageNamed:@"location_pressed"];
        self.postLocation = YES;
    }
    else {
        sender.image = [UIImage imageNamed:@"location"];
        self.postLocation = NO;
    }
}

- (IBAction)didCancelButtonPressed:(id)sender {
    if ([self.tweetText.text isEqualToString:@""]) {
        [self performSegueWithIdentifier:@"UnwindSelf" sender:self];
    }
    else {
        if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[self.appDelegate cancelAlertAction]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self performSegueWithIdentifier:@"UnwindSelf" sender:self];
            }]];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard" otherButtonTitles:nil];
            [actionSheet showInView:self.view];
        }
    }
}

- (IBAction)didAddPhotoButtonPressed:(id)sender {
    if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[self.appDelegate cancelAlertAction]];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addMediaByUsingCamera];
            }]];
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self addMediaByUsingPhotoLibrary];
            }]];
        }
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)didTweetButtonPressed:(id)sender {
    if (self.imageToTweet) {
        NSDictionary *parameters;
        if (self.option == NewTweetTypeNewTweet) {
            if (self.postLocation) {
                parameters = @{@"status": self.tweetText.text,
                               @"media[]": [Base64 encode:UIImageJPEGRepresentation(self.imageToTweet, 10.0f)],
                               @"lat": [NSString stringWithFormat:@"%lf", self.location2D.latitude],
                               @"long": [NSString stringWithFormat:@"%lf", self.location2D.longitude],
                               @"display_coordinates": @"true"};
            }
            else {
                parameters = @{@"status": self.tweetText.text,
                               @"media[]": [Base64 encode:UIImageJPEGRepresentation(self.imageToTweet, 10.0f)]};
            }
        }
        else if (self.option == NewTweetTypeQuoteTweet ||
                 self.option == NewTweetTypeReply) {
            if (self.postLocation) {
                parameters = @{@"status": self.tweetText.text,
                               @"media[]": [Base64 encode:UIImageJPEGRepresentation(self.imageToTweet, 10.0f)],
                               @"in_reply_to_status_id": [self.inReplyToStatus[@"id"] stringValue],
                               @"lat": [NSString stringWithFormat:@"%lf", self.location2D.latitude],
                               @"long": [NSString stringWithFormat:@"%lf", self.location2D.longitude],
                               @"display_coordinates": @"true"};
            }
            else {
                parameters = @{@"status": self.tweetText.text,
                               @"media[]": [Base64 encode:UIImageJPEGRepresentation(self.imageToTweet, 10.0f)],
                               @"in_reply_to_status_id": [self.inReplyToStatus[@"id"] stringValue]};
            }
        }
        [self postTweetWithParameters:parameters];
    }
    else {
        NSDictionary *parameters;
        if (self.option == NewTweetTypeNewTweet) {
            if (self.postLocation) {
                parameters = @{@"status": self.tweetText.text,
                               @"lat": [NSString stringWithFormat:@"%lf", self.location2D.latitude],
                               @"long": [NSString stringWithFormat:@"%lf", self.location2D.longitude],
                               @"display_coordinates": @"true"};
            }
            else {
                parameters = @{@"status": self.tweetText.text};
            }
        }
        else if (self.option == NewTweetTypeQuoteTweet ||
                 self.option == NewTweetTypeReply) {
            if (self.postLocation) {
                parameters = @{@"status": self.tweetText.text,
                               @"in_reply_to_status_id": [self.inReplyToStatus[@"id"] stringValue],
                               @"lat": [NSString stringWithFormat:@"%lf", self.location2D.latitude],
                               @"long": [NSString stringWithFormat:@"%lf", self.location2D.longitude],
                               @"display_coordinates": @"true"};
            }
            else {
                parameters = @{@"status": self.tweetText.text,
                               @"in_reply_to_status_id": [self.inReplyToStatus[@"id"] stringValue]};
            }
        }
        [self postTweetWithParameters:parameters];
    }
    [self performSegueWithIdentifier:@"UnwindSelf" sender:self];
}

#pragma mark - Action Sheet Delegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (id view in actionSheet.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if ([button.titleLabel.text isEqualToString:@"Discard"]) {
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonStr = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonStr isEqualToString:@"Discard"]) {
        [self performSegueWithIdentifier:@"UnwindSelf" sender:self];
    }
    else if ([buttonStr isEqualToString:@"Camera"]) {
        [self addMediaByUsingCamera];
    }
    else if ([buttonStr isEqualToString:@"Photo Library"]) {
        [self addMediaByUsingPhotoLibrary];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    int count = 140 - (int)textView.text.length;
    self.navigationItem.title = [NSString stringWithFormat:@"Compose (%d)", count];
    if (count == 140 || count < 0) {
        self.tweetButton.enabled = NO;
    }
    else {
        self.tweetButton.enabled = YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

#pragma mark - Media Picker

- (void)addMediaByUsingCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *camera = [[UIImagePickerController alloc] init];
        camera.delegate = self;
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:camera animated:YES completion:nil];
    }
}

- (void)addMediaByUsingPhotoLibrary {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    // Don't forget to add UIImagePickerControllerDelegate in your .h
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageToTweet = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:picker completion:nil];
}


@end
