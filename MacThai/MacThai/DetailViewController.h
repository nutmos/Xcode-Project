//
//  DetailViewController.h
//  MacThai
//
//  Created by Nattapong Mos on 14/3/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (copy, nonatomic) NSMutableString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
