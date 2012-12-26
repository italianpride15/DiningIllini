//
//  AddFoodTableViewController.m
//  Dining Illini
//
//  Created by ItalianPride15 on 12/4/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import "AddFoodTableViewController.h"
#import "sqlite3.h"

@interface AddFoodTableViewController ()

@property (nonatomic) NSMutableArray *favoriteFoodsTableContent;
@property (nonatomic) NSMutableSet *itemsToAddToTable; //need to avoid duplicates might need to load all prev items into here, add new items, then store back

- (void) populateTableViewArray;
- (void) removeDuplicates;

@end

@implementation AddFoodTableViewController

@synthesize favoriteFoodsTableContent = _favoriteFoodsTableContent;
@synthesize hallName = _hallName;
@synthesize itemsToAddToTable = _itemsToAddToTable;

sqlite3 *diningHallDB = NULL;

- (void) viewDidDisappear:(BOOL)animated {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    if (sqlite3_open([writableDBPath UTF8String], &diningHallDB) == SQLITE_OK) {
        
        [self removeDuplicates]; //NOT HOW I WANT TO DO THIS... 
        
        //update table with itemsToAddToTable set IF NOT EXISTS
        for (NSString *element in self.itemsToAddToTable) {
            NSString *tempString = @"INSERT INTO favoritefoods (Food) VALUES ('"; //INSERT OR REPLACE/ABORT/ETC FIX!!!
            tempString = [tempString stringByAppendingString:element];
            tempString = [tempString stringByAppendingString:@"')"];
            sqlite3_stmt *sqlInsertStatement;
            const char *sqlStatement = [tempString cStringUsingEncoding:NSASCIIStringEncoding];
            @try {
                if (sqlite3_prepare(diningHallDB, sqlStatement, -1, &sqlInsertStatement, NULL) != SQLITE_OK) {
                    NSLog(@"Error with prepare statement");
                }
                if(sqlite3_step(sqlInsertStatement) != SQLITE_DONE ) {
                    NSLog(@"Save Error: %s", sqlite3_errmsg(diningHallDB));
                }
                sqlite3_finalize(sqlInsertStatement);
            }
            @catch (NSException *e) {
                NSLog(@"Exception: %@", e);
            }
        }
        sqlite3_close(diningHallDB);
    }
    else {
        NSLog(@"An error opening the database has occured.");
    }
}

- (void) removeDuplicates {
    
    //update set with content from tables also
    const char *sqlStatement = "SELECT Food FROM favoritefoods";
    sqlite3_stmt *sqlSelectStatement;
    @try {
        sqlite3_prepare(diningHallDB, sqlStatement, -1, &sqlSelectStatement, NULL);
        while (sqlite3_step(sqlSelectStatement) == SQLITE_ROW)
        {
            NSString *tempString =[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlSelectStatement, 0)];
            [self.itemsToAddToTable addObject:tempString];
        }
        sqlite3_finalize(sqlSelectStatement);
        
        sqlite3_stmt *sqlDropTableStatement;
        if(sqlite3_prepare(diningHallDB, "DROP TABLE IF EXISTS favoritefoods", -1, &sqlDropTableStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare drop statement");
        }
        sqlite3_step(sqlDropTableStatement);
        sqlite3_finalize(sqlDropTableStatement);
        
        //check if each hall exists in db and set booleans accordingly
        
        sqlite3_stmt *sqlCreateTableStatement;
        if(sqlite3_prepare(diningHallDB, "CREATE TABLE IF NOT EXISTS favoritefoods (\"Index\" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, \"Food\" TEXT NOT NULL)", -1, &sqlCreateTableStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare create statement");
        }
        sqlite3_step(sqlCreateTableStatement);
        sqlite3_finalize(sqlCreateTableStatement);
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }

}

- (void) populateTableViewArray {
    
    NSString *tempString = @"SELECT Food FROM halls WHERE Hall = '";
    tempString = [tempString stringByAppendingString:self.hallName];
    tempString = [tempString stringByAppendingString:@"'"];
    const char *sqlStatement = [tempString cStringUsingEncoding:NSASCIIStringEncoding];
    sqlite3_stmt *sqlSelectStatement;
    @try {
        sqlite3_prepare(diningHallDB, sqlStatement, -1, &sqlSelectStatement, NULL);
        while (sqlite3_step(sqlSelectStatement) == SQLITE_ROW)
        {
            NSString *tempString =[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlSelectStatement, 0)];
            [self.favoriteFoodsTableContent addObject:tempString];
        }
        sqlite3_finalize(sqlSelectStatement);
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }
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
    
    self.favoriteFoodsTableContent = [[NSMutableArray alloc] init];
    self.itemsToAddToTable = [[NSMutableSet alloc] init];
    
    //select database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    if (sqlite3_open([writableDBPath UTF8String], &diningHallDB) == SQLITE_OK) {
        
        //populate array with food from favoritefoods
        [self populateTableViewArray];

        sqlite3_close(diningHallDB);
    }
    else {
        NSLog(@"An error opening the database has occured.");
    }
        

    
    //update favoritefoods

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.favoriteFoodsTableContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell.
    //We are configuring my cells in table view
    
    NSString *cellData = [self.favoriteFoodsTableContent objectAtIndex:indexPath.row];
	cell.textLabel.text  = cellData;
        
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If cell is not checked, check it and add item to set. Else uncheck it and remove item from set
    // MutableSet was chosen so there are no duplicate entries
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.itemsToAddToTable addObject:newCell.textLabel.text];
    }
    else {
        newCell.accessoryType = UITableViewCellAccessoryNone;
        [self.itemsToAddToTable removeObject:newCell.textLabel.text];
    }
}

@end
