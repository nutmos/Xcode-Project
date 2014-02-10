//
//  main.m
//  Program 9.3
//
//  Created by Nattapong Mos on 13/10/2556.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        NSString *file = [NSString stringWithFormat:@"%@/data.arch",NSHomeDirectory()];
        NSMutableDictionary *dict;
        dict = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
        NSArray *keys = [dict allKeys];
        for (NSString *key in keys) {
            NSLog(@"key:%@ obj:%@",key, [dict objectForKey:key]);
        }
    }
    return 0;
}

