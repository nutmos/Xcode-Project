//
//  ViewController.m
//  TRTw1
//
//  Created by Nattapong Mos on 29/1/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "ViewController.h"
#import <Twitter/Twitter.h>

@interface ViewController ()

- (IBAction)tweet:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tweet:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        NSLog(@"Connected and Authorized");
    }
    else {
        NSString *message = @"Please check your internet connection or Settings for a configured Twitter Account";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We're sorry" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alertView show];
    }
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [vc setInitialText:@"My first program tweet!"];
    [vc addImage:[UIImage imageNamed:@"twitter.png"]];
    [vc addURL:[NSURL URLWithString:@"http://nutmos2539.wordpress.com"]];
    [vc setCompletionHandler:^(SLComposeViewControllerResult result) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
