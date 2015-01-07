//
//  SFSClockView.h
//  ClockView
//
//  Created by Dalton Claybrook on 1/6/15.
//  Copyright (c) 2015 claybrooksoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSClockViewTime.h"

@interface SFSClockView : UIView

@property (nonatomic, assign, readonly) SFSClockViewTime time;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat strokeWidth;

- (void)setTime:(SFSClockViewTime)time animated:(BOOL)animated;

@end
