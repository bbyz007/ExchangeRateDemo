//
//  ChosenService.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/9.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EXRChosenService : NSObject

+ (void)getCurrenciesWithCompletionHandler:(void (^)(NSArray *currencies, NSArray *sections))completionHandler;

+ (void)updateCommonCurrencies:(NSString *)abbreviation;

+ (void)updateDefaultCurrencies:(NSString *)previous withNew:(NSString *)abbreviation;

@end
