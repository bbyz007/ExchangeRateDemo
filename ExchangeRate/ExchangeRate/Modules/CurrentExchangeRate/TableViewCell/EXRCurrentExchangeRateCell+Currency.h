//
//  EXRCurrentExchangeRateCell+Currency.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/26.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrentExchangeRateCell.h"

@class EXRCurrency;

@interface EXRCurrentExchangeRateCell (Currency)

- (void)configureWithCurrency:(EXRCurrency *)currency;

@end
