//
//  SearchResultTableViewController.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/21.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRBaseViewController.h"


@protocol EXRSearchResultTableViewControllerDelegate <NSObject>

@optional

- (void)searchCurrency:(NSString *)info;

@end

@interface EXRSearchResultTableViewController : EXRBaseViewController

@property (copy, nonatomic) NSArray *dataArray;
@property (copy, nonatomic) NSArray *selectCurrencies;
@property (copy, nonatomic) NSString *currentCurrencies;

@property (weak, nonatomic) id<EXRSearchResultTableViewControllerDelegate> delegate;

@end
