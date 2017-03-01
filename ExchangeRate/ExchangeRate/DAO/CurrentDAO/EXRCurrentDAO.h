//
//  CurrentDAO.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/7.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EXRCurrentDAO : NSObject

+ (void)insertCurrentExchangeRate:(NSDictionary *)dic withPath:(NSString *)path;

+ (NSArray *)getDefaultCurrencies:(NSString *)path;

+ (NSArray *)getCommonCurrencies:(NSString *)path;

+ (NSString *)getExchangeRate:(NSString *)abbreviation withPath:(NSString *)path;

+ (void)updateCommonCurrencies:(NSString *)abbreviation withPath:(NSString *)path;

+ (void)updateDefaultCurrencies:(NSString *)previous withNew:(NSString *)abbreviation withPath:(NSString *)path;

@end
