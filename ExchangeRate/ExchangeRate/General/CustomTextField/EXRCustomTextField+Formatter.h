//
//  EXRCustomTextField+Formatter.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/26.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCustomTextField.h"

@interface EXRCustomTextField (Formatter)

- (double)calculateTextValueWithInput:(NSString *)title;

- (BOOL)legalInput:(NSString *)title;

- (void)textInput:(NSString *)title;

- (NSString *)setStringFormat:(NSString *)string;

- (BOOL)setCalculateTextWith:(NSString *)title;

- (NSString *)adjustDecimalsWith:(NSString *)string;

- (NSInteger)calculateDecimalsNum:(NSString *)string;

@end
