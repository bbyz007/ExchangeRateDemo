//
//  ChosenService.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/9.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRChosenService.h"

#import "EXRExchangeRatePlistHelper.h"
#import "EXRCurrencyDetailHelper.h"
#import "EXRCurrentDAO.h"
#import "EXRHistoricalService.h"

@implementation EXRChosenService


+ (void)updateCommonCurrencies:(NSString *)abbreviation {
    [EXRCurrentDAO updateCommonCurrencies:abbreviation withPath:[EXRExchangeRatePlistHelper currenciesPath]];
}

+ (void)updateDefaultCurrencies:(NSString *)previous withNew:(NSString *)abbreviation {
    [EXRCurrentDAO updateDefaultCurrencies:previous withNew:abbreviation withPath:[EXRExchangeRatePlistHelper currenciesPath]];
    [EXRHistoricalService changeCurrency:abbreviation];
}


+ (void)getCurrenciesWithCompletionHandler:(void (^)(NSArray *, NSArray *))completionHandler{
    NSDictionary *allCurrencies = [[EXRCurrencyDetailHelper class] allCurrencies];
    NSArray *expensiveCurrencies = [[EXRCurrencyDetailHelper class] expensiveCurrencies];
    NSArray *commonCurrencies = [[EXRCurrentDAO class] getCommonCurrencies:[EXRExchangeRatePlistHelper currenciesPath]];
    
    NSMutableArray<NSArray *> *currencies = [NSMutableArray array];
    NSMutableArray *sections = [NSMutableArray array];
    
    [currencies addObject:[[self class] p_getCurrenciesArray:commonCurrencies]];
    [sections addObject:@"常用货币"];
   
    [currencies addObject:@[@"人民币 CNY"]];
    [sections addObject:@"当地货币"];

    [currencies addObject:[[self class] p_getCurrenciesArray:expensiveCurrencies]];
    [sections addObject:@"土豪货币"];
    
    unichar beChar = 'A';
    for (NSInteger index = 0; index < 26; index++) {
        unichar character = beChar + index;
        NSString *key = [NSString stringWithCharacters:&character length:1];
        NSArray *keyArray = [allCurrencies valueForKey:key];
        
        if (keyArray.count) {
            [currencies addObject:[[self class] p_getCurrenciesArray:keyArray]];
            [sections addObject:key];
        }
    }
    
    if (completionHandler) {
        completionHandler(currencies, sections);
    }
}


+ (NSArray *)p_getCurrenciesArray:(NSArray *)keyArray {
    NSMutableArray *common = [NSMutableArray array];
    for (NSString *key in keyArray) {
        NSString *name = [[[EXRCurrencyDetailHelper class] currencyDetailWithAbbreviation:key] valueForKey:@"name"];
        name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", key]];
        [common addObject:name];
    }
    return [common copy];
}

@end
