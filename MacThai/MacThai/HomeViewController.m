//
//  HomeViewController.m
//  MacThai
//
//  Created by Nattapong Mos on 22/8/57.
//  Copyright (c) พ.ศ. 2557 Nutmos. All rights reserved.
//

#import "HomeViewController.h"
#import "ArticleCell.h"

@interface HomeViewController ()

@property (strong, nonatomic) NSMutableArray *feeds;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSDictionary *items;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSString *element;
@property (strong, nonatomic) NSString *itemDescription;
@property (strong, nonatomic) NSString *content;

@end

@implementation HomeViewController

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
    //NSLog(@"viewDidLoad");
    [super viewDidLoad];
    self.feeds = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://www.macthai.com/feed/"];
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    self.parser.shouldResolveExternalEntities = NO;
    [self.parser parse];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArticleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ArticleCell"];
    
    [cell setArticleWithDictionary:[self.feeds objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [ArticleCell calculateCellHeightWithArticleDictionary:[self.feeds objectAtIndex:indexPath.row]];
    //NSLog(@"%.3f", height);
    return height;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"did start element");
    self.element = elementName;
    if ([self.element isEqualToString:@"item"]) {
        self.items = [[NSDictionary alloc] init];
        self.title = @"";
        self.itemDescription = @"";
        self.link = @"";
        self.content = @"";
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"did end element");
    if ([elementName isEqualToString:@"item"]) {
        if (self.items) {
            if (self.itemDescription.length > 100) {
                self.itemDescription = [[self.itemDescription substringWithRange:NSMakeRange(0, 100)] stringByAppendingString:@"..."];
            }
            self.itemDescription = [self.itemDescription stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.items = @{@"title": [self.title stringByReplacingOccurrencesOfString:@"\n" withString:@""], @"link": self.link, @"description": self.itemDescription};
            //NSLog(@"title = %@", self.title);
            [self.feeds addObject:[self.items copy]];
            self.title = nil;
            self.link = nil;
            self.items = nil;
            self.itemDescription = nil;
            self.content = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.element isEqualToString:@"title"]) {
        if (self.title) {
            self.title = [self.title stringByAppendingString:string];
        }
    }
    else if ([self.element isEqualToString:@"link"]) {
        if (self.link) {
            self.link = [self.link stringByAppendingString:string];
        }
    }
    else if ([self.element isEqualToString:@"description"]) {
        if (self.itemDescription) {
            self.itemDescription = [self.itemDescription stringByAppendingString:string];
        }
    }
    else if ([self.element isEqualToString:@"content:encoded"]) {
        if (self.content) {
            self.content = [self.content stringByAppendingString:string];
        }
    }
}

@end
