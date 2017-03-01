//
//  CurrentExchangeRateService.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrentService.h"

#import "EXRCurrency.h"
#import "EXRCurrentDAO.h"
#import "EXRAFClient.h"
#import "EXRExchangeRatePlistHelper.h"
#import "EXRCurrencyDetailHelper.h"

#import <AFNetworking/AFNetworking.h>

static NSString *const urlPath1 = @"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20csv%20where%20url%3D%22http%3A%2F%2Ffinance.yahoo.com%2Fd%2Fquotes.csv%3Fe%3D.csv%26f%3Dnl1d1t1%26s%3D";
static NSString *const urlPath2 = @"%3DX%2C";
static NSString *const urlPath3 = @"%3DX%22%3B&format=json&diagnostics=true&callback=";

static const CGFloat grammaPerOunce = 31.1035f;

@implementation EXRCurrentService

+ (dispatch_queue_t)serviceQueue {
    static dispatch_queue_t service_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service_queue = dispatch_queue_create("exchangeRate.service.current", DISPATCH_QUEUE_SERIAL);
    });
    return service_queue;
}


+ (void)getCurrentExchangeRate:(NSArray<EXRCurrency *> *)currencies withCompletionHandler:(void (^)(NSDictionary *))completionHandler withFailedHandler:(void (^)(NSString *))failedHandler {
    
    dispatch_async([[self class] serviceQueue], ^{
        
        if (currencies == nil) {
            return;
        }
        
        NSArray *expenArray = [[EXRCurrencyDetailHelper expensiveCurrencies] copy];
        NSMutableArray<NSString *> *abbArray = [NSMutableArray array];
        for (EXRCurrency *currency in currencies) {
            NSString *abbreviation = currency.abbreviation;
            if (abbreviation.length == 3 && ![expenArray containsObject:abbreviation]) {
                abbreviation = [@"USD" stringByAppendingString:abbreviation];
                [abbArray addObject:abbreviation];
            } else {
                abbreviation = [abbreviation stringByAppendingString:@"USD"];
                [abbArray addObject:abbreviation];
            }
        }
        
        if (currencies.count != abbArray.count) {
           dispatch_async(dispatch_get_main_queue(), ^{
               if (failedHandler) {
                   failedHandler(@"currency abbrevaiton error");
               }
           });
        }
        
        NSString *url = [[self class] p_getUrlWithArray:abbArray];
        [[EXRAFClient shareClient] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSDictionary *query = [responseObject valueForKey:@"query"];
            NSDictionary *result = [query valueForKey:@"results"];
            NSArray *row = [result valueForKey:@"row"];
            
            NSMutableDictionary *currentDic = [NSMutableDictionary dictionary];
            for (NSDictionary *dic in row) {
                NSString *str = [dic valueForKey:@"col0"];
                if ([str isKindOfClass:[NSString class]] && str.length > 4) {
                    NSString *abb = [str substringFromIndex:4];
                    NSString *value = [dic valueForKey:@"col1"];
                    if ([expenArray containsObject:abb]) {
                        CGFloat amount = [value floatValue];
                        if (![abb isEqualToString:@"BTC"]) {
                            amount = amount / grammaPerOunce;
                        }
                        if (amount > 0) {
                            amount = 1 / amount;
                        }
                        value = [NSString stringWithFormat:@"%.7f", amount];
                    }
                    [currentDic setValue:value forKey:abb];
                }
            }
            
            if (currentDic.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionHandler) {
                        completionHandler(currentDic);
                    }
                });
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failedHandler) {
                    failedHandler(@"current EXR update failed");
                }
            });
        }];
        
        [[self class] p_updateAllCurrencies];
    });
}


+ (void)p_updateAllCurrencies {
    NSDictionary *dic = [[EXRCurrencyDetailHelper class] allCurrencies];
    NSMutableArray *array = [NSMutableArray array];
    NSArray *expenArray = [[EXRCurrencyDetailHelper expensiveCurrencies] copy];

    for (NSString *key in dic.allKeys) {
        NSArray *arr = [dic valueForKey:key];
        for (NSString *abbreviation in arr) {
            if (![expenArray containsObject:abbreviation]) {
                NSString *abb = [@"USD" stringByAppendingString:abbreviation];
                [array addObject:abb];
            }
        }
    }
    
    NSString *url = [[self class] p_getUrlWithArray:array];
    [[EXRAFClient shareClient] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *query = [responseObject valueForKey:@"query"];
        NSDictionary *result = [query valueForKey:@"results"];
        NSArray *row = [result valueForKey:@"row"];
        
        NSMutableDictionary *currentDic = [NSMutableDictionary dictionary];
        for (NSDictionary *dic in row) {
            NSString *str = [dic valueForKey:@"col0"];
            if ([str isKindOfClass:[NSString class]] && str.length > 4) {
                NSString *abb = [str substringFromIndex:4];
                NSString *value = [dic valueForKey:@"col1"];
                [currentDic setValue:value forKey:abb];
            }
        }
        
        if (currentDic.count) {
            [EXRCurrentDAO insertCurrentExchangeRate:currentDic withPath:[EXRExchangeRatePlistHelper currentRatePath]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"update all currencies fail");
    }];
    
    //调整贵金属价格
    [array removeAllObjects];
    for (NSString *abbreviation in expenArray) {
        NSString *abb = [abbreviation stringByAppendingString:@"USD"];
        [array addObject:abb];
    }
    
    url = [[self class] p_getUrlWithArray:array];
    [[EXRAFClient shareClient] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *query = [responseObject valueForKey:@"query"];
        NSDictionary *result = [query valueForKey:@"results"];
        NSArray *row = [result valueForKey:@"row"];
        
        NSMutableDictionary *currentDic = [NSMutableDictionary dictionary];
        if (row.count == expenArray.count) {
            for (NSInteger index = 0; index < expenArray.count; index++) {
                NSString *abb = expenArray[index];
                id obj = row[index];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = (NSDictionary *)obj;
                    NSString *value = [dic valueForKey:@"col1"];
                    CGFloat amount = [value floatValue];
                    
                    if (![abb isEqualToString:@"BTC"]) {
                        amount = amount / grammaPerOunce;
                    }
                    if (amount > 0) {
                        amount = 1 / amount;
                    }
                    value = [NSString stringWithFormat:@"%.7f",amount];
                    [currentDic setValue:value forKey:abb];
                }
            }
        }
        
        if (currentDic.count) {
            [EXRCurrentDAO insertCurrentExchangeRate:currentDic withPath:[EXRExchangeRatePlistHelper currentRatePath]];
        }
    } failure:nil];
}


+ (NSString *)p_getUrlWithArray:(NSArray<NSString *> *)abbArray {
    NSString *url = urlPath1;
    
    for (NSInteger index = 0; index < abbArray.count; index++) {
        NSString *str = abbArray[index];
        url = [url stringByAppendingString:str];
        
        if (index < abbArray.count - 1) {
            url = [url stringByAppendingString:urlPath2];
        } else {
            url = [url stringByAppendingString:urlPath3];
        }
    }
    return url;
}


+ (NSArray<EXRCurrency *> *)getCurrencies {
    NSArray *defaultCurrencies = [EXRCurrentDAO getDefaultCurrencies:[EXRExchangeRatePlistHelper currenciesPath]];
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *abbreviation in defaultCurrencies) {
        EXRCurrency *currency = [[EXRCurrency alloc] initWithCurrencyAbbreviation:abbreviation];
        CGFloat value = [currency.placeHolder floatValue];
        
        if (value) {
            NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.4f", value]];
            currency.placeHolder = [NSString stringWithFormat:@"%@", num];
        } else {
            currency.placeHolder = @"---";
        }
        [array addObject:currency];
    }
    return array;
}

@end
