//
//  CurrenciesChosenViewController.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/8.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EXRCurrency;
@class EXRCurrenciesChosenViewController;

@protocol EXRCurrenciesChosenViewControllerDelegate <NSObject>

@optional
- (void)chosenCurrency:(EXRCurrency *)currency with:(EXRCurrenciesChosenViewController *)selfVC;

@end

@interface EXRCurrenciesChosenViewController : UITableViewController

@property (copy, nonatomic) NSArray *selectCurrencies;
@property (copy, nonatomic) NSString *currentCurrencies;

@property (weak, nonatomic) id<EXRCurrenciesChosenViewControllerDelegate> delegate;

@end
