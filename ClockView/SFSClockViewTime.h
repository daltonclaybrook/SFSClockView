//
//  SFSClockViewTime.h
//  ClockView
//
//  Created by Dalton Claybrook on 1/7/15.
//  Copyright (c) 2015 claybrooksoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    CGFloat hours;
    CGFloat minutes;
} SFSClockViewTime;

static inline SFSClockViewTime SFSClockViewTimeMake(CGFloat hours, CGFloat minutes) {
    SFSClockViewTime time;
    time.hours = hours;
    time.minutes = minutes;
    return time;
};

static inline SFSClockViewTime SFSClockViewTimeMakeWithDate(NSDate *date) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    return SFSClockViewTimeMake(components.hour, components.minute);
}

static inline BOOL SFSClockTimeEqual(SFSClockViewTime time1, SFSClockViewTime time2) {
    return ((fabsf(time1.hours - time2.hours) < FLT_EPSILON) &&
            (fabsf(time1.minutes - time2.minutes) < FLT_EPSILON));
};