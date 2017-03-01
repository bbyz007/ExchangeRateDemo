//
//  HistoricalService.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/15.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EXRate;

@interface EXRHistoricalService : NSObject

+ (void)getDefualtCurrenciesHistoricalExchangeRate;

+ (void)getDateOfCurrency:(NSString *)abbreviation WithEndDate:(NSDate *)endDate withTimeInterval:(NSTimeInterval)timeInterval withCompletionHandler:(void (^)(NSArray<EXRate *> *, NSTimeInterval))completionHandler withFailedHandler:(void (^)(NSString *, NSTimeInterval))failedHandler;

+ (EXRate *)getCurrentRateWithLocaCurrency:(NSString *)localCurrency withExchangeCurrency:(NSString *)exchangeCurrency withDate:(NSString *)toDate;

+ (void)updateCurrency:(NSString *)abbreviation withDataArray:(NSArray<EXRate *> *)dataArray;

+ (void)changeCurrency:(NSString *)abbreviation;

+ (void)resetCurrency:(NSString *)abbreviation;

@end
