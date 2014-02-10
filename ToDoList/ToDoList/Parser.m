//
//  Parser.m
//  ToDoList
//
//  Created by Nattapong Mos on 3/1/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import "Parser.h"

@implementation Parser

+ (NSString *)getString:(NSString *)string tag:(NSString *)tag location:(int)location {
    NSString *ret = nil;
    if (string != nil) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:string];
        [scanner setScanLocation:location];
        [scanner scanUpToString:[NSString stringWithFormat:@"<%@>",tag] intoString:nil];
        [scanner scanString:[NSString stringWithFormat:@"<%@>",tag] intoString:nil];
        [scanner scanUpToString:[NSString stringWithFormat:@"</%@>", tag] intoString:&ret];
    }
    return ret;
}

@end
