//
//  Product.h
//  Program
//
//  Created by Nattapong Mos on 29/12/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PrintBlock) (NSString *name, float price);

@interface Product : NSObject {
    NSMutableString *name;
    float price;
    PrintBlock printBlock;
}

@property PrintBlock printBlock;

- (id)initWithName:(NSString *)name price:(float)price;
- (void)setPrintBlock:(PrintBlock) block;
- (void)printWithName:(NSString *)name andPrice:(float)price;

@end
