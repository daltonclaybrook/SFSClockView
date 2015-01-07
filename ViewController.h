//
//  ViewController.h
//  ClockView
//
//  Created by Dalton Claybrook on 1/6/15.
//  Copyright (c) 2015 claybrooksoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSClockView.h"

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet SFSClockView *clockView;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

- (IBAction)timeButtonPressed:(UIButton *)sender;

@end

