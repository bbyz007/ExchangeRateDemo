//
//  CurrentDAO.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/7.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrentDAO.h"

@implementation EXRCurrentDAO


+ (void)updateCommonCurrencies:(NSString *)abbreviation withPath:(NSString *)path {
    NSMutableDictionary *dictionary = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
    NSMutableArray *array = [[dictionary valueForKey:@"common"] mutableCopy];
    if ([array containsObject:abbreviation]) {
        [array removeObject:abbreviation];
    } else {
        [array removeLastObject];
    }
    [array insertObject:abbreviation atIndex:0];
    [dictionary setValue:array forKey:@"common"];
    [dictionary writeToFile:path atomically:YES];
}


+ (void)updateDefaultCurrencies:(NSString *)previous withNew:(NSString *)abbreviation withPath:(NSString *)path {
    NSMutableDictionary *dictionary = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
    NSMutableArray *defaultCurrencies = [[dictionary valueForKey:@"default"] mutableCopy];
    NSInteger index = [defaultCurrencies indexOfObject:previous];
    [defaultCurrencies removeObjectAtIndex:index];
    [defaultCurrencies insertObject:abbreviation atIndex:index];
    [dictionary setValue:defaultCurrencies forKey:@"default"];
    [dictionary writeToFile:path atomically:YES];
}

+ (void)insertCurrentExchangeRate:(NSDictionary *)dic withPath:(NSString *)path {
    NSMutableDictionary *dictionary = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
    if (dictionary == nil) {
        dictionary = [NSMutableDictionary dictionary];
    }
    
    for (NSString *key in dic.allKeys) {
        NSString *value = [dic valueForKey:key];
        [dictionary setValue:value forKey:key];
    }
    
    [dictionary writeToFile:path atomically:YES];
}


+ (NSArray *)getDefaultCurrencies:(NSString *)path {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [dic valueForKey:@"default"];
}


+ (NSArray *)getCommonCurrencies:(NSString *)path {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [dic valueForKey:@"common"];
}


+ (NSString *)getExchangeRate:(NSString *)abbreviation withPath:(NSString *)path {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [dic valueForKey:abbreviation];
}

@end
