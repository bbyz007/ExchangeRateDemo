//
//  HistoricalDAO.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/17.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRHistoricalDAO.h"

#import "EXRate.h"
#import "EXRDBHelper.h"

static const CGFloat availableDataScale = 0.90f;
static const CGFloat secondsPerDay = 24 * 60 * 60;

@implementation EXRHistoricalDAO


+ (NSString *)queryDateNeedToUpdateWithIndex:(NSInteger)index {
    NSString *row = [[self class] p_switchIndexWithString:index];
    __block NSString *date = nil;

    [[EXRDBHelper shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM EX_HISTORICAL WHERE %@ IS NOT NULL ORDER BY id DESC LIMIT %@", row, @(365)];
        FMResultSet *set = [db executeQuery:sql];
        
        if ([set next]) {
            date = [set stringForColumn:@"date"];
        }
        [set close];
    }];
    return date;
}


+ (void)updateHistoricalData:(NSArray<EXRate *> *)dataArray withIndex:(NSInteger)index {
    NSString *row = [[self class] p_switchIndexWithString:index];

    [[EXRDBHelper shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        for (NSInteger ind = dataArray.count - 1; ind >= 0; ind--) {
            EXRate *model = dataArray[ind];
            NSString *value = [NSString stringWithFormat:@"%.6f", model.rate];
            NSString *sql = [NSString stringWithFormat:@"UPDATE EX_HISTORICAL SET %@ = %@ WHERE date = '%@';", row, value, model.date];
            NSString *sql2 = [NSString stringWithFormat:@"INSERT INTO EX_HISTORICAL (date, %@) SELECT '%@', %@ WHERE changes() = 0", row, model.date, value];
            [db executeUpdate:sql];
            [db executeUpdate:sql2];
        }
    }];
}


+ (BOOL)haveDataWithEndDate:(NSDate *)endDate withTimeInterval:(NSTimeInterval)time withIndex:(NSInteger)index {
    NSString *row = [[self class] p_switchIndexWithString:index];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
   
    NSMutableArray *dateArray = [NSMutableArray array];
    for (NSInteger index = 0; index < 3; index++) {
        NSDate *date = [endDate dateByAddingTimeInterval:-time / 6 * (index * 2 + 1)];
        NSString *dateStr = [formatter stringFromDate:date];
        [dateArray addObject:dateStr];
    }
    
    __block BOOL haveData = YES;
    [[EXRDBHelper shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        CGFloat value = 0;
        NSInteger num = 0;
        
        for (NSString *dateStr in dateArray) {
            NSString *date = dateStr;
            value = 0;
            num = 0;
            
            do {
                FMResultSet *set = [db executeQuery:@"SELECT * FROM EX_HISTORICAL WHERE date = ?", date];
                if ([set next]) {
                    value = [[set stringForColumn:row] floatValue];
                }
                [set close];
                
                if (value > 0) {
                    break;
                }
                
                num++;
                NSDate *newDate = [formatter dateFromString:date];
                newDate = [newDate dateByAddingTimeInterval:-secondsPerDay];
                date = [formatter stringFromDate:newDate];
                
            } while (num < 7);
            
            if (value == 0) {
                haveData = NO;
                break;
            }
        }
    }];
    
    return haveData;
}

//completion block中两个bool值分别代表本地汇率和兑换汇率数据是否需要重新下载
+ (void)getDataWithEndDate:(NSDate *)endDate withFromDate:(NSDate *)fromDate withIndex:(NSInteger)index withCompletionBlock:(void (^)(NSArray<EXRate *> *, BOOL, BOOL))completion {
    NSString *row = [[self class] p_switchIndexWithString:index];
    
    //验证时间有效性
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    __block NSString *begin = [formatter stringFromDate:fromDate];
    __block NSString *end = [formatter stringFromDate:endDate];
    __block long long beginID = 0;
    __block long long endID = 0;
    __block NSInteger num = 0;
    
    [[EXRDBHelper shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        do {
            FMResultSet *setBegin = [db executeQuery:@"SELECT * FROM EX_HISTORICAL WHERE date = ?", begin];
            if ([setBegin next]) {
                beginID = [setBegin longLongIntForColumn:@"id"];
            }
            [setBegin close];
            
            if (beginID > 0) {
                break;
            }
            
            NSDate *date = [formatter dateFromString:begin];
            date = [date dateByAddingTimeInterval:-secondsPerDay];
            begin = [formatter stringFromDate:date];
            num++;
        } while (num < 10);
    }];
    
    num = 0;
    [[EXRDBHelper shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        do {
            FMResultSet *setEnd = [db executeQuery:@"SELECT * FROM EX_HISTORICAL WHERE date = ?", end];
            if ([setEnd next]) {
                endID = [setEnd longLongIntForColumn:@"id"];
            }
            [setEnd close];
            
            if (endID > 0) {
                break;
            }
            
            NSDate *date = [formatter dateFromString:end];
            date = [date dateByAddingTimeInterval:-secondsPerDay];
            end = [formatter stringFromDate:date];
            num++;
        } while (num < 10);
    }];
    
    beginID--;
    long long limit = endID - beginID;
    if (!(beginID && endID && limit)) {
        if (completion) {
            completion(nil, YES, YES);
        }
    }
    
    //读取数据
    NSMutableArray<EXRate *> *array = [NSMutableArray array];
    __block NSInteger count1 = 0;
    __block NSInteger count2 = 0;
    NSTimeInterval time = [endDate timeIntervalSinceDate:fromDate];
    NSInteger amount = time / (24 * 60 * 60);
    
    if (index == 0) {
        [[EXRDBHelper shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM EX_HISTORICAL LIMIT %@ OFFSET %@", @(limit), @(beginID)];
            FMResultSet *set = [db executeQuery:sql];
            
            while ([set next]) {
                NSString *value = [set stringForColumn:@"local"];
                if (value.length > 0) {
                    EXRate *rate = [[EXRate alloc] init];
                    rate.date = [set stringForColumn:@"date"];
                    rate.rate = [value floatValue];
                    [array insertObject:rate atIndex:0];
                    count1++;
                }
            }
            [set close];
        }];
        
        CGFloat scale = 0;
        if (amount > 0) {
            scale = 1.0 * count1 / (amount * 1.0 * 5 / 7);
        }
        if (scale < availableDataScale) {
            array = nil;
        }
        
        if (completion) {
            completion(array, YES, NO);
        }
        
    } else {
        [[EXRDBHelper shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM EX_HISTORICAL LIMIT %@ OFFSET %@", @(limit), @(beginID)];
            FMResultSet *set = [db executeQuery:sql];
            
            while ([set next]) {
                CGFloat value1 = [[set stringForColumn:@"local"] floatValue];
                CGFloat value2 = [[set stringForColumn:row] floatValue];
                
                if (value1) {
                    count1++;
                }
                if (value2) {
                    count2++;
                }
                
                if (value1 && value2) {
                    EXRate *rate = [[EXRate alloc] init];
                    rate.date = [set stringForColumn:@"date"];
                    rate.rate = value1 / value2;
                    [array insertObject:rate atIndex:0];
                }
            }
            [set close];
        }];
        
        CGFloat scale1 = 0;
        CGFloat scale2 = 0;
        if (amount > 0) {
            scale1 = 1.0 * count1 / (amount * 1.0 * 5 / 7);
            scale2 = 1.0 * count2 / (amount * 1.0 * 5 / 7);
        }
        
        BOOL local = scale1 < availableDataScale;
        BOOL exchange = scale2 < availableDataScale;
        if (local || exchange) {
            array = nil;
        }
        
        if (completion) {
            completion(array, local, exchange);
        }
    }
}


+ (BOOL)deleteDateOfIndex:(NSInteger)index {
    
    NSString *row = [[self class] p_switchIndexWithString:index];
    if (row.length == 0) {
        return NO;
    }
    
    __block BOOL succ = NO;
    [[EXRDBHelper shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE EX_HISTORICAL SET %@ = NULL", row];
        succ = [db executeUpdate:sql];
    }];
    
    return succ;
}

+ (NSString *)p_switchIndexWithString:(NSInteger)index {
    NSString *str = @"";
    switch (index) {
        case 0:
            str = @"local";
            break;
        case 1:
            str = @"first";
            break;
        case 2:
            str = @"second";
            break;
        case 3:
            str = @"third";
            break;
        case 4:
            str = @"fourth";
            break;
    }
    
    return str;
}



@end
