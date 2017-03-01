//
//  HistoricalDBHelper.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/16.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>


@interface EXRDBHelper : NSObject

+ (void)buildDBFile;

+ (NSString *)dbPath;

+ (instancetype)shareInstance;

@property (strong, nonatomic, readonly) FMDatabaseQueue *dbQueue;

@end
