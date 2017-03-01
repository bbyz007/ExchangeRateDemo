//
//  AFClient.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/11.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface EXRAFClient : AFHTTPSessionManager

+ (instancetype)shareClient;

@end
