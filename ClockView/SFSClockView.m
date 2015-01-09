//
//  SFSClockView.m
//  ClockView
//
//  Created by Dalton Claybrook on 1/6/15.
//  Copyright (c) 2015 claybrooksoftware. All rights reserved.
//

#import "SFSClockView.h"

static NSString * const kHourHandAnimationKey = @"kHourHandAnimationKey";
static NSString * const kMinuteHandAnimationKey = @"kMinuteHandAnimationKey";

static CGFloat const kMinAnimationDuration = 0.4f;
static CGFloat const kMaxAnimationDuration = 2.0f;

static CGFloat const kDefaultStrokeWidth = 4.0f;

static CGFloat const kHourHandLengthMultiplier = 0.5f;
static CGFloat const kMinuteHandLengthMultiplier = 0.8f;

@interface SFSClockView ()

@property (nonatomic, strong) CAShapeLayer *hourHand;
@property (nonatomic, strong) CAShapeLayer *minuteHand;

@end

@implementation SFSClockView

#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self SFSClockViewCommonInit];
    }
    return self;
}

- (void)SFSClockViewCommonInit
{
    _color = [UIColor blackColor];
    _strokeWidth = kDefaultStrokeWidth;
    
    _minimumAnimationDuration = kMinAnimationDuration;
    _maximumAnimationDuration = kMaxAnimationDuration;
    
    [self refreshHands];
}

#pragma mark - Superclass

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    [self refreshHands];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat dimentions = MIN(CGRectGetWidth(self.bounds)-self.strokeWidth, CGRectGetHeight(self.bounds)-self.strokeWidth);
    CGRect clockRect = CGRectMake((CGRectGetWidth(self.bounds)-dimentions)/2.0f, (CGRectGetHeight(self.bounds)-dimentions)/2.0f, dimentions, dimentions);
//    CGRect dotRect = CGRectMake(CGRectGetMidX(clockRect)-self.strokeWidth, CGRectGetMidY(clockRect)-self.strokeWidth, self.strokeWidth*2.0f, self.strokeWidth*2.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self.color CGColor]);
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, self.strokeWidth);
    
    CGContextStrokeEllipseInRect(context, clockRect);
//    CGContextFillEllipseInRect(context, dotRect);
}

#pragma mark - Public

- (void)setTime:(SFSClockViewTime)time animated:(BOOL)animated
{
    if (SFSClockTimeEqual(_time, time))
    {
        return;
    }
    [self setTime:time fromCurrentTime:_time animated:animated];
}

#pragma mark - Private

- (void)setTime:(SFSClockViewTime)time fromCurrentTime:(SFSClockViewTime)current animated:(BOOL)animated
{
    _time = time;
    
    SFSClockViewTime adjustedTime = [self adjustedStartTimeToTime:time fromTime:current];
    CGFloat fromHourRadians = [self hourRadiansFromHours:adjustedTime.hours minutes:adjustedTime.minutes];
    CGFloat fromMinuteRadians = [self minuteRadiansFromHours:adjustedTime.hours minutes:adjustedTime.minutes];
    
    CGFloat toHourRadians = [self hourRadiansFromHours:time.hours minutes:time.minutes];
    CGFloat toMinuteRadians = [self minuteRadiansFromHours:time.hours minutes:time.minutes];
    
    CGFloat distance = fabsf(toHourRadians - fromHourRadians);
    CGFloat animationModifier = distance / M_PI;
    CGFloat duration = ((self.maximumAnimationDuration - self.minimumAnimationDuration) * animationModifier) + kMinAnimationDuration;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CABasicAnimation *hourAnimation = [self createAnimationToRadians:toHourRadians fromRadians:fromHourRadians];
    CABasicAnimation *minuteAnimation = [self createAnimationToRadians:toMinuteRadians fromRadians:fromMinuteRadians];
    
    [self.hourHand addAnimation:hourAnimation forKey:kHourHandAnimationKey];
    [self.minuteHand addAnimation:minuteAnimation forKey:kMinuteHandAnimationKey];
    
    [CATransaction commit];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.hourHand.transform = CATransform3DMakeRotation(toHourRadians, 0, 0, 1);
    self.minuteHand.transform = CATransform3DMakeRotation(toMinuteRadians, 0, 0, 1);
    
    [CATransaction commit];
}

- (SFSClockViewTime)adjustedStartTimeToTime:(SFSClockViewTime)targetTime fromTime:(SFSClockViewTime)fromTime
{
    SFSClockViewTime closest = fromTime;
    CGFloat totalMinutes = 60 * 12;
    CGFloat time1 = targetTime.hours * 60.0f + targetTime.minutes;
    CGFloat time2 = fromTime.hours * 60.0f + fromTime.minutes;
    
    if (fabsf(time1 - time2) > totalMinutes/2.0f)
    {
        CGFloat multiplier = (time2 < time1) ? 1.0f : -1.0f;
        
        while ((fabsf(time1 - time2) > totalMinutes/2.0f) && (time))
        {
            time2 += (totalMinutes * multiplier);
        }
        
        CGFloat hours = floorf(time2/60.0f);
        CGFloat minutes = time2-(hours*60.0f);
        closest = SFSClockViewTimeMake(hours, minutes);
    }
    
    return closest;
}

- (CABasicAnimation *)createAnimationToRadians:(CGFloat)toRadians fromRadians:(CGFloat)fromRadians
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(fromRadians);
    animation.toValue = @(toRadians);
    return animation;
}

- (void)refreshHands
{
    [self removeHandsIfNecessary];
    
    CGRect hourRect = [self handRectWithMultiplier:kHourHandLengthMultiplier];
    CGRect minuteRect = [self handRectWithMultiplier:kMinuteHandLengthMultiplier];
    
    UIBezierPath *hourPath = [UIBezierPath bezierPath];
    [hourPath moveToPoint:CGPointMake(CGRectGetWidth(hourRect)/2.0f, CGRectGetWidth(hourRect)/2.0f)];
    [hourPath addLineToPoint:CGPointMake(CGRectGetWidth(hourRect)/2.0f, 0.0f)];
    
    UIBezierPath *minutePath = [UIBezierPath bezierPath];
    [minutePath moveToPoint:CGPointMake(CGRectGetWidth(minuteRect)/2.0f, CGRectGetWidth(minuteRect)/2.0f)];
    [minutePath addLineToPoint:CGPointMake(CGRectGetWidth(minuteRect)/2.0f, 0.0f)];
    
    self.hourHand = [self createHandWithPath:hourPath frame:hourRect];
    self.minuteHand = [self createHandWithPath:minutePath frame:minuteRect];
    
    [self.layer addSublayer:self.hourHand];
    [self.layer addSublayer:self.minuteHand];
}

- (CGRect)handRectWithMultiplier:(CGFloat)multiplier
{
    CGFloat dimentions = MIN(CGRectGetWidth(self.bounds) * multiplier, CGRectGetHeight(self.bounds) * multiplier);
    
     return CGRectMake((CGRectGetWidth(self.bounds)-dimentions)/2.0f, (CGRectGetHeight(self.bounds)-dimentions)/2.0f, dimentions, dimentions);
}

- (CAShapeLayer *)createHandWithPath:(UIBezierPath *)path frame:(CGRect)rect
{
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.lineWidth = self.strokeWidth;
    shape.strokeColor = [self.color CGColor];
    shape.lineCap = kCALineCapRound;
    shape.path = [path CGPath];
    shape.frame = rect;
    
    return shape;
}

- (BOOL)isAngle:(CGFloat)radians1 equalToAngle:(CGFloat)radians2
{
    CATransform3D transform1 = CATransform3DMakeRotation(radians1, 0, 0, 1);
    CATransform3D transform2 = CATransform3DMakeRotation(radians2, 0, 0, 1);
    return CATransform3DEqualToTransform(transform1, transform2);
}

- (void)removeHandsIfNecessary
{
    if (self.hourHand.superlayer)
    {
        [self.hourHand removeFromSuperlayer];
    }
    if (self.minuteHand.superlayer)
    {
        [self.minuteHand removeFromSuperlayer];
    }
}

- (CGFloat)hourRadiansFromHours:(CGFloat)hours minutes:(CGFloat)minutes
{
    CGFloat rotations = (hours/12.0f) + (minutes/60.0f/12.0f);
    
    return [self radiansFromRotations:rotations];
}

- (CGFloat)minuteRadiansFromHours:(CGFloat)hours minutes:(CGFloat)minutes
{
    CGFloat rotations = hours + (minutes/60.0f);
    
    return [self radiansFromRotations:rotations];
}

- (CGFloat)radiansFromRotations:(CGFloat)rotations
{
    return M_PI * 2.0f * rotations;
}

@end
