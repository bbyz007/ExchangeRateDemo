//
//  HistoricalService.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/15.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRHistoricalService.h"

#import "EXRate.h"
#import "EXRAFClient.h"
#import "EXRCurrentDAO.h"
#import "EXRHistoricalDAO.h"
#import "EXRExchangeRatePlistHelper.h"

static NSString *const urlPath1 = @"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22";
static NSString *const urlPath2 = @"%3DX%22%20and%20startDate%20%3D%20%22";
static NSString *const urlPath3 = @"%22%20and%20endDate%20%3D%20%22";
static NSString *const urlPath4 = @"%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=";
static const NSInteger timeIntervalSeconds = 366 * 24 * 60 * 60;
static const NSInteger secondsPerDay = 24 * 60 * 60;
static const CGFloat availableRange = 0.1f;
static BOOL getingDataNow;

@implementation EXRHistoricalService

+ (dispatch_queue_t)serviceQueue {
    static dispatch_queue_t service_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service_queue = dispatch_queue_create("exchangeRateHistorical.service.current", DISPATCH_QUEUE_SERIAL);
    });
    return service_queue;
}

+ (dispatch_queue_t)backgroundQueue {
    static dispatch_queue_t wait_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wait_queue = dispatch_queue_create("exchangeRateHistoricalBG.service.current", DISPATCH_QUEUE_SERIAL);
    });
    return wait_queue;
}

#pragma mark - update db file
//检查更新数据库数据
+ (void)getDefualtCurrenciesHistoricalExchangeRate {
    dispatch_async([[self class] backgroundQueue], ^{
        NSDate *endDate = [[NSDate alloc] init];
        NSDate *previousDay = [endDate dateByAddingTimeInterval:-secondsPerDay];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSTimeInterval time = timeIntervalSeconds;
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *previousDate = [formatter stringFromDate:previousDay];
        
        NSString *fromDate = [EXRHistoricalDAO queryDateNeedToUpdateWithIndex:0];
        if (![fromDate isEqualToString:previousDate]) {
            if (fromDate != nil) {
                NSDate *date = [formatter dateFromString:fromDate];
                time = [endDate timeIntervalSinceDate:date];
            }
            
            [[self class] p_getDataOfCurrency:@"CNY" WithTimeInterval:time];
        }

        NSArray *defaultCurrencies = [EXRCurrentDAO getDefaultCurrencies:[EXRExchangeRatePlistHelper currenciesPath]];
        for (NSInteger index = 0; index < defaultCurrencies.count; index++) {
            NSString *abbreviation = defaultCurrencies[index];
            
            if (![abbreviation isEqualToString:@"CNY"] && ![abbreviation isEqualToString:@"USD"]) {
                NSString *fromDate = [EXRHistoricalDAO queryDateNeedToUpdateWithIndex:index + 1];
                if (![fromDate isEqualToString:previousDate]) {
                    if (fromDate != nil) {
                        NSDate *date = [formatter dateFromString:fromDate];
                        time = [endDate timeIntervalSinceDate:date];
                    }
                    
                    [[self class] p_getDataOfCurrency:abbreviation WithTimeInterval:time];
                }
            }
        }
    });
}


+ (void)changeCurrency:(NSString *)abbreviation {
    
    if ([abbreviation isEqualToString:@"CNY"] || [abbreviation isEqualToString:@"USD"]) {
        return;
    }
    
    dispatch_async([[self class] backgroundQueue], ^{
        NSArray *defaultCurrencies = [EXRCurrentDAO getDefaultCurrencies:[EXRExchangeRatePlistHelper currenciesPath]];
        NSInteger index = [defaultCurrencies indexOfObject:abbreviation];
        
        if (index > defaultCurrencies.count - 1 && index < 0) {
            return;
        }
        
        if ([EXRHistoricalDAO deleteDateOfIndex:index + 1]) {
            [[self class] p_getDataOfCurrency:abbreviation WithTimeInterval:timeIntervalSeconds];
        }
    });
}

+ (void)resetCurrency:(NSString *)abbreviation {
    if (![abbreviation isEqualToString:@"CNY"] && ![abbreviation isEqualToString:@"USD"]) {
        NSArray *defaultCurrencies = [EXRCurrentDAO getDefaultCurrencies:[EXRExchangeRatePlistHelper currenciesPath]];
        NSInteger index = [defaultCurrencies indexOfObject:abbreviation];
        
        if (index > defaultCurrencies.count - 1 && index < 0) {
            return;
        }
        [EXRHistoricalDAO deleteDateOfIndex:index + 1];
    }
    
    [EXRHistoricalDAO deleteDateOfIndex:0];
}

+ (void)p_getDataOfCurrency:(NSString *)abbreviation WithTimeInterval:(NSInteger)time {
    NSArray *defaultCurrencies = [EXRCurrentDAO getDefaultCurrencies:[EXRExchangeRatePlistHelper currenciesPath]];
    NSInteger index = 0;
    
    if (![abbreviation isEqualToString:@"CNY"] && ![abbreviation isEqualToString:@"USD"]) {
        index = [defaultCurrencies indexOfObject:abbreviation];
        if (index < 0 || index > 3) {
            return;
        }
        index++;
    }
    
    if (abbreviation == nil) {
        return;
    }
    NSDate *endDate = [[NSDate alloc] init];
    
    [[self class] p_getDataForNetWithCurrency:abbreviation withEndDate:endDate withTimeInterval:time withCompletion:^(NSArray *array) {
        if (array.count) {
            dispatch_async([[self class] backgroundQueue], ^{
                [EXRHistoricalDAO updateHistoricalData:array withIndex:index];
            });
        }
    }];
}

//从服务器返回数据后更新数据库
+ (void)updateCurrency:(NSString *)abbreviation withDataArray:(NSArray<EXRate *> *)dataArray {
    dispatch_async([[self class] backgroundQueue], ^{
        if ([abbreviation isEqualToString:@"CNY"] || [abbreviation isEqualToString:@"USD"]) {
            [EXRHistoricalDAO updateHistoricalData:dataArray withIndex:0];
            return;
        }
        
        NSArray *defaultCurrencies = [EXRCurrentDAO getDefaultCurrencies:[EXRExchangeRatePlistHelper currenciesPath]];
        NSInteger index = [defaultCurrencies indexOfObject:abbreviation];
        if (index > 3 || index < 0) {
            return;
        }
        [EXRHistoricalDAO updateHistoricalData:dataArray withIndex:index + 1];
    });
}

#pragma mark - get data for VC

//从数据库中获取历史汇率
+ (void)getDateOfCurrency:(NSString *)abbreviation WithEndDate:(NSDate *)endDate withTimeInterval:(NSTimeInterval)timeInterval withCompletionHandler:(void (^)(NSArray<EXRate *> *, NSTimeInterval))completionHandler withFailedHandler:(void (^)(NSString *, NSTimeInterval))failedHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *localCurrency = @"CNY";
        NSDate *end = [endDate dateByAddingTimeInterval:-secondsPerDay];
        NSDate *fromDate = [end dateByAddingTimeInterval:-timeInterval];

        NSInteger index = 0;
        if (![abbreviation isEqualToString:@"CNY"] && ![abbreviation isEqualToString:@"USD"]) {
            NSArray *defaultCurrencies = [EXRCurrentDAO getDefaultCurrencies:[EXRExchangeRatePlistHelper currenciesPath]];
            index = [defaultCurrencies indexOfObject:abbreviation];
            if (index < 0 || index > defaultCurrencies.count - 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failedHandler) {
                        failedHandler(@"default currency error", timeInterval);
                    }
                });
                return;
            }
            
            index++;
        }
        
        dispatch_semaphore_t semaphore1 = dispatch_semaphore_create(0);
        dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
        __block NSMutableArray<EXRate *> *resultArray = [NSMutableArray array];
        __block BOOL needUpdate = YES;
        BOOL lessOneYear = timeInterval < timeIntervalSeconds;
        
        //首次从数据库获取数据，如不成功，则从网络下载更新
        [EXRHistoricalDAO getDataWithEndDate:end withFromDate:fromDate withIndex:index withCompletionBlock:^(NSArray<EXRate *> *array, BOOL local, BOOL exchange) {

            if (array != nil) {
                resultArray = [array copy];
                needUpdate = NO;
                dispatch_semaphore_signal(semaphore1);
                dispatch_semaphore_signal(semaphore2);
                
            } else if (!getingDataNow) {
                getingDataNow = YES;
                if (lessOneYear) {
                    dispatch_async([[self class] serviceQueue], ^{
                        NSTimeInterval time = timeIntervalSeconds;
                        
                        if (index == 0) {
                            [[self class] p_getDataForNetWithCurrency:localCurrency withEndDate:end withTimeInterval:time withCompletion:^(NSArray *array) {
                                if (array.count) {
                                    [[self class] updateCurrency:localCurrency withDataArray:[array copy]];
                                }
                                dispatch_semaphore_signal(semaphore1);
                            }];
                            
                        } else {
                            if (local) {
                                [[self class] p_getDataForNetWithCurrency:localCurrency withEndDate:end withTimeInterval:time withCompletion:^(NSArray *array) {
                                    if (array.count) {
                                        [[self class] updateCurrency:localCurrency withDataArray:[array copy]];
                                    }
                                    dispatch_semaphore_signal(semaphore1);
                                }];
                            }
                            
                            if (exchange) {
                                [[self class] p_getDataForNetWithCurrency:abbreviation withEndDate:end withTimeInterval:time withCompletion:^(NSArray *array) {
                                    if (array.count) {
                                        [[self class] updateCurrency:abbreviation withDataArray:[array copy]];
                                    }
                                    dispatch_semaphore_signal(semaphore2);
                                }];
                            }
                        }
                    });
                    
                } else {
                    //三年数据分开处理
                    if (index == 0) {
                        [[self class] p_getLongPeriodOfCurrency:localCurrency withIndex:index WithEndDate:end withTimeInterval:timeInterval];
                        
                    } else {
                        if (local) {
                            [[self class] p_getLongPeriodOfCurrency:localCurrency withIndex:index WithEndDate:end withTimeInterval:timeInterval];
                        }
                        if (exchange) {
                            [[self class] p_getLongPeriodOfCurrency:abbreviation withIndex:index WithEndDate:end withTimeInterval:timeInterval];
                        }
                    }
                }
            }
        }];
       
        dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC));
        dispatch_semaphore_wait(semaphore1, waitTime);
        dispatch_semaphore_wait(semaphore2, waitTime);
        getingDataNow = NO;

        //重新加载数据库数据
        if (needUpdate) {
            [EXRHistoricalDAO getDataWithEndDate:end withFromDate:fromDate withIndex:index withCompletionBlock:^(NSArray<EXRate *> *array, BOOL local, BOOL exchange) {
                resultArray = [array copy];
                dispatch_semaphore_signal(semaphore1);
            }];
        } else {
            dispatch_semaphore_signal(semaphore1);
        }
        
        dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER);
        if (resultArray.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler(resultArray, timeInterval);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failedHandler) {
                    failedHandler(@"get data failed", timeInterval);
                }
            });
        }
    });
}


//从plist文件中获取当前汇率
+ (EXRate *)getCurrentRateWithLocaCurrency:(NSString *)localCurrency withExchangeCurrency:(NSString *)exchangeCurrency withDate:(NSString *)toDate {
    NSString *local = [EXRCurrentDAO getExchangeRate:localCurrency withPath:[EXRExchangeRatePlistHelper currentRatePath]];
    NSString *exchange = [EXRCurrentDAO getExchangeRate:exchangeCurrency withPath:[EXRExchangeRatePlistHelper currentRatePath]];
    CGFloat localValue = [local floatValue];
    CGFloat exchangeValue = [exchange floatValue];
    
    if (exchangeValue > 0) {
        CGFloat rate = localValue / exchangeValue;
        EXRate *model = [[EXRate alloc] init];
        model.date = toDate;
        model.rate = rate;
        return model;
    }
    return nil;
}

#pragma mark - get data from network

+ (void)p_getLongPeriodOfCurrency:(NSString *)currency withIndex:(NSInteger)index WithEndDate:(NSDate *)endDate withTimeInterval:(NSTimeInterval)timeInterval {
    
    dispatch_async([[self class] backgroundQueue], ^{
        NSTimeInterval time = timeInterval;
        NSDate *end = endDate;
        
        do {
            BOOL haveData = [EXRHistoricalDAO haveDataWithEndDate:end withTimeInterval:timeIntervalSeconds withIndex:index];
            
            if (!haveData) {
                [self p_getDataForNetWithCurrency:currency withEndDate:end withTimeInterval:timeIntervalSeconds withCompletion:^(NSArray *array) {
                    if (array.count) {
                        [[self class] updateCurrency:currency withDataArray:[array copy]];
                    }
                }];
            }
            end = [end dateByAddingTimeInterval:-timeIntervalSeconds];
            time -= timeIntervalSeconds;
        } while (time > 0);
    });
}

+ (void)p_getDataForNetWithCurrency:(NSString *)currency withEndDate:(NSDate *)endDate withTimeInterval:(NSTimeInterval)timeInterval withCompletion:(void (^)(NSArray *))completion {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [endDate dateByAddingTimeInterval:-timeInterval];
    NSString *fromDate = [formatter stringFromDate:startDate];
    NSString *toDate = [formatter stringFromDate:endDate];

    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@%@%@%@%@%@", urlPath1, currency, urlPath2, fromDate, urlPath3, toDate, urlPath4];
    
    [[EXRAFClient shareClient] GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *query = [responseObject valueForKey:@"query"];
        NSDictionary *results= [query valueForKey:@"results"];
        id quote = [results valueForKey:@"quote"];
        NSMutableArray *resultArray = [NSMutableArray array];
        
        if ([quote isKindOfClass:[NSArray class]]) {
            NSArray *dataArray = [quote copy];
            if (dataArray.count) {
                resultArray = [[[self class] p_setDataWith:dataArray] copy];
            }
        }

        if (completion) {
            completion(resultArray);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
//            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//            NSLog(@"%@ %@ %@",currency, endDate, @(response.statusCode));
            completion(nil);
        }
    }];
}

//过滤异常数据
+ (NSArray *)p_setDataWith:(NSArray *)dataArray {
    CGFloat average = 0;
    NSInteger count = 0;
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (NSInteger index = 0; index < dataArray.count; index++) {
        id obj = dataArray[index];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)obj;
            CGFloat value = [[dic valueForKey:@"Close"] floatValue];
            NSString *date = [dic valueForKey:@"Date"];
            BOOL valid = YES;
            
            if (value > 0) {
                if (count == 0) {
                    average = value;
                    count++;
                    
                } else if (count == 1) {
                    if (fabs(value / average - 1) < availableRange) {
                        count++;
                        average = (average + value) / count;
                    } else {
                        count = 0;
                        average = 0;
                        valid = NO;
                        [resultArray removeAllObjects];
                    }
                    
                } else {
                    if (fabs(value / average - 1) < availableRange) {
                        average = (average * 4 + value) / 5;                //此处设置：为增加value在后续平均值中的比重
                    } else {
                        valid = NO;
                    }
                }
            }
            
            if (valid) {
                EXRate *model = [[EXRate alloc] init];
                model.date = date;
                model.rate = value;
                [resultArray addObject:model];
            }
        }
    }
    
    return resultArray;
}

@end
