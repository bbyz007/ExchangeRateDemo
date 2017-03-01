//
//  ChartView.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/12.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EXRChartViewDelegate <NSObject>

@optional

- (void)changeHistoricalPeriod:(NSInteger)timeIntevral;

@end

@interface EXRChartView : UIView

@property (copy, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) id<EXRChartViewDelegate> delegate;

- (void)convertCurrencies;
- (void)resetDataAction;

@end
