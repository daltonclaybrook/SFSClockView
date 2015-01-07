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
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.datePicker.date];
    
    SFSClockViewTime time = SFSClockViewTimeMake(components.hour, components.minute);
    [self.clockView setTime:time animated:YES];
}

@end
