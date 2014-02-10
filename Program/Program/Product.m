//
//  Product.m
//  Program
//
//  Created by Nattapong Mos on 29/12/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#import "Product.h"

@implementation Product

@dynamic printBlock;

- (id)initWithName:(NSString *)n price:(float)p {
    self = [super init];
    if (self != nil) {
        name = [NSMutableString stringWithString:n];
        price = p;
    }
    return self;
}

- (void)setPrintBlock:(PrintBlock)block {
    printBlock = [block copy];
}

- (PrintBlock)getPrintBlock {
    return [printBlock copy];
}

- (void)printWithName:(NSString *)n andPrice:(float)p {
    printBlock(n,p);
}

@end
