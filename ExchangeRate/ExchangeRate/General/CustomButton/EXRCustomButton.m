//
//  CustomButton.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/20.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCustomButton.h"

@implementation EXRCustomButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = self.bounds;
    rect = CGRectInset(rect, -20, -10);
    return CGRectContainsPoint(rect, point);
}


@end
