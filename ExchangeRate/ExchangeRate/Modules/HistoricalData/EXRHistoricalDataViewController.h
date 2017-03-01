//
//  HistoricalDataViewController.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/12.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRBaseViewController.h"

@class EXRHistoricalDataViewController;

@protocol EXRHistoricalDataViewControllerDelegate <NSObject>

@optional
- (void)dismissVC:(EXRHistoricalDataViewController *)vc;

@end

@interface EXRHistoricalDataViewController : EXRBaseViewController

@property (copy, nonatomic) NSString *exchangeCurrency;

@property (weak, nonatomic) id<EXRHistoricalDataViewControllerDelegate> delegate;

@end
