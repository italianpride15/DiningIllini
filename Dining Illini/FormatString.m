//
//  FormatString.m
//  Dining Illini
//
//  Created by ItalianPride15 on 12/6/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import "FormatString.h"
#import "sqlite3.h"
#import "Parser.h"

@interface FormatString ()

- (NSString *) getStringByHallName:(NSString *)hallName;
- (NSString *) formatStringToBeDisplayed:(NSString *)formatString;

@end

@implementation FormatString


//temp function to display data
-(NSString *) getFormattedText:(NSString *)hallIndex:(NSString *)hallName {
    
    Parser *generalParser = NULL;
    generalParser = [[Parser alloc] init];
    
    NSString *returnString = @"";
    
    //parse the data
    if (![generalParser loadDiningHallData:hallIndex]) {
        return returnString;
    }
    
    //put all data from hallName into string
    returnString = [self getStringByHallName:hallName];
    
    //format the string for display
    //returnString = [self formatStringToBeDisplayed:returnString];
    
    generalParser = NULL;
    return returnString;
}

- (NSString *) getStringByHallName:(NSString *)hallName {
    
    NSString *returnString = @"";
    
    //get db path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    sqlite3 *diningHallDB = NULL;
    
    //compile SELECT string
    NSString *tempString = @"SELECT Food,Category,Meal,Restaurant FROM halls WHERE Hall = '";
    tempString = [tempString stringByAppendingString:hallName];
    tempString = [tempString stringByAppendingString:@"'"];
    const char *sqlSelectAllStatement = [tempString cStringUsingEncoding:NSASCIIStringEncoding];
    
    //open data base to grab rows and format text
    if (sqlite3_open([writableDBPath UTF8String], &diningHallDB) == SQLITE_OK) {
    
        NSString *tempRest;
        NSString *tempMeal;
        NSString *tempCat;
        NSString *tempFood;
        NSString *currRest = @"";
        NSString *currMeal = @"";
        NSString *currCat = @"";
        BOOL changeString = NO;


        sqlite3_stmt *sqlSelectStatement;
        @try {
            sqlite3_prepare(diningHallDB, sqlSelectAllStatement, -1, &sqlSelectStatement, NULL);
            while (sqlite3_step(sqlSelectStatement) == SQLITE_ROW)
            {
                //get each column in row
                tempRest = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlSelectStatement, 3)];
                tempMeal = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlSelectStatement, 2)];
                tempCat =  [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlSelectStatement, 1)];
                tempFood = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlSelectStatement, 0)];
                
                //only used to set initial curr variables (runs once)
                if (currRest == @"") {
                    currRest = tempRest;
                    
                    if (currMeal == @"") {
                        currMeal = tempMeal;
                        
                        if (currCat == @"") {
                            currCat = tempCat;
                            
                            returnString = [returnString stringByAppendingString:tempRest];
                            returnString = [returnString stringByAppendingString:@" => "];
                            returnString = [returnString stringByAppendingString:tempMeal];
                            returnString = [returnString stringByAppendingString:@" => "];
                            returnString = [returnString stringByAppendingString:tempCat];
                            returnString = [returnString stringByAppendingString:@": \n"];
                        }
                    }
                }
                
                //each loop, find if there is a change to one of the variables and update the current directory string
                if ([currRest rangeOfString:tempRest].location == NSNotFound) {
                    currRest = tempRest;
                    changeString = YES;
                }
                if ([currMeal rangeOfString:tempMeal].location == NSNotFound) {
                    currMeal = tempMeal;
                    changeString = YES;
                }
                if ([currCat rangeOfString:tempCat].location == NSNotFound) {
                    currCat = tempCat;
                    changeString = YES;
                }
                if (changeString) {
                    returnString = [returnString stringByAppendingString:@"\n"];
                    returnString = [returnString stringByAppendingString:@"\n"];
                    returnString = [returnString stringByAppendingString:tempRest];
                    returnString = [returnString stringByAppendingString:@" => "];
                    returnString = [returnString stringByAppendingString:tempMeal];
                    returnString = [returnString stringByAppendingString:@" => "];
                    returnString = [returnString stringByAppendingString:tempCat];
                    returnString = [returnString stringByAppendingString:@": \n"];
                    changeString = NO;
                }
                //format food in each string directory
                if ([currRest rangeOfString:tempRest].location != NSNotFound && [currMeal rangeOfString:tempMeal].location != NSNotFound && [currCat rangeOfString:tempCat].location != NSNotFound) {
                    returnString = [returnString stringByAppendingString:tempFood];
                    returnString = [returnString stringByAppendingString:@", "];
                }
            }
            sqlite3_finalize(sqlSelectStatement);
        }
        @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
    }
    else {
        //if we received an error, we log it and let the program continue.
        NSLog(@"An error opening the database has occured.");
        return @"";
    }
    //NSLog(returnString);
    return returnString;
}

- (NSString *) formatStringToBeDisplayed:(NSString *)formatString {
    
}

@end
