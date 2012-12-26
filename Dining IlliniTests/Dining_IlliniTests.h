//
//  Dining_IlliniTests.h
//  Dining IlliniTests
//
//  Created by ItalianPride15 on 11/13/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface Dining_IlliniTests : SenTestCase

- (void)testParserBadInputString;

- (void)testParserBadInputIndex;

- (void)testParserGoodInput;

- (void)testDatabaseStartup;

- (void)testParsedSpecificHall;

- (void)testMultipleParsedHalls;

- (void)testCreatedAllTables;

@end
