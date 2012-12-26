//
//  ViewController.m
//  Dining Illini
//
//  Created by ItalianPride15 on 11/13/12.
//  Copyright (c) 2012 npanta2. All rights reserved.
//

#import "ViewController.h"
#import "DisplayFoodViewController.h"

@interface ViewController ()

@property (nonatomic) NSString *hallIndex;
@property (nonatomic) NSString *hallName;

@end

@implementation ViewController

@synthesize hallIndex = _hallIndex;
@synthesize hallName = _hallName;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    DisplayFoodViewController *dataView = [segue destinationViewController];
    
    if ([dataView view]) {
        dataView.hallTitle = self.hallName;
        [dataView setTitle:self.hallName];
        dataView.displayData.text = [dataView displayDiningHallData:self.hallIndex];
    }
}

- (IBAction)BuseyEvans:(UIButton *)sender {

    self.hallIndex = @"Menus.aspx?RIndex=0";
    self.hallName = @"Busey-Evans";

}

- (IBAction)FAR:(UIButton *)sender {
    
    self.hallIndex = @"Menus.aspx?RIndex=1";
    self.hallName = @"FAR";

}

- (IBAction)Ikenberry:(UIButton *)sender {
    
    self.hallIndex = @"Menus.aspx?RIndex=2";
    self.hallName = @"Ikenberry";

}

- (IBAction)ISR:(UIButton *)sender {
    
    self.hallIndex = @"Menus.aspx?RIndex=3";
    self.hallName = @"ISR";
    
}

- (IBAction)LAR:(UIButton *)sender {
    
    self.hallIndex = @"Menus.aspx?RIndex=4";
    self.hallName = @"LAR";

}

- (IBAction)PAR:(UIButton *)sender {
    
    self.hallIndex = @"Menus.aspx?RIndex=5";
    self.hallName = @"PAR";

}

- (void) viewDidLoad {
    //disable rotation
}

@end
