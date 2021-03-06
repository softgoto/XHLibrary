//
//  RWKnobControl.m
//  KnobControl
//
//  Created by xuhui on 16/3/16.
//  Copyright © 2016年 RayWenderlich. All rights reserved.
//

#import "RWKnobControl.h"
#import "RWKnobRenderer.h"
#import "RWRotationGestureRecognizer.h"

@implementation RWKnobControl
{
    RWKnobRenderer *_knobRenderer;
    RWRotationGestureRecognizer *_gestureRecognizer;
}

@dynamic lineWidth;
@dynamic startAngle;
@dynamic endAngle;
@dynamic pointerLength;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _minimumValue = 0.0;
        _maximumValue = 1.0;
        _value = 0.0;
        _continuous = YES;
        
        _gestureRecognizer = [[RWRotationGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleGesture:)];
        [self addGestureRecognizer:_gestureRecognizer];
        
        [self createKnobUI];
    }
    return self;
}

- (void)createKnobUI
{
    _knobRenderer = [[RWKnobRenderer alloc] init];
    [_knobRenderer updateWithBounds:self.bounds];
    _knobRenderer.color = self.tintColor;
    // Set some defaults
    _knobRenderer.startAngle = -M_PI * 11 / 8.0;
    _knobRenderer.endAngle = M_PI * 3 / 8.0;
    _knobRenderer.pointerAngle = _knobRenderer.startAngle;
    _knobRenderer.lineWidth = 2.0;
    _knobRenderer.pointerLength = 6.0;
    // Add the layers
    [self.layer addSublayer:_knobRenderer.trackLayer];
    [self.layer addSublayer:_knobRenderer.pointerLayer];
}

- (void)handleGesture:(RWRotationGestureRecognizer *)gesture
{
    // 1. Mid-point angle
    CGFloat midPointAngle = (2 * M_PI + self.startAngle - self.endAngle) / 2
    + self.endAngle;
    
    // 2. Ensure the angle is within a suitable range
    CGFloat boundedAngle = gesture.touchAngle;
    if(boundedAngle > midPointAngle) {
        boundedAngle -= 2 * M_PI;
    } else if (boundedAngle < (midPointAngle - 2 * M_PI)) {
        boundedAngle += 2 * M_PI;
    }
    // 3. Bound the angle to within the suitable range
    boundedAngle = MIN(self.endAngle, MAX(self.startAngle, boundedAngle));
    
    // 4. Convert the angle to a value
    CGFloat angleRange = self.endAngle - self.startAngle;
    CGFloat valueRange = self.maximumValue - self.minimumValue;
    CGFloat valueForAngle = (boundedAngle - self.startAngle) / angleRange
    * valueRange + self.minimumValue;
    
    // 5. Set the control to this value
    self.value = valueForAngle;
    
    // Notify of value change
    if (self.continuous) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else {
        // Only send an update if the gesture has completed
        if(_gestureRecognizer.state == UIGestureRecognizerStateEnded
           || _gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

#pragma mark - API Methods
- (void)setValue:(CGFloat)value animated:(BOOL)animated
{
    if(value != _value) {
        [self willChangeValueForKey:@"value"];
        // Save the value to the backing ivar
        // Make sure we limit it to the requested bounds
        _value = MIN(self.maximumValue, MAX(self.minimumValue, value));
        
        // Now let's update the knob with the correct angle
        CGFloat angleRange = self.endAngle - self.startAngle;
        CGFloat valueRange = self.maximumValue - self.minimumValue;
        CGFloat angleForValue = (_value - self.minimumValue) / valueRange * angleRange + self.startAngle;
        [_knobRenderer setPointerAngle:angleForValue animated:animated];
        [self didChangeValueForKey:@"value"];
    }
}

#pragma mark - Property overrides
- (void)setValue:(CGFloat)value
{
    // Chain with the animation method version
    [self setValue:value animated:NO];
}

- (void)tintColorDidChange
{
    _knobRenderer.color = self.tintColor;
}

- (CGFloat)lineWidth
{
    return _knobRenderer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _knobRenderer.lineWidth = lineWidth;
}

- (CGFloat)startAngle
{
    return _knobRenderer.startAngle;
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _knobRenderer.startAngle = startAngle;
}

- (CGFloat)endAngle
{
    return _knobRenderer.endAngle;
}

- (void)setEndAngle:(CGFloat)endAngle
{
    _knobRenderer.endAngle = endAngle;
}

- (CGFloat)pointerLength
{
    return _knobRenderer.pointerLength;
}

- (void)setPointerLength:(CGFloat)pointerLength
{
    _knobRenderer.pointerLength = pointerLength;
}

@end
