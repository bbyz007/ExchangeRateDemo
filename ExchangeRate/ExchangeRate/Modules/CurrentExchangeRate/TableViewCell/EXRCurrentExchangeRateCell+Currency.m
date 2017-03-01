//
//  EXRCurrentExchangeRateCell+Currency.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/26.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrentExchangeRateCell+Currency.h"

#import "EXRCurrency.h"
#import "EXRCustomTextField.h"

@implementation EXRCurrentExchangeRateCell (Currency)

- (void)configureWithCurrency:(EXRCurrency *)currency {
    self.flag.image = [UIImage imageNamed:currency.abbreviation];
    self.abbreviationLabel.text = currency.abbreviation;
    self.amount.placeholder = currency.placeHolder;
    self.symbolLabel.text = [NSString stringWithFormat:@"%@  %@", currency.name, currency.symbol];
    
    if ([currency.abbreviation containsString:@"CNY"]) {
        self.localIcon.image = [UIImage imageNamed:@"localIcon"];
    } else {
        self.localIcon.image = nil;
    }
}


@end
