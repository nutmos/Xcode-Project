//
//  NewToDoViewController.h
//  ToDoList
//
//  Created by Nattapong Mos on 31/12/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface NewToDoViewController : UIViewController

@property BOOL didDoneButtonPressed;
@property ToDoItem *toDoItem;

@end
