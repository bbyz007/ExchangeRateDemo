//
//  ExchangeRatePlistHelper.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/7.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EXRExchangeRatePlistHelper : NSObject

+ (NSString *)plistFolder;

+ (NSString *)currentRatePath;

+ (void)buildPlistFile;

+ (NSString *)currenciesPath;


@end
