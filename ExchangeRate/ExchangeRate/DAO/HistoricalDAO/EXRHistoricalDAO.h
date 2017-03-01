//
//  HistoricalDAO.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/17.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class EXRate;

@interface EXRHistoricalDAO : NSObject

+ (NSString *)queryDateNeedToUpdateWithIndex:(NSInteger)index;

+ (void)updateHistoricalData:(NSArray<EXRate *> *)dataArray withIndex:(NSInteger)index;

+ (BOOL)deleteDateOfIndex:(NSInteger)index;

+ (void)getDataWithEndDate:(NSDate *)endDate withFromDate:(NSDate *)fromDate withIndex:(NSInteger)index withCompletionBlock:(void (^)(NSArray<EXRate *> *, BOOL, BOOL))completion;

+ (BOOL)haveDataWithEndDate:(NSDate *)endDate withTimeInterval:(NSTimeInterval)time withIndex:(NSInteger)index;

@end
