//
//  NewTweetViewController.m
//  Twt
//
//  Created by Nattapong Mos on 26/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "NewTweetViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"

@interface NewTweetViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *tweetButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) NSDictionary *tweetSent;

@end

@implementation NewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tweetText setText:@""];
    [self.tweetText becomeFirstResponder];
}

- (IBAction)didCancelButtonPressed:(id)sender {
    if (![self.tweetText.text isEqualToString:@""]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard" otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Discard"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == self.tweetButton) {
        if (self.tweetText.text.length) {
            NSURL *feed = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.tweetText.text, @"status", nil];
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            request.account = [appDelegate.account objectAtIndex:0];
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (!error) {
                    self.tweetSent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                    NSLog(@"tweet that sent = %@", self.tweetSent); 
                }
                else {
                    [[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        }
    }
}

@end
