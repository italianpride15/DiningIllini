//
//  DisplayFoodViewController.m
//  Dining Illini
//
//  Created by ItalianPride15 on 12/3/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import "DisplayFoodViewController.h"
#import "AddFoodTableViewController.h"
#import "FormatString.h"

@interface DisplayFoodViewController ()

@end

@implementation DisplayFoodViewController

@synthesize displayData = _displayData;
@synthesize hallTitle = _hallTitle;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"AddFoodSegueIdentifier"])
    {
        AddFoodTableViewController *favoriteFoodTableView = [segue destinationViewController];
    
        [favoriteFoodTableView setHallName:self.hallTitle];
        
        /*
        AddFoodTableViewController *detailViewController = [[AddFoodTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [detailViewController setHallName:self.hallTitle];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];

        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navController animated:YES];
         */
         
    }
}

- (NSString *) displayDiningHallData:(NSString *)hallIndex {
    
    FormatString *displayText = NULL;
    displayText = [[FormatString alloc] init];
    NSString *returnString = [displayText getFormattedText:hallIndex:self.hallTitle];
    displayText = NULL;
    return returnString;
    //self.displayData.text = [hall getSqlText];
}

- (void) viewDidLoad {
    
    [super viewDidLoad];

    //maybe set orientation?
    [self setTitle:self.hallTitle];
}

@end
