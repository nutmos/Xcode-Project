//
//  BrowserViewController.m
//  Twt
//
//  Created by Nattapong Mos on 25/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "BrowserViewController.h"
#import "NewTweetViewController.h"
#import "UIViewController+RequiredObject.h"
#import <SafariServices/SafariServices.h>

@interface BrowserViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *activityItem;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reloadItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (strong, nonatomic) NSURL *url1;
@property (strong, nonatomic) NSURL *url2;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation BrowserViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.backBarButtonItemTitle != nil) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.title = self.address.host;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.activityItem setCustomView:self.activityIndicator];
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(64, 0, 44, 0)];
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.address];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interactions

- (IBAction)didShareButtonPressed:(id)sender {
    if ([self.appDelegate.majorSystemVersion isEqualToString:@"8"]) {
        NSArray * data = [[NSArray alloc] init];
        data = [data arrayByAddingObject:self.address];
        data = [data arrayByAddingObject:[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:data applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Tweet Link", @"Copy Link", @"Read It Later", nil];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)didReloadOrStopButtonPressed:(UIBarButtonItem *)sender {
    //Define tag 0 as stop, tag 1 as reload
    if (sender == self.stopItem) {
        [self.webView stopLoading];
    }
    else {
        [self.webView reload];
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonString = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonString isEqualToString:@"Open in Safari"]) {
        [[UIApplication sharedApplication] openURL:self.address];
    }
    else if ([buttonString isEqualToString:@"Tweet Link"]) {
        [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
    }
    else if ([buttonString isEqualToString:@"Copy Link"]) {
        UIPasteboard *sysPasterboard = [UIPasteboard generalPasteboard];
        sysPasterboard.string = self.webView.request.URL.absoluteString;
    }
    else if ([buttonString isEqualToString:@"Read It Later"]) {
        SSReadingList *readList = [SSReadingList defaultReadingList];
        [readList addReadingListItemWithURL:self.webView.request.URL title:[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"] previewText:nil error:nil];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToNewTweet"]) {
        NewTweetViewController *vc = (NewTweetViewController *)[segue.destinationViewController visibleViewController];
        vc.option = NewTweetTypeNewTweetWithText;
        vc.tweetString = self.address.description;
    }
}

#pragma mark - Web View Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //NSLog(@"url = %@", request.URL);
    NSURL *url = request.URL;
    if (!([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.shareButton.enabled = NO;
    NSMutableArray *itms = self.toolbar.items.mutableCopy;
    if (itms.count == 8) {
        [itms insertObject:self.stopItem atIndex:7];
    }
    else {
        itms[7] = self.stopItem;
    }
    self.toolbar.items = itms.copy;
    self.backButton.enabled = webView.canGoBack;
    self.nextButton.enabled = webView.canGoForward;
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.shareButton.enabled = YES;
    NSMutableArray *itms = self.toolbar.items.mutableCopy;
    if (itms.count == 8) {
        [itms insertObject:self.reloadItem atIndex:7];
    }
    else {
        itms[7] = self.reloadItem;
    }
    self.toolbar.items = itms.copy;
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (self.title == nil) {
        self.title = webView.request.URL.host;
    }
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.shareButton.enabled = NO;
    NSMutableArray *itms = self.toolbar.items.mutableCopy;
    if (itms.count == 8) {
        [itms insertObject:self.reloadItem atIndex:6];
    }
    else {
        itms[7] = self.reloadItem;
        //[itms replaceObjectAtIndex:7 withObject:self.reloadItem];
    }
    self.toolbar.items = itms.copy;
    [self.activityIndicator stopAnimating];
}

@end
