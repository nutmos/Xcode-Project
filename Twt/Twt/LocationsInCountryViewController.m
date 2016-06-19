//
//  LocationsInCountryViewController.m
//  Twt
//
//  Created by Nattapong Mos on 16/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "LocationsInCountryViewController.h"
#import "TrendsViewController.h"

@interface LocationsInCountryViewController ()

@property (strong, nonatomic) NSArray *locationsArray;
@property (strong, nonatomic) NSArray *locationsName;

@end

@implementation LocationsInCountryViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.backBarButtonItemTitle) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    self.locationsName = self.locations.allKeys;
    self.locationsName = [self.locationsName sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return [str1 localizedCompare:str2];
    }];
    self.locationsArray = @[];
    for (NSString *key in self.self.locationsName) {
        self.locationsArray = [self.locationsArray arrayByAddingObject:self.locations[key]];
    }
    self.tableView.tableFooterView = [(AppDelegate *)[UIApplication sharedApplication].delegate clearTableFooterView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationID" forIndexPath:indexPath];
    /*if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationID"];
    }*/
    cell.textLabel.text = self.locationsArray[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.locationsArray[indexPath.row];
    self.locationNameSentToNextVC = data[@"name"];
    self.woeidSentToNextVC = data[@"woeid"];
    [self performSegueWithIdentifier:@"ToTrends" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToTrends"]) {
        TrendsViewController *vc = segue.destinationViewController;
        vc.trendsLocation = self.locationNameSentToNextVC;
        vc.trendsWOEID = [self.woeidSentToNextVC integerValue];
    }
}

@end
