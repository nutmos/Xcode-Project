//
//  APPDetailViewController.m
//  RSSreader
//
//  Created by Rafael Garcia Leiva on 08/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *myStr = [[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"%09" withString:@""];
    NSURL *myURL = [NSURL URLWithString:myStr];
    NSLog(@"myURL = %@",myURL);
    NSLog(@"self.url = %@",self.url);
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.webView loadRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
