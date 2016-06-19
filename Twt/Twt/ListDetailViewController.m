//
//  ListDetailViewController.m
//  Twt
//
//  Created by Nattapong Mos on 25/4/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "ListDetailViewController.h"
#import "AppDelegate.h"
#import "ListCreaterCell.h"
#import "UserViewController.h"
#import "DetailViewController.h"
#import "TweetInListViewController.h"
#import "UIViewController+RequiredObject.h"
#import "CreateListViewController.h"

@interface ListDetailViewController ()

@property (strong ,nonatomic) AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property UIActionSheet *actionSheet;

@end

@implementation ListDetailViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.estimatedRowHeight = 88;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    if (self.backBarButtonItemTitle != nil) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([self.listData[@"user"][@"screen_name"] isEqualToString:self.appDelegate.currentAccount.username]) {
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
    [self updateData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? CGFLOAT_MIN : UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *cellID = @"headerID";
            ListCreaterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[ListCreaterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            [cell setListDataDictionary:self.listData inViewController:self tableView:self.tableView];
            return cell;
        }
        else {
            static NSString *cellID = @"detailID";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.numberStyle = NSNumberFormatterNoStyle;
            numberFormatter.groupingSeparator = @",";
            numberFormatter.groupingSize = 3;
            numberFormatter.alwaysShowsDecimalSeparator = NO;
            numberFormatter.usesGroupingSeparator = YES;
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Members";
                cell.detailTextLabel.text = [numberFormatter stringFromNumber:(NSNumber *)self.listData[@"member_count"]];
            }
            else {
                cell.textLabel.text = @"Followers";
                cell.detailTextLabel.text = [numberFormatter stringFromNumber:(NSNumber *)self.listData[@"subscriber_count"]];
                
            }
            return cell;
        }
    }
    else {
        static NSString *cellID = @"buttonID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        if ([self.listData[@"user"][@"screen_name"] isEqualToString:self.appDelegate.currentAccount.username]) {
            cell.textLabel.text = @"Remove List";
            cell.textLabel.textColor = [UIColor redColor];
        }
        else {
            if ([self.listData[@"following"] boolValue]) {
                cell.textLabel.text = @"Unfollow List";
                cell.textLabel.textColor = [UIColor redColor];
            }
            else {
                cell.textLabel.text = @"Follow List";
                cell.textLabel.textColor = [UIColor blueColor];
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0) {
        return 101.0f;
    }
    else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row != 0) {
            self.selectedRowNumber = @((int)indexPath.row);
            [self performSegueWithIdentifier:@"ToDetail" sender:self];
        }
    }
    else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell.textLabel.text isEqualToString:@"Remove List"]) {
            if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
                UIAlertController * actionSheet = [UIAlertController alertControllerWithTitle:@"Are you sure to remove list?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [actionSheet addAction:[self.appDelegate cancelAlertAction]];
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self postDestroyListID:self.listData[@"id"]];
                }]];
                [self presentViewController:actionSheet animated:YES completion:nil];
            }
            else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure to remove list" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:nil];
                [actionSheet showInView:self.view];
            }
        }
        else if ([cell.textLabel.text isEqualToString:@"Unfollow List"]) {
            if ([[self.appDelegate majorSystemVersion] isEqualToString:@"8"]) {
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Are you sure to unfollow list?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self postUnsubscribeListID:self.listData[@"id"]];
                }]];
                [self presentViewController:actionSheet animated:YES completion:nil];
            }
            else {
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure to unfollow list?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil];
                [actionSheet showInView:self.view];
            }
        }
        else {
            [self postSubscribeListID:self.listData[@"id"]];
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    if ([segueID isEqualToString:@"ToUser"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.screenName = self.screenNameSentToNextVC;
        vc.avatarImage = self.avatarSentToNextVC;
    }
    else if ([segueID isEqualToString:@"ToDetail"]) {
        DetailViewController *vc = segue.destinationViewController;
        vc.listID = self.listData[@"id"];
        vc.listDetail = self.listData;
        if ([self.selectedRowNumber isEqualToNumber:@1]) {
            vc.options = DetailShowingTypeListMembers;
        }
        else if ([self.selectedRowNumber isEqualToNumber:@2]) {
            vc.options = DetailShowingTypeListFollowers;
        }
    }
    else if ([segueID isEqualToString:@"ToTweetInList"]) {
        TweetInListViewController *vc = segue.destinationViewController;
        vc.listDetail = self.listData;
    }
    else if ([segueID isEqualToString:@"ToCreateList"]) {
        CreateListViewController *vc = (CreateListViewController *)[segue.destinationViewController visibleViewController];
        vc.option = CreateListTypeEdit;
        vc.listData = self.listData;
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)sender {
    [self getListDataForListID:self.listData[@"id"]];
}

#pragma mark - Get Data Method

- (void)postSubscribeListID:(NSNumber *)listID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostSubscribeListURL stringParameter:nil];
        NSDictionary *parameters = @{@"list_id": [listID stringValue]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *listData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([listData isKindOfClass:[NSDictionary class]]) {
                    if (listData.count && listData[@"errors"] == nil) {
                        self.listData = listData;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                    else if (listData[@"errors"]) {
                        NSLog(@"error = %@", listData[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postUnsubscribeListID:(NSNumber *)listID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostDestroySubscribeListURL stringParameter:nil];
        NSDictionary *parameters = @{@"list_id": [listID stringValue]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                [self getListDataForListID:listID];
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postDestroyListID:(NSNumber *)listID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostDestroyListURL stringParameter:nil];
        NSDictionary *parameters = @{@"list_id": [listID stringValue]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

- (void)getListDataForListID:(NSNumber *)listID {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetShowListURL stringParameter:nil];
        NSDictionary *parameters = @{@"list_id": [listID stringValue]};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                //NSLog(@"data = %@", data);
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && data[@"errors"] == nil) {
                        self.listData = data;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                    else if (data[@"errors"]) {
                        NSLog(@"error = %@", data[@"errors"]);
                    }
                }
            }
            else {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

#pragma mark - User Interactions

- (IBAction)didEditButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"ToCreateList" sender:self];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Unfollow"]) {
        [self postUnsubscribeListID:self.listData[@"id"]];
    }
    else if ([buttonTitle isEqualToString:@"Remove"]) {
        [self postDestroyListID:self.listData[@"id"]];
    }
}

@end
