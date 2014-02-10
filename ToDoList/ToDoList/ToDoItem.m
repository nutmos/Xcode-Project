//
//  ToDoItem.m
//  ToDoList
//
//  Created by Nattapong Mos on 31/12/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#import "ToDoItem.h"

@interface ToDoItem ()

@property NSDate *completionDate;

@end

@implementation ToDoItem

- (id)completedValue {
    return [NSNumber numberWithBool:self.completed];
}

- (NSString *)description {

    if (self.completed) {
        return [NSString stringWithFormat:@"%@ Completed",self.itemName];
    }
    else {
        return [NSString stringWithFormat:@"%@ Incomplete",self.itemName];
    }
}

- (void)markAsCompleted:(BOOL)isCompleted {
    self.completed = isCompleted;
    [self setCompletionDate];
}

- (void)setCompletionDate {
    if (self.completed) self.completionDate = [NSDate date];
    else self.completionDate = nil;
}

@end
