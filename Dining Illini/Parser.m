//
//  Parser.m
//  Dining Illini
//
//  Created by ItalianPride15 on 11/13/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import "Parser.h"
#import "TFHpple.h"
#import "sqlite3.h"
#import "Constants.h"

@interface Parser ()

- (BOOL) checkIfNeedsToParse;
- (BOOL) checkIndexBounds;
- (void) generalParseIntoArrays:(NSString *)url;
- (void) specialParseIntoArray:(NSString *)url;
- (void) parseIntoDatabase;

@end

@implementation Parser

//for use in parsing into database
NSString *hallIndex;
NSMutableArray *newRestuarants;
NSMutableArray *newBLD;
NSMutableArray *newGenCateg;
NSMutableArray *newFoods;
int restSize = 0;
int mealSize = 0;
int genCategSize = 0;
int foodSize = 0;

//for use in database manipulation
sqlite3 *diningHallsDB = NULL;

//
- (BOOL) checkIfNeedsToParse {
    
    if (hallIndex == @"Menus.aspx?RIndex=0" && buseyIsSet == NO) {
        buseyIsSet = YES;
        return YES;
    }
    if (hallIndex == @"Menus.aspx?RIndex=1" && farIsSet == NO) {
        farIsSet = YES;
        return YES;
    }
    if (hallIndex == @"Menus.aspx?RIndex=2" && ikeIsSet == NO) {
        ikeIsSet = YES;
        return YES;
    }
    if (hallIndex == @"Menus.aspx?RIndex=3" && isrIsSet == NO) {
        isrIsSet = YES;
        return YES;
    }
    if (hallIndex == @"Menus.aspx?RIndex=4" && larIsSet == NO) {
        larIsSet = YES;
        return YES;
    }
    if (hallIndex == @"Menus.aspx?RIndex=5" && parIsSet == NO) {
        parIsSet = YES;
        return YES;
    }
    return NO;
}

- (BOOL) checkIndexBounds {
    
    /*
     Index passed in the form of Menus.aspx?RIndex=...
     ..Index=0 => Busey-Evans
     ..Index=1 => FAR
     ..Index=2 => Ikenberry
     ..Index=3 => ISR
     ..Index=4 => LAR
     ..Index=5 => PAR
     */
    
    //test string input however should never be passed incorrectly
    if (hallIndex != @"Menus.aspx?RIndex=0" & hallIndex != @"Menus.aspx?RIndex=1" & hallIndex != @"Menus.aspx?RIndex=2" & hallIndex != @"Menus.aspx?RIndex=3" & hallIndex != @"Menus.aspx?RIndex=4" & hallIndex != @"Menus.aspx?RIndex=5") {
        return NO;
    }
    else {
        return YES;
    }
}

- (void) generalParseIntoArrays:(NSString *)url {
    
    //get raw page source data
    NSURL *diningHallUrl = [NSURL URLWithString:url];
    NSData *diningHallHtmlData = [NSData dataWithContentsOfURL:diningHallUrl]; //CHANGE dataWithContentsOfURL -- this call blocks until data is received!
    
    //create the hpple general parser (this is an Objective-C wrapper for libxml2 html parser)
    TFHpple *generalParser = [TFHpple hppleWithHTMLData:diningHallHtmlData];
    
    //parse first level of data (the dining hall's restuarants)
    NSString *diningHallXpathQueryString = @"//div[@id='menuchooser']/h2/span";
    NSArray *menuNodes = [generalParser searchWithXPathQuery:diningHallXpathQueryString];
    
    newRestuarants = [[NSMutableArray alloc] initWithCapacity:0];
    restSize = 0;
    for (TFHppleElement *element in menuNodes) {
        
        [newRestuarants addObject:[[element firstChild] content]];
        restSize++;
        
    }
    //NSLog(@"%@", newRestuarants);
    
    //parse second level of data (breakfast, lunch, and dinner for each restuarant)
    diningHallXpathQueryString = @"//ul[@class='menus']/li/h2/span";
    menuNodes = [generalParser searchWithXPathQuery:diningHallXpathQueryString];
    
    newBLD = [[NSMutableArray alloc] initWithCapacity:0];
    mealSize = 0;
    for (TFHppleElement *element in menuNodes) {
        
        [newBLD addObject:[[element firstChild] content]];
        mealSize++;
        
    }
    //NSLog(@"%@", newBLD);
    
    //parse third level of data (general food categories)
    diningHallXpathQueryString = @"//ul[@class='menus']/li/p/b";
    menuNodes = [generalParser searchWithXPathQuery:diningHallXpathQueryString];
    
    newGenCateg = [[NSMutableArray alloc] initWithCapacity:0];
    genCategSize = 0;
    for (TFHppleElement *element in menuNodes) {
        
        [newGenCateg addObject:[[element firstChild] content]];
        genCategSize++;
        
    }
    //NSLog(@"%@", newGenCateg);
}

- (void) specialParseIntoArray:(NSString *)url {
    
    //get raw page source data
    NSData *htmlDataString = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]] dataUsingEncoding:NSUTF8StringEncoding];
    //create the hpple special parser (this is an Objective-C wrapper for libxml2 html parser)
    TFHpple *specialFoodParser = [[TFHpple alloc] initWithHTMLData:htmlDataString];
    
    //parse fourth level of data (all foods for each general category)
    NSString *diningHallXpathQueryString = @"//ul[@class='menus']/li/p/text()";
    NSArray *menuNodes = [specialFoodParser searchWithXPathQuery:diningHallXpathQueryString];
    
    newFoods = [[NSMutableArray alloc] initWithCapacity:0];
    int i = 0;
    foodSize = 0;
    for (TFHppleElement *element in menuNodes) {
        TFHppleElement *element = [menuNodes objectAtIndex:i];
        [newFoods addObject:[element content]];
        foodSize++;
        i++;
    }
    //NSLog(@"%@", newFoods);
    
}

- (void) parseIntoDatabase {
    
    //create url
    NSString *url = @"http://www.housing.illinois.edu/Current/Dining/";
    url = [url stringByAppendingString:hallIndex];
    
    //general parser
    [self generalParseIntoArrays:(url)];
    
    //special parse
    [self specialParseIntoArray:(url)];

    /*
     The following stores the parsed data in a SQLite database with a table formatted like such:
     CREATE TABLE "halls" ("ID" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "Food" TEXT, "Category" TEXT, "Meal" TEXT, "Restaurant" TEXT, "Hall" TEXT, "Date" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP)
     The four parsed arrays are used to construct the table entries in the following way:
     1st restaurant => 1st meal => 1st gen category => all foods
     all foods is a string that is then split into each individual food and added to the table with all parent tags
     1st restaurant => 1st meal => 2st gen category => all foods
     when "<<" is detected this means that we have reached the end of the meal
     1st restaurant => 2st meal => 1st gen category => all foods
     2st restaurant => 1st meal => 1st gen category => all foods
     ...and so on
     */
    
    //keep track of next object needed using index
    int restIndex = 0;
    int mealIndex = 0;
    int genCategIndex = 0;
    int foodIndex = 0;
    
    //flag to know when to change meals
    BOOL nextMeal = NO;
    
    NSString *hall = NULL;
    
    //All halls except for Ikenberry and PAR only have one restaurant (themselves) so these two need to be fixed
    if ([[newRestuarants objectAtIndex:0] isEqualToString:@"Ikenberry"]) {
        restIndex++;
        hall = @"Ikenberry";
    }
    if ([[newRestuarants objectAtIndex:0] isEqualToString:@"PAR"]) {
        restIndex++;
        hall = @"PAR";
    }

    for (NSString *foodElement in newFoods) {

        //break if any index out of bounds
        if (restIndex >= restSize) {
            break;
        }
        if (mealIndex >= mealSize) { 
            break;
        }
        if (genCategIndex >= genCategSize) { 
            break;
        }
        if (foodIndex >= foodSize) {
            break;
        }
        
        //set and format hall, restaurant, meal, and genCat names
        if (hall == NULL) {
            hall = [newRestuarants objectAtIndex:restIndex];
        }

        NSString *restaurant = [newRestuarants objectAtIndex:restIndex];
        restaurant = [restaurant stringByReplacingOccurrencesOfString:@":" withString:@""];
        restaurant = [restaurant stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *meal = [newBLD objectAtIndex:mealIndex];
        meal = [meal stringByReplacingOccurrencesOfString:@":" withString:@""];
        meal = [meal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *genCat = [newGenCateg objectAtIndex:genCategIndex];
        genCat = [genCat stringByReplacingOccurrencesOfString:@":" withString:@""];
        genCat = [genCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *food = [newFoods objectAtIndex:foodIndex]; //food needs to be formated after string is broken up

        //split up string into individual elements
        if ([food rangeOfString:@">>"].location != NSNotFound) { //or ==0 if found
            nextMeal = YES;
        }
        
        //format food
        food = [food stringByReplacingOccurrencesOfString:@":" withString:@""];
        food = [food stringByReplacingOccurrencesOfString:@">>" withString:@""];
        food = [food stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSArray *splitString = [food componentsSeparatedByString:@", "];
        
        //add each element to SQLite table
        for (NSString *splitElement in splitString) {     

            //INSERT INTO "halls" ("Food", "Category", "Meal", "Restaurant", "Hall") VALUES (splitElement, genCat, meal, restuarant, hall);
            sqlite3_stmt *compiledInsertStatement;
            
            @try {
                if(sqlite3_prepare(diningHallsDB, sqlInsertStatement, -1, &compiledInsertStatement, NULL) == SQLITE_OK)    {
                    sqlite3_bind_text(compiledInsertStatement, 1, [splitElement UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(compiledInsertStatement, 2, [genCat UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(compiledInsertStatement, 3, [meal UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(compiledInsertStatement, 4, [restaurant UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(compiledInsertStatement, 5, [hall UTF8String], -1, SQLITE_TRANSIENT);
                }
                if(sqlite3_step(compiledInsertStatement) != SQLITE_DONE ) {
                    NSLog(@"Save Error: %s", sqlite3_errmsg(diningHallsDB));
                }
                sqlite3_finalize(compiledInsertStatement);
            }
            @catch (NSException *e) {
                NSLog(@"Exception: %@", e);
            }
        }
        
        //check to see if move to next restaurant
        if (mealIndex + 1 < mealSize && nextMeal) {
            if ([meal isEqualToString:@"After Dark Late Dinner"]) {
                restIndex++;
            }
            NSString *nextMealElement = [newBLD objectAtIndex:mealIndex + 1];
            nextMealElement = [nextMealElement stringByReplacingOccurrencesOfString:@":" withString:@""];
            nextMealElement = [nextMealElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([meal isEqualToString:@"Lunch"] && [nextMealElement isEqualToString:@"Breakfast"]) {
                restIndex++;
            }
            if ([meal isEqualToString:@"Lunch"] && [nextMealElement isEqualToString:@"Lunch"]) {
                restIndex++;
            }
            if ([meal isEqualToString:@"Breakfast"] && [nextMealElement isEqualToString:@"Breakfast"]) {
                restIndex++;
            }
            if ([meal isEqualToString:@"Dinner"] && ![nextMealElement isEqualToString:@"After Dark Late Dinner"]) {
                restIndex++;
            }
        }
        
        //move to next meal if >> was detected
        if (nextMeal == YES) {
            mealIndex++;
            nextMeal = NO;
        }
        
        genCategIndex++;
        foodIndex++;
    }
}


- (BOOL)loadDiningHallData:(NSString *)hallID {
    
    //select database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dininghalls.sqlite3"];
    if (sqlite3_open([writableDBPath UTF8String], &diningHallsDB) == SQLITE_OK) {
        
        hallIndex = hallID;
        
        //sanity check for index bounds (should never be wrong)
        if ([self checkIndexBounds] == NO) {
            return NO;
        }

        if ([self checkIfNeedsToParse]) {
            [self parseIntoDatabase];
        }
              
        sqlite3_close(diningHallsDB);        
    }
    else {
        //if we received an error, we log it and let the program continue.
        NSLog(@"An error opening the database has occured.");
        return NO;
    }
    return YES;
}

@end
