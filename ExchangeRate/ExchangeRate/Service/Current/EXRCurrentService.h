//
//  CurrentExchangeRateService.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EXRCurrency;

@interface EXRCurrentService : NSObject

+ (NSArray<EXRCurrency *> *)getCurrencies;

+ (void)getCurrentExchangeRate:(NSArray<EXRCurrency *> *)currencies withCompletionHandler:(void (^)(NSDictionary *))completionHandler withFailedHandler:(void (^)(NSString *))failedHandler;


@end
