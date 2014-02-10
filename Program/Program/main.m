//
//  main.m
//  Program
//
//  Created by Nattapong Mos on 30/10/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        Product *macBook = [[Product alloc] initWithName:@"MacBook" price:200];
        Product *macBookAir = [[Product alloc] initWithName:@"MacBook Air" price:400];
        [macBook setPrintBlock:^(NSString *name, float price){
            NSLog(@"Product name: %@ \nPrice %f",name,price);
        }];
        [macBook printWithName:@"New MacBook" andPrice:400];
        PrintBlock block = [macBook getPrintBlock];
        
        
    }
    return 0;
}

