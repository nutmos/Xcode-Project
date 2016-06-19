//
//  CreateListViewController.m
//  Twt
//
//  Created by Nattapong Mos on 30/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "AppDelegate.h"
#import "CreateListViewController.h"

@interface CreateListViewController ()

@property NSArray *dataArray;
@property BOOL changed;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateButton;
@property AppDelegate *appDelegate;

@end

@implementation CreateListViewController

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
    self.changed = NO;
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [self.appDelegate clearTableFooterView];
    if (self.option == CreateListTypeCreate) {
        self.navigationItem.rightBarButtonItem = self.createButton;
        self.createButton.enabled = NO;
    }
    else if (self.option == CreateListTypeEdit) {
        self.nameTextView.text = self.listData[@"name"];
        self.publicSwitch.on = self.listData[@"mode"][@"public"];
        self.descriptionTextView.text = self.listData[@"description"];
        self.navigationItem.rightBarButtonItem = self.updateButton;
        self.navigationItem.title = @"Edit List";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.nameTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Data Method

- (void)postCreateListName:(NSString *)name public:(BOOL)public description:(NSString *)description {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostCreateListURL stringParameter:nil];
        NSDictionary *parameters = @{@"name": name, @"mode": (public)?@"public":@"private", @"description": description};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                //NSLog(@"data = %@", data);
                if ([data isKindOfClass:[NSDictionary class]]) {
                    if (data.count && !data[@"errors"]) {
                        [self performSegueWithIdentifier:@"UnwindCreateList" sender:self];
                    }
                    else if (data[@"errors"]) {
                        NSString *errorMessage = data[@"errors"][0][@"message"];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (void)postUpdateListName:(NSString *)name public:(BOOL)public description:(NSString *)description {
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestPostUpdateListURL stringParameter:nil];
        NSDictionary *parameters = @{
            @"list_id": self.listData[@"id_str"],
            @"name": name,
            @"mode": (public)?@"public":@"private",
            @"description": description};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                [self performSegueWithIdentifier:@"UnwindCreateList" sender:self];
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - User Interactions

- (IBAction)didCreateButtonPressed:(id)sender {
    [self postCreateListName:self.nameTextView.text public:self.publicSwitch.isOn description:self.descriptionTextView.text];
}

- (IBAction)didUpdateButtonPressed:(id)sender {
    [self postUpdateListName:self.nameTextView.text public:self.publicSwitch.isOn description:self.descriptionTextView.text];
}

- (IBAction)didCancelButtonPressed:(id)sender {
    if (![self.descriptionTextView.text isEqualToString:@""] ||
        ![self.nameTextView.text isEqualToString:@""]) {
        if (self.changed == YES) {
            if ([self.appDelegate.majorSystemVersion isEqualToString:@"8"]) {
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self performSegueWithIdentifier:@"UnwindCreateList" sender:self];
                }]];
                [self presentViewController:actionSheet animated:YES completion:nil];
            }
            else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard" otherButtonTitles:nil];
                [actionSheet showInView:self.view];
            }
        }
        else {
            [self performSegueWithIdentifier:@"UnwindCreateList" sender:self];
        }
    }
    else {
        [self performSegueWithIdentifier:@"UnwindCreateList" sender:self];
    }
}

#pragma mark - Action Sheet Delegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (id view in actionSheet.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if ([button.titleLabel.text isEqualToString:@"Discard"]) {
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Discard"]) {
        [self performSegueWithIdentifier:@"UnwindCreateList" sender:self];
    }
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.changed = YES;
    if (self.option == CreateListTypeCreate) {
        if ([textView.text isEqualToString:@""]) {
            self.createButton.enabled = NO;
        }
        else {
            self.createButton.enabled = YES;
        }
    }
    else if (self.option == CreateListTypeEdit) {
        if ([textView.text isEqualToString:@""]) {
            self.updateButton.enabled = NO;
        }
        else {
            self.updateButton.enabled = YES;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

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
