//
//  Databaseload.m
//  Dining Illini
//
//  Created by ItalianPride15 on 11/29/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import "Databaseload.h"
#import "sqlite3.h"

@interface Databaseload ()

- (void) initializeExtraFeaturesTablesIfNeeded;
- (void) initializeDatabaseForUse;

@end

@implementation Databaseload

const char *sqlCreateFavoriteFoodsTable = "CREATE TABLE IF NOT EXISTS favoritefoods (\"Index\" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, \"Food\" TEXT NOT NULL)";
const char *sqlCreateFavoriteHallsTable = "CREATE TABLE IF NOT EXISTS favoritehalls (\"Index\" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, \"Hall\" TEXT NOT NULL)";
const char *sqlCreateAllergensTable = "CREATE TABLE IF NOT EXISTS Allergens (\"Index\" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, \"Allergen\" TEXT NOT NULL)";
const char *sqlCreateTable = "CREATE TABLE IF NOT EXISTS halls (\"ID\" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, \"Food\" TEXT, \"Category\" TEXT, \"Meal\" TEXT, \"Restaurant\" TEXT, \"Hall\" TEXT, \"Date\" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP)";

sqlite3 *hallDB = NULL;

// Creates a writable copy of the bundled default database in the application Documents directory.
- (BOOL) createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) {
        if (sqlite3_open([writableDBPath UTF8String], &hallDB) == SQLITE_OK) {
            
            [self initializeDatabaseForUse];
            [self initializeExtraFeaturesTablesIfNeeded];
            sqlite3_close(hallDB);
            return YES;

        }
        else {
            NSLog(@"An error opening the database has occured.");
        }
    }
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    else {
        if (sqlite3_open([writableDBPath UTF8String], &hallDB) == SQLITE_OK) {
            
            [self initializeDatabaseForUse];
            [self initializeExtraFeaturesTablesIfNeeded];
            sqlite3_close(hallDB);
            return YES;
        }
        else {
            NSLog(@"An error opening the database has occured.");
        }
    }
    return NO;
}

- (void) initializeDatabaseForUse {
    
    BOOL dropTable = YES;
    
    /*
    //create halls table if it doesn't exist already
    sqlite3_stmt *sqlCreateTableStatement;
    if (sqlite3_prepare(hallDB, sqlCreateTable, -1, &sqlCreateTableStatement, NULL) != SQLITE_OK)
    {
        NSLog(@"Problem with prepare create statement");
    }
    sqlite3_step(sqlCreateTableStatement);
    sqlite3_finalize(sqlCreateTableStatement);
    
    //check if halls table is up-to-date.
    sqlite3_stmt *sqlCheckTableDateStatement;
    if (sqlite3_prepare(hallDB, "SELECT Date FROM halls", -1, &sqlCheckTableDateStatement, NULL) != SQLITE_OK)
    {
        NSLog(@"Problem with check table date statement");
    }
    if (sqlite3_step(sqlCheckTableDateStatement) == SQLITE_ROW)
    {
        NSString *tempString =[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlCheckTableDateStatement, 0)];
        
        //get todays date in format yyyy-MM-dd
        NSDateFormatter *formatter;
        NSString *dateString;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        dateString = [formatter stringFromDate:[NSDate date]];
        
        //if tempString is NULL then table is new and no need to drop and remake it. if tempString contains dateString then it is good. else drop table and remake it
        if (tempString == NULL) {
            dropTable = NO;
        }
        if ([tempString rangeOfString:dateString].location != NSNotFound) { //or ==0 if found
            dropTable = NO;
        }
    }
    sqlite3_finalize(sqlCheckTableDateStatement);
     */
    
    //if halls is not up-to-date (or empty), drop the table and remake it.
    if (dropTable) {
        
        sqlite3_stmt *sqlDropTableStatement;
        if(sqlite3_prepare(hallDB, "DROP TABLE IF EXISTS halls", -1, &sqlDropTableStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare drop statement");
        }
        sqlite3_step(sqlDropTableStatement);
        sqlite3_finalize(sqlDropTableStatement);
        
        //check if each hall exists in db and set booleans accordingly

        sqlite3_stmt *sqlCreateTableStatement;
        if(sqlite3_prepare(hallDB, sqlCreateTable, -1, &sqlCreateTableStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare create statement");
        }
        sqlite3_step(sqlCreateTableStatement);
        sqlite3_finalize(sqlCreateTableStatement);
    }
}

//put in try catch
- (void) initializeExtraFeaturesTablesIfNeeded {
    
    //create favoritefoods table if needed
    sqlite3_stmt *sqlTableStatement;
    if (sqlite3_prepare(hallDB, sqlCreateFavoriteFoodsTable, -1, &sqlTableStatement, NULL) != SQLITE_OK)
    {
        NSLog(@"Problem with favoritefoods statement");
    }
    sqlite3_step(sqlTableStatement);
    sqlite3_finalize(sqlTableStatement);
    
    //create favoritehalls table if needed
    if (sqlite3_prepare(hallDB, sqlCreateFavoriteHallsTable, -1, &sqlTableStatement, NULL) != SQLITE_OK)
    {
        NSLog(@"Problem with favoritehalls statement");
    }
    sqlite3_step(sqlTableStatement);
    sqlite3_finalize(sqlTableStatement);
    
    //create allergens table if needed
    if (sqlite3_prepare(hallDB, sqlCreateAllergensTable, -1, &sqlTableStatement, NULL) != SQLITE_OK)
    {
        NSLog(@"Problem with allergens statement");
    }
    sqlite3_step(sqlTableStatement);
    sqlite3_finalize(sqlTableStatement);
}

@end
