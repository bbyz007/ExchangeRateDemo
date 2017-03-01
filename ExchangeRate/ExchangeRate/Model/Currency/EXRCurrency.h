//
//  Currency.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRBaseEntity.h"

@interface EXRCurrency : EXRBaseEntity

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *abbreviation;
@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *placeHolder;

@end
