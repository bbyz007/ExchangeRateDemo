//
//  Currency.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrency.h"

#import "EXRCurrencyDetailHelper.h"
#import "EXRCurrentDAO.h"
#import "EXRExchangeRatePlistHelper.h"

@implementation EXRCurrency

- (instancetype)initWithCurrencyAbbreviation:(NSString *)abbreviation {
    EXRCurrency *currency = [[EXRCurrency alloc] init];
    NSDictionary *detail = [EXRCurrencyDetailHelper currencyDetailWithAbbreviation:abbreviation];

    currency.abbreviation = abbreviation;
    currency.name = [detail valueForKey:@"name"];
    currency.symbol = [detail valueForKey:@"symbol"];
    currency.placeHolder = [EXRCurrentDAO getExchangeRate:abbreviation withPath:[EXRExchangeRatePlistHelper currentRatePath]];
    return currency;
}

@end
