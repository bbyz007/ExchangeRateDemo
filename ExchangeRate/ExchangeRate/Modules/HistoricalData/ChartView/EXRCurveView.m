//
//  CurveView.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/14.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurveView.h"

static const CGFloat curveAnimateDuration = 2.0f;
static const CGFloat shadowOffsetY = 20.0f;

@interface EXRCurveView ()

@property (strong, nonatomic) UIBezierPath *path;
@property (strong, nonatomic) UIBezierPath *shadowPath;

@property (copy, nonatomic) NSArray *pointYArray;

@end

@implementation EXRCurveView


- (void)startDrawCurve {
    
    CAShapeLayer *shadow = [[CAShapeLayer alloc] init];
    shadow.path = self.shadowPath.CGPath;
    shadow.fillColor = [UIColorFromRGB(0X455064) colorWithAlphaComponent:0.7].CGColor;
    [self.layer addSublayer:shadow];
    
    CAGradientLayer *shadowMask = [CAGradientLayer layer];
    shadowMask.frame = CGRectMake(0, 0, self.frame.size.width - 1, self.frame.size.height);
    [shadowMask setColors:@[(id)shadow.fillColor, (id)[UIColor clearColor].CGColor]];
    [shadowMask setStartPoint:CGPointMake(0, 0)];
    [shadowMask setEndPoint:CGPointMake(0, 1)];
    [self.layer addSublayer:shadowMask];
    shadow.mask = shadowMask;

    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = self.path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor blueColor].CGColor;
    layer.lineWidth = 1.5f;
    layer.lineJoin = @"round";
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.frame.size.width - 1, self.frame.size.height);
    [gradient setColors:@[(id)UIColorFromRGB(0X0C56F5).CGColor, (id)[UIColor greenColor].CGColor]];
    [gradient setStartPoint:CGPointMake(0, 0)];
    [gradient setEndPoint:CGPointMake(1, 0)];
    [self.layer addSublayer:gradient];
    gradient.mask = layer;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.duration = curveAnimateDuration;
    animation.removedOnCompletion = NO;
    [layer addAnimation:animation forKey:animation.keyPath];
    
    if (_pointYArray.count > 0) {
        if ([self.delegate respondsToSelector:@selector(feedbackPointYArray:)]) {
            [self.delegate feedbackPointYArray:_pointYArray];
        }
    }
}


#pragma mark - lazy initializaiton

- (UIBezierPath *)path {
    if (_path == nil) {
        CGRect rect = self.frame;
        CGFloat unitX = rect.size.width / (_pointsArray.count - 1);
        CGFloat unitY = rect.size.height / _rateSpan;
        CGPoint point0 = CGPointMake(-0.5, rect.size.height - [[_pointsArray firstObject] floatValue] * unitY);
        
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:@(point0.y)];
        
        self.path = [UIBezierPath bezierPath];
        [_path moveToPoint:point0];
        
        for (NSInteger index = 1; index < _pointsArray.count; index++) {
            CGFloat pointX = index * unitX;
            CGFloat pointY = rect.size.height - [_pointsArray[index] floatValue] * unitY;
            CGPoint point = CGPointMake(pointX, pointY);
            [_path addLineToPoint:point];
            [array addObject:@(pointY)];
        }
        self.pointYArray = array;
    }
    return _path;
}

- (UIBezierPath *)shadowPath {
    if (_shadowPath == nil) {
        _shadowPath = self.path;
        [_shadowPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height + shadowOffsetY)];
        [_shadowPath addLineToPoint:CGPointMake(0, self.frame.size.height + shadowOffsetY)];
        [_shadowPath closePath];
    }
    return _shadowPath;
}


@end
