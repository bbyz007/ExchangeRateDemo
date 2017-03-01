//
//  CurveView.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/14.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EXRCurveViewDelegate <NSObject>

@optional

- (void)feedbackPointYArray:(NSArray *)pointYArray;

@end

@interface EXRCurveView : UIView

@property (copy, nonatomic) NSArray *labelTitleArray;
@property (copy, nonatomic) NSArray *pointsArray;
@property (assign, nonatomic) CGFloat rateSpan;

@property (weak, nonatomic) id<EXRCurveViewDelegate> delegate;

- (void)startDrawCurve;


@end
