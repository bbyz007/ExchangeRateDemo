//
//  AFClient.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/11.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRAFClient.h"

@implementation EXRAFClient

+ (instancetype)shareClient {
    static EXRAFClient *_shareClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareClient = [[EXRAFClient alloc] init];
        _shareClient.responseSerializer = [AFJSONResponseSerializer serializer];
        [_shareClient.requestSerializer setTimeoutInterval:8.0f];
    });
    return _shareClient;
}

@end
