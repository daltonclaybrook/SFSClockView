//
//  ViewController.m
//  ClockView
//
//  Created by Dalton Claybrook on 1/6/15.
//  Copyright (c) 2015 claybrooksoftware. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.datePicker.date = [NSDate date];
    [self timeButtonPressed:nil];
}

- (IBAction)timeButtonPressed:(UIButton *)sender
{
    SFSClockViewTime time = SFSClockViewTimeMakeWithDate(self.datePicker.date);
    
    [self.clockView setTime:time animated:YES];
}

@end
