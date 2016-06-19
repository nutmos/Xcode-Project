//
//  AlcoholViewController.m
//  alcdetector
//
//  Created by Nattapong Ekudomsuk on 2/8/58.
//  Copyright © พ.ศ. 2558 Nattapong Ekudomsuk. All rights reserved.
//

#import "AlcoholViewController.h"

@interface AlcoholViewController ()

@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UILabel *alcRate;
@property (strong, nonatomic) IBOutlet UIButton *buzzerBtn;
@property (strong, nonatomic) IBOutlet UILabel *drunkStatus;

@end

@implementation AlcoholViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.alcRate.bounds;
    self.alcRate.frame = CGRectMake(frame.origin.x, frame.origin.y, [UIScreen mainScreen].bounds.size.width, frame.size.height);
    self.alcRate.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *s;
    s = [[NSMutableAttributedString alloc] initWithString:@"50"];
    [s addAttribute:NSKernAttributeName
              value:[NSNull null]
              range:NSMakeRange(0, s.length)];
    self.alcRate.attributedText = s;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateData) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSLayoutConstraint *constriant1 = [NSLayoutConstraint constraintWithItem:self.topLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.topLabel.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:(screenSize.width-self.topLabel.bounds.size.width)/2];
    NSLayoutConstraint *constriant2 = [NSLayoutConstraint constraintWithItem:self.topLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.topLabel.superview attribute:NSLayoutAttributeRight multiplier:1 constant:(screenSize.width-self.topLabel.bounds.size.width)/2];
    //NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.alcRate attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.alcRate.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    //NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.alcRate attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.alcRate.superview attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:self.buzzerBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.buzzerBtn.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:(screenSize.width - self.buzzerBtn.frame.size.width)/2];
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:self.buzzerBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.buzzerBtn.superview attribute:NSLayoutAttributeRight multiplier:1 constant:(screenSize.width - self.buzzerBtn.frame.size.width)/2];
    [self.view addConstraints:@[constriant1, constriant2, constraint5, constraint6]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateData {
    NSString *alcRateData = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://exceed.cupco.de/iot/ohzeed/board"]] encoding:NSUTF8StringEncoding];
    self.alcRate.text = alcRateData;
    if (self.alcRate.text.integerValue >= 500) {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"Danger" attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];
        self.drunkStatus.attributedText = attStr;
    }
    else {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"Normal" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        self.drunkStatus.attributedText = attStr;
    }
    //[self.alcRate sizeToFit];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didBuzzerBtnPressed:(id)sender {
    NSLog(@"buzzer btn pressed");
    NSURL *url = [NSURL URLWithString:@"http://exceed.cupco.de/iot/ohzeed/emer-buzzer"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postData = @"data=B";
    request.HTTPMethod = @"POST";
    request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
    /*[NSURLConnection sendAsynchronousRequest:<#(nonnull NSURLRequest *)#> queue:<#(nonnull NSOperationQueue *)#> completionHandler:<#^(NSURLResponse * __nullable response, NSData * __nullable data, NSError * __nullable connectionError)handler#>]
    [NSURLConnection sendAsynchronousRequest:request queue: [NSOperationQueue mainQueue] ]
    {
        (response, data, error) in
        println(response)
        
    }*/
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSLog(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
            }] resume];
}

@end
