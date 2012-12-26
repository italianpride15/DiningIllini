//
//  DisplayFoodViewController.h
//  Dining Illini
//
//  Created by ItalianPride15 on 12/3/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayFoodViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *displayData;
@property (nonatomic) NSString *hallTitle;

- (NSString *) displayDiningHallData:(NSString *)hallIndex;

@end
