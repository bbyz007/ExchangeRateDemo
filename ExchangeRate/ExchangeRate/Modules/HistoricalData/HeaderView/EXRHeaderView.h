//
//  HeaderView.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/12.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EXRHeaderViewDelegate <NSObject>

@optional
- (void)converCurrencies;
- (BOOL)canConverCurrencies;

@end

@interface EXRHeaderView : UIView

@property (weak, nonatomic) id<EXRHeaderViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame withLocalCurrency:(NSString *)localAbb withExchangeCurrency:(NSString *)exchangeAbb;

@end
