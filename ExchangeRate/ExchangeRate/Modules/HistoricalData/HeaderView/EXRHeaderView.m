//
//  HeaderView.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/12.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRHeaderView.h"

#import <Masonry/Masonry.h>


static const CGFloat abbreviationToIconScale = 0.05f;
static const CGFloat abbreviationToButtonScale = 0.08f;
static const CGFloat fontScale = 0.3f;
static const CGFloat iconCornerRadius = 5.0f;

@interface EXRHeaderView ()

@property (strong, nonatomic) UILabel *localLabel;
@property (strong, nonatomic) UILabel *exchangeLabel;
@property (strong, nonatomic) UIImageView *localIcon;
@property (strong, nonatomic) UIImageView *exchangeIcon;

@end

@implementation EXRHeaderView


- (instancetype)initWithFrame:(CGRect)frame withLocalCurrency:(NSString *)localAbb withExchangeCurrency:(NSString *)exchangeAbb {
    self = [self initWithFrame:frame];
    if (self) {
        
        CGFloat width = frame.size.width;
        
        UIButton *exchange = [[UIButton alloc] init];
        [exchange setImage:[UIImage imageNamed:@"historicalIcon"] forState:UIControlStateNormal];
        [exchange addTarget:self action:@selector(exchangeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:exchange];
        
        [exchange mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        //本地货币
        self.localLabel = [[UILabel alloc] init];
        _localLabel.font = [UIFont systemFontOfSize:frame.size.height * fontScale];
        _localLabel.text = localAbb;
        _localLabel.textColor = UIColorFromRGB(0XE6E6E6);
        [self addSubview:_localLabel];
        
        [_localLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(exchange.mas_right).with.offset(width * abbreviationToButtonScale);
            make.centerY.mas_equalTo(0);
        }];
        
        self.localIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:localAbb]];
        _localIcon.layer.cornerRadius = iconCornerRadius;
        _localIcon.layer.masksToBounds = YES;
        [self addSubview:_localIcon];
        
        [_localIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(_localLabel.mas_right).with.offset(width * abbreviationToIconScale);
        }];
        
        //汇率换算货币
        self.exchangeLabel = [[UILabel alloc] init];
        _exchangeLabel.font = [UIFont systemFontOfSize:frame.size.height * fontScale];
        _exchangeLabel.text = exchangeAbb;
        _exchangeLabel.textColor = UIColorFromRGB(0XE6E6E6);
        [self addSubview:_exchangeLabel];
        
        [_exchangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(exchange.mas_left).with.offset(-width * abbreviationToButtonScale);
            make.centerY.mas_equalTo(0);
        }];
        
        self.exchangeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exchangeAbb]];
        _exchangeIcon.layer.cornerRadius = iconCornerRadius;
        _exchangeIcon.layer.masksToBounds = YES;
        [self addSubview:_exchangeIcon];
        
        [_exchangeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.equalTo(_exchangeLabel.mas_left).with.offset(-width * abbreviationToIconScale);
        }];
    }
    return self;
}

- (void)exchangeAction:(id)sender {
    BOOL enable = NO;
    if ([self.delegate respondsToSelector:@selector(canConverCurrencies)]) {
        enable = [self.delegate canConverCurrencies];
    }
    
    if (!enable) {
        return;
    }
    
    NSString *bufferAbb = _localLabel.text;
    UIImage *bufferImage = _localIcon.image;
    
    _localLabel.text = _exchangeLabel.text;
    _localIcon.image = _exchangeIcon.image;
    
    _exchangeIcon.image = bufferImage;
    _exchangeLabel.text = bufferAbb;
    
    if ([self.delegate respondsToSelector:@selector(converCurrencies)]) {
        [self.delegate converCurrencies];
    }
}

@end
