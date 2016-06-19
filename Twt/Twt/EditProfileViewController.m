//
//  EditProfileTableViewController.m
//  Twt
//
//  Created by Nattapong Mos on 22/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "EditProfileViewController.h"
#import "AppDelegate.h"
#import "Base64.h"
#import "UserViewController.h"
#import "UIImageView+Extension.h"

@interface EditProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;
@property (weak, nonatomic) IBOutlet UITextView *locationTextView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property BOOL changed;
@property AppDelegate *appDelegate;

@end

@implementation EditProfileViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.estimatedRowHeight = 88;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.changed = NO;
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    [self updateData];
}

- (void)updateData {
    self.nameTextView.text = self.userData[@"name"];
    self.urlTextView.text = self.userData[@"entities"][@"url"][@"urls"][0][@"expanded_url"];
    self.locationTextView.text = self.userData[@"location"];
    self.descriptionTextView.text = self.userData[@"description"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *currentPath = [[NSBundle mainBundle] resourcePath];
    NSString *avatarPath = [currentPath stringByAppendingPathComponent:@"Avatar"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.userData[@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]]];
    NSString *avatarImageFile = [avatarPath stringByAppendingPathComponent:[NSString stringWithFormat:@"user_%@", [self.userData[@"id"] stringValue]]];
    [fileMgr createFileAtPath:avatarImageFile contents:imageData attributes:@{NSFileType: NSFileTypeRegular}];
    [self setAvatarImage:[UIImage imageWithData:imageData]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.nameTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAvatarImage:(UIImage *)image {
    self.avatarImageView.image = image;
    [self.avatarImageView maskToCircleWithAvatarSide:30];
}

#pragma mark - Get Data Method

- (void)postUpdateProfilePicture:(UIImage *)image {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostUpdateProfileImageURL stringParameter:nil];
        NSData *data = UIImageJPEGRepresentation(image, 8.0f);
        NSDictionary *parameters = @{@"image": [Base64 encode:data]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (!data[@"errors"] && data.count) {
                        self.userData = data;
                        [self updateData];
                    }
                    else if (data[@"errors"]) {
                        NSLog(@"error = %@", data[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postUpdateProfileWithName:(NSString *)name URLString:(NSString *)url locationString:(NSString *)location description:(NSString *)description {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostUpdateProfileURL stringParameter:nil];
        NSDictionary *parameters = @{@"name": name, @"url": url, @"location":location, @"description": description};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (!data[@"errors"] && data.count) {
                        self.userData = data;
                    }
                    else if (data[@"errors"]) {
                        NSLog(@"error = %@", data[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - User Interactions

- (IBAction)didCancelButtonPressed:(id)sender {
    if (self.changed) {
        if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
            UIAlertController * actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
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
    else {
        [self performSegueWithIdentifier:@"UnwindSelf" sender:self];
    }
}

- (IBAction)didDoneButtonPressed:(id)sender {
    [self postUpdateProfileWithName:self.nameTextView.text URLString:self.urlTextView.text locationString:self.locationTextView.text description:self.descriptionTextView.text];
    [self performSegueWithIdentifier:@"UnwindSelf" sender:self];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Discard"]) {
        [self performSegueWithIdentifier:@"UnwindSelf" sender:self];
    }
    else if ([buttonTitle isEqualToString:@"Take a photo"]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }
    else if ([buttonTitle isEqualToString:@"Pick from library"]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[self.appDelegate cancelAlertAction]];
            UIAlertAction *takeAPhoto = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                    [self presentViewController:picker animated:YES completion:nil];
                }
            }];
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                takeAPhoto.enabled = NO;
            }
            [actionSheet addAction:takeAPhoto];
            UIAlertAction *library = [UIAlertAction actionWithTitle:@"Pick from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                        [self presentViewController:picker animated:YES completion:nil];
                    }
            }];
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                library.enabled = NO;
            }
            [actionSheet addAction:library];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo", @"Pick from library", nil];
            [actionSheet showInView:self.view];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.changed = YES;
}

#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self postUpdateProfilePicture:info[UIImagePickerControllerOriginalImage]];
}

@end
