//
//  LoginViewController.m
//  alcdetector
//
//  Created by Nattapong Ekudomsuk on 2/8/58.
//  Copyright © พ.ศ. 2558 Nattapong Ekudomsuk. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UILabel *enterPassLbl;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.enterPassLbl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.enterPassLbl.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:(screenSize.width - self.enterPassLbl.bounds.size.width)/2];
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.enterPassLbl attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.enterPassLbl.superview attribute:NSLayoutAttributeRight multiplier:1 constant:(screenSize.width - self.enterPassLbl.bounds.size.width)/2];
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.passwordField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.passwordField.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:(screenSize.width - self.passwordField.bounds.size.width)/2];
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.passwordField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.passwordField.superview attribute:NSLayoutAttributeRight multiplier:1 constant:(screenSize.width - self.passwordField.bounds.size.width)/2];
    [self.view addConstraints:@[constraint1, constraint2, constraint3, constraint4]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didLoginButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://onestone.eng.src.ku.ac.th/~b5530300049/exceed12/login.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postData = [NSString stringWithFormat:@"pwd=%@", self.passwordField.text];
    NSLog(@"postData = %@", postData);
    request.HTTPMethod = @"POST";
    request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    //NSLog(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"dataString = %@",dataStr);
                    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(processAfterGetData:) userInfo:dataStr repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }] resume];
}

- (void)processAfterGetData:(NSTimer *)data {
    NSLog(@"processAfterGetData");
    NSString *dataStr = [data userInfo];
    NSLog(@"data = %@", dataStr);
    NSString *match = @"Log-in is failed. Please try again." ;
    NSRange range = [dataStr rangeOfString:match options: NSCaseInsensitiveSearch];
    NSLog(@"found: %@", (range.location != NSNotFound) ? @"Yes" : @"No");
    if (range.location != NSNotFound) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:@"Please try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"ToMain" sender:nil];
    }
}

@end
