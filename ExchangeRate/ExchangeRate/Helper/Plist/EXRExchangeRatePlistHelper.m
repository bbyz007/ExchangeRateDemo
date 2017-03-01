//
//  ExchangeRatePlistHelper.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/7.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRExchangeRatePlistHelper.h"

@implementation EXRExchangeRatePlistHelper

+ (NSString *)plistFolder {
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [docsDir stringByAppendingPathComponent:@"Plist"];
    return path;
}

//实时汇率主界面缓存当前汇率数据
+ (NSString *)currentRatePath {
    NSString *path = [[[self class] plistFolder] stringByAppendingPathComponent:@"currentRate.plist"];
    return path;
}


+ (NSString *)currenciesPath {
    NSString *path = [[[self class] plistFolder] stringByAppendingPathComponent:@"currencies.plist"];
    return path;
}

+ (void)buildPlistFile {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[self class] plistFolder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[[self class] plistFolder] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //创建默认显示货币
    NSArray *defaultCurrencies = @[@"CNY", @"USD", @"HKD", @"EUR"];
    NSArray *commonCurrencies = @[@"CNY", @"USD", @"HKD", @"EUR", @"RUB", @"JPY", @"TWD", @"GBP", @"CNH", @"KRW"];
    NSDictionary *currencies = @{
                                 @"default": defaultCurrencies,
                                 @"common": commonCurrencies
                                 };
    
    [currencies writeToFile:[[self class] currenciesPath] atomically:YES];
}




@end
