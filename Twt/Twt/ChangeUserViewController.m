//
//  ChangeUserViewController.m
//  Twt
//
//  Created by Nattapong Mos on 25/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "ChangeUserViewController.h"
#import "AppDelegate.h"
#import "UserCell.h"

@interface ChangeUserViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation ChangeUserViewController

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
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self getUserLookupForAccountsArray:self.appDelegate.account];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interaction

- (IBAction)didCancelButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"UnwindChangeUser" sender:self];
}

#pragma mark - Get Data Method

// Get Parameters ACAccounts Array
- (void)getUserLookupForAccountsArray:(NSArray *)users {
    __block NSString *str = @"";
    dispatch_queue_t q1 = dispatch_queue_create("q1", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t g1 = dispatch_group_create();
    dispatch_group_async(g1, q1, ^{
        for (ACAccount *user in users) {
            if ([user isEqual:users.lastObject]) str = [str stringByAppendingString:user.username];
            else str = [str stringByAppendingString:[NSString stringWithFormat:@"%@,",user.username]];
        }
    });
    dispatch_group_wait(g1, DISPATCH_TIME_FOREVER);
    NSDictionary *parameters = @{@"screen_name": str};
    NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetLookupUserURL stringParameter:nil];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
    request.account = self.appDelegate.currentAccount;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error) {
            NSArray *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            if ([data isKindOfClass:[NSArray class]]) {
                if (data.count) {
                    self.dataArray = data;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }
            else if ([data isKindOfClass:[NSDictionary class]]) {
                NSLog(@"error = %@", ((NSDictionary *)data)[@"errors"]);
            }
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userID" forIndexPath:indexPath];
    /*if (!cell) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userID"];
    }*/
    [cell setUserDictionary:self.dataArray[indexPath.row] inViewController:self];
    if ([self.dataArray[indexPath.row][@"screen_name"] isEqualToString:self.appDelegate.currentAccount.username]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.appDelegate.currentAccount = self.appDelegate.account[indexPath.row];
    NSString *currentPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"lastUsedUsername.txt"];
    [self.appDelegate.currentAccount.username writeToFile:currentPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self performSegueWithIdentifier:@"UnwindChangeUser" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
