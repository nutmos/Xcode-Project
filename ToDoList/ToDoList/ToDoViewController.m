//
//  ToDoViewController.m
//  ToDoList
//
//  Created by Nattapong Mos on 31/12/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#import "ToDoViewController.h"
#import "ToDoItem.h"

@interface ToDoViewController ()

@property NSMutableArray *arrayContainToDoItem;

@end

@implementation ToDoViewController

- (void)writeToFile {
    NSString *path = [NSString stringWithFormat:@"%@/ToDoData.txt",[[NSBundle mainBundle] bundlePath]];
    NSLog(@"File Path %@",path);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    int count = [self.arrayContainToDoItem count];
    for (int i = 0; i < count; ++i) {
        [dict setObject:[self.arrayContainToDoItem objectAtIndex:i] forKey:[NSNumber numberWithInt:i]];
    }
    NSString *m_error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&m_error];
    NSLog(@"%@",plistData);
    BOOL error = [plistData writeToFile:path atomically:YES];
    if (error == 0) {
        NSLog(@"!!!!!ERROR!!!!!");
    }
}

- (void)loadInitialData {
    NSString *path = [NSString stringWithFormat:@"%@/ToDoData.txt",[[NSBundle mainBundle] bundlePath]];
    NSPropertyListFormat format;
    NSString *errorDesc = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"txt"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSDictionary *tmp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!tmp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    else {
        NSLog(@"%@",tmp);
    }
    [self.arrayContainToDoItem addObjectsFromArray:[tmp objectForKey:@"key"]];
    NSLog(@"arrayContainToDoItem = %@",self.arrayContainToDoItem);
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arrayContainToDoItem = [[NSMutableArray alloc] init];
    [self loadInitialData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.arrayContainToDoItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ToDoItem *toDoItem = [self.arrayContainToDoItem objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.itemName;
    
    if (toDoItem.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (IBAction)unwindToList:(UIStoryboardSegue *)seague {
    NewToDoViewController *source = [seague sourceViewController];
    ToDoItem *item = source.toDoItem;
    if (item != nil) {
        [self.arrayContainToDoItem addObject:item];
        [self.tableView reloadData];
        [self writeToFile];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ToDoItem *tappedItem = [self.arrayContainToDoItem objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self writeToFile];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.arrayContainToDoItem removeObjectAtIndex:indexPath.row];
    [tableView reloadData];
}

@end
