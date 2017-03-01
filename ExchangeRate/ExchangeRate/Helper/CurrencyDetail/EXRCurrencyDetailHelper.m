//
//  CurrencyDetailHelper.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/7.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrencyDetailHelper.h"

@implementation EXRCurrencyDetailHelper


+ (NSDictionary *)currencyDetailWithAbbreviation:(NSString *)abbreviation {
    NSDictionary *detail = @{
                             @"AUD": @{@"name": @"澳元", @"symbol": @"$"},
                             @"EGP": @{@"name": @"埃及镑", @"symbol": @"Le"},
                             @"MOP": @{@"name": @"澳门币", @"symbol": @"MOP$"},
                             
                             @"ISK": @{@"name": @"冰岛克朗", @"symbol": @"Kr"},
                             @"XPT": @{@"name": @"铂", @"symbol": @"﹒克"},
                             @"BTC": @{@"name": @"比特币", @"symbol": @""},

                             @"KPW": @{@"name": @"朝鲜币", @"symbol": @"₩"},
                             
                             @"DKK": @{@"name": @"丹麦币", @"symbol": @"kr"},
                             
                             @"RUB": @{@"name": @"俄罗斯卢布", @"symbol": @"₽"},
                             
                             @"PHP": @{@"name": @"菲律宾比绍", @"symbol": @"₱"},
                             
                             @"HKD": @{@"name": @"港币", @"symbol": @"$"},

                             @"KRW": @{@"name": @"韩币", @"symbol": @"₩"},
                             
                             @"XAU": @{@"name": @"金", @"symbol": @"﹒克"},

                             @"KES": @{@"name": @"肯尼亚先令", @"symbol": @"Ksh"},
                             
                             @"CNH": @{@"name": @"离岸人民币", @"symbol": @"¥"},
                             
                             @"USD": @{@"name": @"美元", @"symbol": @"$"},

                             @"NOK": @{@"name": @"挪威克朗", @"symbol": @"Kr"},
                             
                             @"EUR": @{@"name": @"欧元", @"symbol": @"€"},

                             @"VEF": @{@"name": @"强势玻利瓦尔", @"symbol": @"Bs."},
                             
                             @"CNY": @{@"name": @"人民币", @"symbol": @"¥"},
                             @"JPY": @{@"name": @"日元", @"symbol": @"¥"},

                             @"SDG": @{@"name": @"苏丹镑", @"symbol": @"£"},
                             
                             @"THB": @{@"name": @"泰铢", @"symbol": @"฿"},
                             
                             @"TWD": @{@"name": @"新台币", @"symbol": @"NT$"},
                             
                             @"GBP": @{@"name": @"英镑", @"symbol": @"£"},
                             @"XAG": @{@"name": @"银", @"symbol": @"﹒克"},

                             @"CLP": @{@"name": @"智利比绍", @"symbol": @"$"},
                             };
    return [detail valueForKey:abbreviation];
}


+ (NSDictionary *)allCurrencies {
    NSDictionary *currencies = @{
                                 @"A": @[@"AUD", @"EGP", @"MOP"],
                                 @"B": @[@"ISK", @"XPT", @"BTC"],
                                 @"C": @[@"KPW"],
                                 @"D": @[@"DKK"],
                                 @"E": @[@"RUB"],
                                 @"F": @[@"PHP"],
                                 @"G": @[@"HKD"],
                                 @"H": @[@"KRW"],
                                 @"J": @[@"XAU"],
                                 @"K": @[@"KES"],
                                 @"L": @[@"CNH"],
                                 @"M": @[@"USD"],
                                 @"N": @[@"NOK"],
                                 @"O": @[@"EUR"],
                                 @"Q": @[@"VEF"],
                                 @"R": @[@"CNY", @"JPY"],
                                 @"S": @[@"SDG"],
                                 @"T": @[@"THB"],
                                 @"X": @[@"TWD"],
                                 @"Y": @[@"GBP", @"XAG"],
                                 @"Z": @[@"CLP"],
                                 };
    return currencies;
}


+ (NSArray *)expensiveCurrencies {
    return @[@"XAU", @"XAG", @"XPT", @"BTC"];
}


@end
