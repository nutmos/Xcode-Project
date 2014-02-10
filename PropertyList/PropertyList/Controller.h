//
//  Controller.h
//  PropertyList
//
//  Created by Nattapong Mos on 29/1/57.
//  Copyright (c) พ.ศ. 2557 Nattapong Mos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Controller : NSObject {
    NSString *personName;
    NSMutableArray *phoneNumbers;
}

@property (copy, nonatomic) NSString *personeName;
@property (retain, nonatomic) NSMutableArray *phoneNumbers;

@end
