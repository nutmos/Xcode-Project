//
//  AllLocationsViewController.m
//  Twt
//
//  Created by Nattapong Mos on 14/5/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "AllLocationsViewController.h"
#import "LocationsInCountryViewController.h"
#import "AppDelegate.h"
#import "TrendsViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface AllLocationsViewController () {
    CLLocation *currentLocation;
}

@property (strong, nonatomic) NSArray *locationsArray;
@property (strong, nonatomic) NSArray *countryArray;
@property (nonatomic) NSInteger rowSelected;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
//@property (strong, nonatomic) NSString *locationNameSentToNextVC;
//@property (strong, nonatomic) NSNumber *woeidSentToNextVC;

@end

@implementation AllLocationsViewController

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
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.tableView.tableFooterView = [self.appDelegate clearTableFooterView];
    if (self.backBarButtonItemTitle) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:self.backBarButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    }
    [self getAllAvailableLocationTrends];
}

- (IBAction)didCancelButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"CancelPressToTrends" sender:self];
}

#pragma mark - Get Data Method

- (void)getWoeidAtLocation:(CLLocation *)location {
    //NSLog(@"getWoeid");
    if (self.appDelegate.account.count) {
        NSURL *feed = [self.appDelegate requestURLWithOption:RequestGetWOEIDAtLocationURL stringParameter:nil];
        NSDictionary *parameters = @{@"lat": [NSString stringWithFormat:@"%f",self.location.coordinate.latitude], @"long": [NSString stringWithFormat:@"%f", self.location.coordinate.longitude]};
        //NSLog(@"parameters = %@", parameters);
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:parameters];
        request.account = self.appDelegate.currentAccount;
        //NSLog(@"request start");
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                //NSLog(@"data");
                if ([data isKindOfClass:[NSArray class]]) {
                    if (data.count) {
                        self.locationNameSentToNextVC = data[0][@"name"];
                        self.woeidSentToNextVC = data[0][@"woeid"];
                        //NSLog(@"locationName = %@, woeid = %@", self.locationNameSentToNextVC, self.woeidSentToNextVC);
                        [self performSegueWithIdentifier:@"ToTrends" sender:self];
                    }
                }
                else if ([data isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"error = %@", ((NSDictionary *)data)[@"errors"]);
                }
            }
        }];
    }
}

- (void)getAllAvailableLocationTrends {
    if (self.appDelegate.account.count) {
        NSURL *feed = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/available.json"];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feed parameters:nil];
        request.account = self.appDelegate.currentAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSArray * dataArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                if ([dataArray isKindOfClass:[NSArray class]]) {
                    if ([dataArray count]) {
                        NSMutableDictionary *locationsDictionary = [[NSMutableDictionary alloc] init];
                        @synchronized (locationsDictionary) {
                            for (NSDictionary *object in dataArray) {
                                @synchronized (dataArray) {
                                    NSString *country = object[@"country"];
                                    if (locationsDictionary[country]) {
                                        NSMutableDictionary *locationsInCountry = locationsDictionary[country];
                                        locationsInCountry[object[@"name"]] = object;
                                        //[locationsInCountry setObject:object forKey:[object objectForKey:@"name"]];
                                    }
                                    else {
                                        NSMutableDictionary *locationsInCountry = [[NSMutableDictionary alloc] initWithObjects:@[object] forKeys:@[object[@"name"]]];
                                        //[locationsDictionary setObject:locationsInCountry forKey:country];
                                        locationsDictionary[country] = locationsInCountry;
                                    }
                                }
                            }
                            [locationsDictionary removeObjectForKey:@""];
                            self.countryArray = locationsDictionary.allKeys;
                            self.countryArray = [self.countryArray sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
                                return [str1 localizedCompare:str2];
                            }];
                            NSMutableArray *array2 = [NSMutableArray array];
                            for (NSString *key in self.countryArray) {
                                [array2 addObject:locationsDictionary[key]];
                            }
                            self.locationsArray = array2.copy;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }
                else if ([dataArray isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"error = %@", ((NSDictionary *)dataArray)[@"errors"]);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"locationID" forIndexPath:indexPath];
        /*if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationID"];
        }*/
        cell.textLabel.text = @"Current Location";
    }
    else {
        NSDictionary *locationsInCountry = self.locationsArray[indexPath.row-1];
        NSString *country = self.countryArray[indexPath.row-1];
        if (locationsInCountry.count > 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"moreLocationID" forIndexPath:indexPath];
            /*if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moreLocationID"];
            }*/
            cell.textLabel.text = country;
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"locationID" forIndexPath:indexPath];
            /*if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationID"];
            }*/
            cell.textLabel.text = country;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        /*self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [self.locationManager startUpdatingLocation];
        [self performSegueWithIdentifier:@"ToTrends" sender:self];*/
        
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        lm.delegate = self;
        lm.desiredAccuracy = kCLLocationAccuracyBest;
        lm.distanceFilter = kCLDistanceFilterNone;
        [lm startUpdatingLocation];
        [self getWoeidAtLocation:[lm location]];
        //CLLocation *location = [lm location];
        //[self performSegueWithIdentifier:@"ToTrends" sender:self];
    }
    else {
        NSDictionary *allLocationsInCountry = self.locationsArray[indexPath.row - 1];
        if (allLocationsInCountry.count == 1) {
            NSDictionary *locationData = allLocationsInCountry.allValues[0];
            self.locationNameSentToNextVC = locationData[@"name"];
            self.woeidSentToNextVC = locationData[@"woeid"];
            [self performSegueWithIdentifier:@"ToTrends" sender:self];
        }
        else {
            self.rowSelected = indexPath.row;
            [self performSegueWithIdentifier:@"ToLocationsInCountry" sender:self];
        }
    }
}

#pragma mark - Location Manager Delegate

/*- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"location updated");
    self.location = [manager location];
    [self getWoeidAtLocation:self.location];
}*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToTrends"]) {
        TrendsViewController *vc = segue.destinationViewController;
        vc.trendsLocation = self.locationNameSentToNextVC;
        vc.trendsWOEID = [self.woeidSentToNextVC integerValue];
    }
    else if ([segue.identifier isEqualToString:@"ToLocationsInCountry"]) {
        LocationsInCountryViewController *vc = segue.destinationViewController;
        vc.locations = self.locationsArray[self.rowSelected - 1];
    }
}

#pragma mark - Location Manager Delegate

@end
