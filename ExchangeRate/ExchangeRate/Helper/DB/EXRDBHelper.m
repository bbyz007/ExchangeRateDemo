//
//  HistoricalDBHelper.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/16.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRDBHelper.h"

#import "EXRExchangeRatePlistHelper.h"
#import <FMDB/FMDB.h>

@implementation EXRDBHelper
@synthesize dbQueue = _dbQueue;

+ (instancetype)shareInstance {
    static EXRDBHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[EXRDBHelper alloc] init];
    });
    return _instance;
}

- (FMDatabaseQueue *)dbQueue {
    if (_dbQueue == nil) {
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:[[self class] dbPath]];
    }
    return _dbQueue;
}


+ (NSString *)p_dbFolder {
    return [EXRExchangeRatePlistHelper plistFolder];
}


+ (NSString *)dbPath {
    NSString *path = [[[self class] p_dbFolder] stringByAppendingPathComponent:@"historicalDB.sqlite"];
    return path;
}


+ (void)buildDBFile {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[self class] p_dbFolder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[[self class] p_dbFolder] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL succ = [[self class] p_createTable];
    if (succ) {
        NSLog(@"db init succ");
        [[self class] p_setDate];
    } else {
        NSLog(@"db init failed");
    }
}

+ (BOOL)p_createTable {
    __block BOOL succ = NO;
    
    [[[[self class] shareInstance] dbQueue] inDatabase:^(FMDatabase *db) {
        succ = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'EX_HISTORICAL'(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, local TEXT, first TEXT, second TEXT, third TEXT, fourth TEXT)"];
    }];
    return succ;
}


+ (void)p_setDate {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *date = [[NSDate alloc] init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSInteger interval = 24 * 60 * 60;
        
        [[[[self class] shareInstance] dbQueue] inDatabase:^(FMDatabase *db) {
            for (NSInteger index = 370 * 3; index >= 0; index--) {
                NSTimeInterval timeInterval = -index * interval;
                NSDate *previous = [date dateByAddingTimeInterval:timeInterval];
                NSString *preDate = [formatter stringFromDate:previous];
                
                [db executeUpdate:@"INSERT INTO EX_HISTORICAL (date) VALUES (?)", preDate];
                
            }
        }];
    });
}

@end
