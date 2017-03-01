//
//  CurrentExchangeRateCell.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRBaseTableViewCell.h"

@class EXRCurrentExchangeRateCell;
@class EXRCustomTextField;

@protocol EXRCurrentExchangeRateCellDelegate <NSObject>

@optional
- (void)beginEditing:(EXRCurrentExchangeRateCell *)cell;
- (NSNumberFormatter *)endEditingSetFormatter;
- (void)changeCurrency:(EXRCurrentExchangeRateCell *)cell;
- (void)currencyDetail:(EXRCurrentExchangeRateCell *)cell;

@end

@interface EXRCurrentExchangeRateCell : EXRBaseTableViewCell

@property (strong, nonatomic) UIImageView *flag;
@property (strong, nonatomic) UILabel *abbreviationLabel;
@property (strong, nonatomic) EXRCustomTextField *amount;
@property (strong, nonatomic) UILabel *symbolLabel;
@property (strong, nonatomic) UIImageView *localIcon;
@property (strong, nonatomic) EXRCustomTextField *calculateTextField;

@property (weak, nonatomic) id<EXRCurrentExchangeRateCellDelegate> delegate;

- (void)labelHiddenSet;
- (void)amountIllegalInput;
- (void)calculateIllegalInput;


@end
