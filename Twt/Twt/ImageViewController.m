//
//  ImageViewController.m
//  Twt
//
//  Created by Nattapong Mos on 9/7/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "ImageViewController.h"
#import "UIERealTimeBlurView.h"
#import "BrowserViewController.h"
#import "NewTweetViewController.h"
#import "UIViewController+RequiredObject.h"

@interface ImageViewController ()

@property (nonatomic, getter = isBarHide) BOOL barHide;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property AppDelegate *appDelegate;

@end

@implementation ImageViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isBarHide) {
        self.barHide = !self.isBarHide;
        self.navigationController.navigationBar.alpha = 1.0f;
        self.tabBarController.tabBar.alpha = 1.0f;
        self.imageView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.backBarButtonItemTitle) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.navigationController.title = @"Image";
    [self.activity startAnimating];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHideBar:)];
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

- (BOOL)prefersStatusBarHidden {
    return self.isBarHide;
}

- (void)tapToHideBar:(UITapGestureRecognizer *)sender {
    if (self.isBarHide) {
        self.barHide = !self.isBarHide;
        self.navigationController.navigationBar.alpha = 1.0f;
        self.tabBarController.tabBar.alpha = 1.0f;
        self.imageView.backgroundColor = [UIColor whiteColor];
        //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [self prefersStatusBarHidden];
    }
    else {
        self.barHide = !self.isBarHide;
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.imageView.backgroundColor = [UIColor blackColor];
            self.navigationController.navigationBar.alpha = 0.0f;
            self.tabBarController.tabBar.alpha = 0.0f;
        } completion:nil];
        //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self prefersStatusBarHidden];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.image) {
        self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageLink]];
    }
    self.imageView.image = self.image;
    [self.activity stopAnimating];
    self.activity.hidden = YES;
}

#pragma mark - User Interaction

- (IBAction)didShareButtonPressed:(id)sender {
    if ([self.appDelegate.majorSystemVersion isEqualToString:@"8"]) {
        /*UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Copy Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            pb.image = self.image;
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Save Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"View Website" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"ToBrowser" sender:self];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Tweet Link" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];*/
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.image, (self.shareLink != nil)?self.shareLink:self.imageLink] applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy Image", @"Save Image", @"View Website", @"Tweet Link", nil];
        [actionSheet showInView:self.view];
    }
    
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonString = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonString isEqualToString:@"Copy Image"]) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.image = self.image;
    }
    else if ([buttonString isEqualToString:@"Save Image"]) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }
    else if ([buttonString isEqualToString:@"View Website"]) {
        [self performSegueWithIdentifier:@"ToBrowser" sender:self];
    }
    else if ([buttonString isEqualToString:@"Tweet Link"]) {
        [self performSegueWithIdentifier:@"ToNewTweet" sender:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToBrowser"]) {
        BrowserViewController *vc = segue.destinationViewController;
        vc.address = self.shareLink;
    }
    else if ([segue.identifier isEqualToString:@"ToNewTweet"]) {
        NewTweetViewController *vc = (NewTweetViewController *)[segue.destinationViewController visibleViewController];
        vc.option = NewTweetTypeNewTweetWithText;
        vc.tweetString = self.shareLink.absoluteString;
    }
}

#pragma mark - Save Image

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    /*UIERealTimeBlurView *bv = [[UIERealTimeBlurView alloc] initWithFrame:CGRectMake((screenSize.width/2.0f)-100.0f, (screenSize.height/2.0f)-50.0f, 200.0f, 100.0f)];
    bv.layer.cornerRadius = 5;
    bv.layer.masksToBounds = YES;*/
    UIVisualEffectView *bv = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    bv.frame = CGRectMake((screenSize.width/2.0f)-100.0f, (screenSize.height/2.0f)-50.0f, 200.0f, 100.0f);
    bv.layer.cornerRadius = 5;
    bv.layer.masksToBounds = YES;
    UILabel *saveCompleted = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 100.0f)];
    saveCompleted.text = @"Save Completed!";
    saveCompleted.textAlignment = NSTextAlignmentCenter;
    [bv addSubview:saveCompleted];
    //bv.alpha = 0.0f;
    [self.view addSubview:bv];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        bv.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f delay:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            bv.alpha = 0.0f;
        } completion:nil];
    }];
    //[self performSelector:@selector(removeBlurView:) withObject:bv afterDelay:2.0f];
}

@end
