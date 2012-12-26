//
//  Dining_IlliniTests.m
//  Dining IlliniTests
//
//  Created by ItalianPride15 on 11/13/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import "Dining_IlliniTests.h"
#import "Parser.h"
#import "Databaseload.h"
#import "AddFoodTableViewController.h"
#import "FormatString.h"
#import "sqlite3.h"

@implementation Dining_IlliniTests

- (void)testParserBadInputString {
    
    FormatString *displayText;
    displayText = [[FormatString alloc] init];
    
    NSString *testString = [displayText getFormattedText:@"imabadstring":@"imabadstring"];
    assert(testString == @"");
}

- (void)testParserBadInputIndex {

    FormatString *displayText;
    displayText = [[FormatString alloc] init];
    
    NSString *testString = [displayText getFormattedText:@"Menus.aspx?RIndex=6":@"PAR"];
    assert(testString == @"");
}


- (void)testParserGoodInput {
    
    FormatString *displayText;
    displayText = [[FormatString alloc] init];
    
    NSString *testString = [displayText getFormattedText:@"Menus.aspx?RIndex=3":@"ISR"];
    
    if(testString != @"") {
        assert(YES);
    }
    else {
        assert(NO);
    }
}

- (void)testDatabaseStartup {
    
    Databaseload *database;
    database = [[Databaseload alloc] init];
    
    assert([database createEditableCopyOfDatabaseIfNeeded]);
}


- (void)testCreatedAllTables {
    
    Databaseload *testDBLoad;
    testDBLoad = [[Databaseload alloc] init];
    
    [testDBLoad createEditableCopyOfDatabaseIfNeeded];
    
    sqlite3 *testDB = NULL;
    NSInteger testInt = 0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    if (sqlite3_open([writableDBPath UTF8String], &testDB) == SQLITE_OK) {
        
        sqlite3_stmt *sqlStatement;
        if(sqlite3_prepare(testDB, "SELECT Count(*) FROM sqlite_master", -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare drop statement");
        }
        if (sqlite3_step(sqlStatement) == SQLITE_ROW) {
            testInt = sqlite3_column_int(sqlStatement, 0);
        }
        sqlite3_finalize(sqlStatement);
        sqlite3_close(testDB);
    }
    assert(testInt == 5);
}

- (void)testParsedSpecificHall {
    
    FormatString *displayText;
    displayText = [[FormatString alloc] init];
    
    [displayText getFormattedText:@"Menus.aspx?RIndex=5":@"PAR"];
    
    sqlite3 *testDB = NULL;
    NSString * tempString = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    if (sqlite3_open([writableDBPath UTF8String], &testDB) == SQLITE_OK) {
        
        sqlite3_stmt *sqlStatement;
        sqlite3_prepare(testDB, "SELECT Food FROM halls WHERE Hall = 'PAR'", -1, &sqlStatement, NULL);
        if (sqlite3_step(sqlStatement) == SQLITE_ROW)
        {
            tempString =[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlStatement, 0)];
        }
        sqlite3_finalize(sqlStatement);
        sqlite3_close(testDB);
    }
    
    if (tempString != @"") {
        assert(YES);
    }
    else {
        assert(NO);
    }
}

- (void)testMultipleParsedHalls {
    
    FormatString *displayText;
    displayText = [[FormatString alloc] init];
    
    [displayText getFormattedText:@"Menus.aspx?RIndex=5":@"PAR"];
    
    sqlite3 *testDB = NULL;
    NSString * tempStringPAR = @"";
    NSString * tempStringLAR = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    if (sqlite3_open([writableDBPath UTF8String], &testDB) == SQLITE_OK) {
        
        sqlite3_stmt *sqlStatementPAR;
        sqlite3_prepare(testDB, "SELECT Food FROM halls WHERE Hall = 'PAR'", -1, &sqlStatementPAR, NULL);
        if (sqlite3_step(sqlStatementPAR) == SQLITE_ROW)
        {
            tempStringPAR =[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlStatementPAR, 0)];
        }
        sqlite3_finalize(sqlStatementPAR);
        
        [displayText getFormattedText:@"Menus.aspx?RIndex=4":@"LAR"];

        sqlite3_stmt *sqlStatementLAR;
        sqlite3_prepare(testDB, "SELECT Food FROM halls WHERE Hall = 'LAR'", -1, &sqlStatementLAR, NULL);
        if (sqlite3_step(sqlStatementLAR) == SQLITE_ROW)
        {
            tempStringLAR =[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlStatementLAR, 0)];
        }
        sqlite3_finalize(sqlStatementLAR);
        sqlite3_close(testDB);
    }
        
    if (tempStringPAR != @"" && tempStringLAR != @"") {
        assert(YES);
    }
    else {
        assert(NO);
    }
    
}

@end
