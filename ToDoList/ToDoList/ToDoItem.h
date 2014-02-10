//
//  ToDoItem.h
//  ToDoList
//
//  Created by Nattapong Mos on 31/12/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject

@property NSString *itemName;
@property BOOL completed;
@property (readonly) NSDate *creationDate;

- (void)markAsCompleted:(BOOL)isCompleted;
- (void)setCompletionDate;
- (NSString *)description;
- (id)completedValue;

@end
