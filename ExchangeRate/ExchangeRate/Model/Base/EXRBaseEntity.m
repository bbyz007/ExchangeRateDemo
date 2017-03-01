//
//  BaseEntity.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/7.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRBaseEntity.h"

@implementation EXRBaseEntity

- (instancetype)initWithCurrencyAbbreviation:(NSString *)abbreviation {
    NSString *msg = [NSString stringWithFormat:@"%s is not implemented for this class %@", sel_getName(_cmd), [self class]];
    @throw [NSException exceptionWithName:@"CurrencyModelInitialzerException" reason:msg userInfo:nil];
}


@end
