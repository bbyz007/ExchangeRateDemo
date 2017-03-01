//
//  CurrentExchangeRateCell.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrentExchangeRateCell.h"

#import "EXRCustomTextField.h"
#import "EXRCustomTextField+Formatter.h"
#import "EXRCustomView.h"

#import <Masonry/Masonry.h>

static const CGFloat cornerRadius = 3.0f;
static const CGFloat constrainToMargins = 15.0f;
static const CGFloat flagIconHeightScale = 0.8f;            //国旗图标高度比例：高／cell的高度
static const CGFloat flagIconWidthScale = 1.1f;             //国旗图标宽度比例：宽／高
static const CGFloat abbLabelToFlagIcon = 18.0f;
static const CGFloat localIconToAbbLabel = 8.0f;
static const CGFloat localIconHiddenInterval = 20.0f;
static const CGFloat amountFontScale = 0.63f;
static const CGFloat symbolFontScale = 0.28f;

static const CGFloat animateDurationTime = 0.1f;
static const CGFloat animateOffsetX = 3.0f;

@interface EXRCurrentExchangeRateCell () <UITextFieldDelegate>

@property (strong, nonatomic) CABasicAnimation *animate;
@property (assign, nonatomic) CGFloat textFieldMaxWidth;                //金额textField最长长度
@property (assign, nonatomic) CGFloat abbHiddenWidth;                   //金额textField长度超过该值时，缩写label隐藏
@property (assign, nonatomic) CGFloat localIconHiddenWidth;             //金额textField长度超过该值时，localIcon隐藏

@end

@implementation EXRCurrentExchangeRateCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self p_setContent];
    }
    return self;
}


- (void)p_setContent {
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColorFromRGBA(0XE2EFFF, 0.6);
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_panAction:)];
    [self addGestureRecognizer:pan];
    
    CGFloat height = self.frame.size.height * flagIconHeightScale;
    CGFloat fontSize = self.frame.size.height * amountFontScale;
    
    //金额textField
    self.amount = [[EXRCustomTextField alloc] init];
    _amount.font = [UIFont systemFontOfSize:fontSize];
    _amount.textAlignment = NSTextAlignmentRight;
    _amount.inputView = [UIView new];
    _amount.delegate = self;
    [self.contentView addSubview:_amount];
    
    [_amount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-constrainToMargins);
        make.left.mas_equalTo(-self.contentView.frame.size.width);
    }];
    
    //计算textField
    self.calculateTextField = [[EXRCustomTextField alloc] init];
    _calculateTextField.font = [UIFont systemFontOfSize:fontSize / 2];
    _calculateTextField.inputView = [UIView new];
    _calculateTextField.textColor = [UIColor grayColor];
    _calculateTextField.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_calculateTextField];
    
    [_calculateTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_amount.mas_top).with.offset(0);
        make.right.mas_equalTo(-constrainToMargins);
        make.left.equalTo(_amount.mas_left);
    }];
        
    //国旗
    self.flag = [[UIImageView alloc] init];
    _flag.backgroundColor = [UIColor whiteColor];
    _flag.layer.cornerRadius = cornerRadius;
    _flag.layer.masksToBounds = YES;
    [self.contentView addSubview:_flag];
    
    [_flag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
        make.width.mas_equalTo(height * flagIconWidthScale);
        make.left.mas_equalTo(constrainToMargins);
        make.centerY.mas_equalTo(0);
    }];
    
    //缩写label
    self.abbreviationLabel = [[UILabel alloc] init];
    _abbreviationLabel.font = [UIFont systemFontOfSize:fontSize * 0.8];
    [self.contentView addSubview:_abbreviationLabel];
    
    [_abbreviationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.equalTo(_flag.mas_right).with.offset(abbLabelToFlagIcon);
    }];
    
    //定位图标
    self.localIcon = [[UIImageView alloc] init];
    _localIcon.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_localIcon];
    
    [_localIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.equalTo(_abbreviationLabel.mas_right).with.offset(localIconToAbbLabel);
    }];
    
    //名称和符号
    self.symbolLabel = [[UILabel alloc] init];
    _symbolLabel.font = [UIFont systemFontOfSize:self.frame.size.height * symbolFontScale];
    _symbolLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_symbolLabel];
    
    [_symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_amount.mas_bottom);
        make.right.mas_equalTo(-constrainToMargins);
    }];
    
    //右滑显示
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    EXRCustomView *leftView = [[EXRCustomView alloc] init];
    [leftView setPersistentBackgroundColor: UIColorFromRGB(0X66CCFF)];
    [self.contentView addSubview:leftView];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-width);
        make.size.equalTo(self.contentView);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *leftViewIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exchangeIcon"]];
    [leftView addSubview:leftViewIcon];
    
    [leftViewIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-constrainToMargins);
        make.centerY.mas_equalTo(0);
    }];

    UILabel *leftLable = [[UILabel alloc] init];
    leftLable.text = @"切换货币";
    leftLable.textColor = [UIColor whiteColor];
    leftLable.font = [UIFont systemFontOfSize:fontSize * 0.7];
    [leftView addSubview:leftLable];
    
    [leftLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.equalTo(leftViewIcon.mas_left).with.offset(-constrainToMargins);
    }];
    
    //左滑显示
    EXRCustomView *rightView = [[EXRCustomView alloc] init];
    [rightView setPersistentBackgroundColor: UIColorFromRGB(0X66CCFF)];
    [self.contentView addSubview:rightView];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(width);
        make.size.equalTo(self.contentView);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *rightViewIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailIcon"]];
    [rightView addSubview:rightViewIcon];
    
    [rightViewIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(constrainToMargins);
        make.centerY.mas_equalTo(0);
    }];
    
    UILabel *rightLable = [[UILabel alloc] init];
    rightLable.text = @"汇率详情";
    rightLable.textColor = [UIColor whiteColor];
    rightLable.font = [UIFont systemFontOfSize:fontSize * 0.7];
    [rightView addSubview:rightLable];
    
    [rightLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.equalTo(rightViewIcon.mas_right).with.offset(constrainToMargins);
    }];
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.flag.image = nil;
    self.amount.text = nil;
    self.symbolLabel.text = nil;
    self.abbreviationLabel.text = nil;
    self.localIcon.image = nil;
}

#pragma mark - gesture action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_amount becomeFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (void)p_panAction:(UIPanGestureRecognizer *)pan {
    CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, self.center.y);
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [pan translationInView:self.contentView];
            self.center = CGPointMake(center.x + translation.x, center.y);
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            if (self.center.x - center.x > center.x / 2) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(center.x * 3, center.y);
                } completion:^(BOOL finished) {
                    if ([self.delegate respondsToSelector:@selector(changeCurrency:)]) {
                        [self.delegate changeCurrency:self];
                    }
                }];
                
            } else if (center.x - self.center.x > center.x / 2) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(- center.x, center.y);
                } completion:^(BOOL finished) {
                    if ([self.delegate respondsToSelector:@selector(currencyDetail:)]) {
                        [self.delegate currencyDetail:self];
                    }
                }];

            } else {
                [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:5.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.center = center;
                } completion:nil];
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(beginEditing:)]) {
        NSString *str = self.amount.text;
        if ([str containsString:@"."]) {
            self.amount.text = [self.amount adjustDecimalsWith:str];
        }
        [self.delegate beginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length != 0) {
        
        NSString *str = textField.text;
        if ([str containsString:@","]) {
            str = [self p_removeCommaSepatator:str];
        }
        
        double amount = [str doubleValue];
        if ([self.delegate respondsToSelector:@selector(endEditingSetFormatter)]) {
            NSNumberFormatter *formatter = [self.delegate endEditingSetFormatter];
            NSString *str = [formatter stringFromNumber:@(amount)];
            textField.text = [self.amount setStringFormat:str];
        }
    }
}

#pragma mark - string formatter

- (NSString *)p_removeCommaSepatator:(NSString *)string {
    return [string stringByReplacingOccurrencesOfString:@"," withString:@""];
}

- (void)amountIllegalInput {
    [self.amount.layer addAnimation:self.animate forKey:self.animate.keyPath];
}

- (void)calculateIllegalInput {
    [self.calculateTextField.layer addAnimation:self.animate forKey:self.animate.keyPath];
}

#pragma mark - lable hidden set

- (void)labelHiddenSet {
    self.localIcon.hidden = [self p_shouldHideLocalIcon];
    self.abbreviationLabel.hidden = [self p_shouldHideAbbreviationLabel];
    
    if (self.calculateTextField.layer.mask == nil) {
        [self p_setCalculateMaskLayer];
    }
}

- (BOOL)p_shouldHideAbbreviationLabel {
    BOOL result = NO;
    
    CGFloat width = [self p_calculateStringWidth];
    if (width >= self.abbHiddenWidth) {
        if (width >= self.textFieldMaxWidth) {
            if (self.amount.layer.mask == nil) {
                CGFloat scale = 1 - self.textFieldMaxWidth / self.amount.frame.size.width;
                CAGradientLayer *maskLayer = [CAGradientLayer layer];
                maskLayer.frame = CGRectMake(0, 0, self.amount.frame.size.width, self.amount.frame.size.height);
                [maskLayer setColors:@[(id)[UIColor colorWithWhite:0 alpha:1].CGColor, (id)[UIColor clearColor].CGColor]];
                maskLayer.startPoint = CGPointMake(scale + 0.1, 0);
                maskLayer.endPoint = CGPointMake(scale, 0);
                self.amount.layer.mask = maskLayer;
            }
        }
        result = YES;
    }
    return result;
}

- (BOOL)p_shouldHideLocalIcon {
    BOOL result = NO;
    
    CGFloat width = [self p_calculateStringWidth];
    if (width > self.localIconHiddenWidth) {
        result = YES;
    }
    return result;
}


- (CGFloat)p_calculateStringWidth {
    NSString *str = self.amount.text;
    
    if (self.amount == self.amount) {
        if (![self.amount.text containsString:@"."]) {
            str = [str stringByAppendingString:@".00"];
            
        } else {
            NSRange range = [self.amount.text rangeOfString:@"."];
            NSInteger index = range.length + range.location;
            
            if (index == self.amount.text.length - 1) {
                str = [str stringByAppendingString:@"0"];
            } else if (index == self.amount.text.length) {
                str = [str stringByAppendingString:@"00"];
            }
        }
    }
    
    UIFont *font = self.amount.font;
    CGSize size = [str boundingRectWithSize:self.amount.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
    
    return size.width;
}


- (void)p_setCalculateMaskLayer {
    CGFloat scale = 1 - self.textFieldMaxWidth / self.amount.frame.size.width;
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    maskLayer.frame = CGRectMake(0, 0, self.calculateTextField.frame.size.width, self.calculateTextField.frame.size.height);
    [maskLayer setColors:@[(id)[UIColor colorWithWhite:0 alpha:1].CGColor, (id)[UIColor clearColor].CGColor]];
    maskLayer.startPoint = CGPointMake(scale + 0.1, 0);
    maskLayer.endPoint = CGPointMake(scale, 0);
    self.calculateTextField.layer.mask = maskLayer;
}

#pragma mark - lazy initializaiton

- (CGFloat)localIconHiddenWidth {
    if (_localIconHiddenWidth == 0) {
        CGFloat width = CGRectGetWidth(self.contentView.frame);
       _localIconHiddenWidth = width - CGRectGetMaxX(_localIcon.frame) - constrainToMargins - localIconHiddenInterval;
    }
    return _localIconHiddenWidth;
}

- (CGFloat)textFieldMaxWidth {
    if (_textFieldMaxWidth == 0){
        CGFloat width = CGRectGetWidth(self.contentView.frame);
        _textFieldMaxWidth = width - CGRectGetMaxX(_flag.frame) - constrainToMargins * 3;
    }
    return _textFieldMaxWidth;
}

- (CGFloat)abbHiddenWidth {
    if (_abbHiddenWidth == 0) {
        CGFloat width = CGRectGetWidth(self.contentView.frame);
        _abbHiddenWidth = width - CGRectGetMaxX(_abbreviationLabel.frame) - constrainToMargins - localIconHiddenInterval / 2;
    }
    return _abbHiddenWidth;
}


- (CABasicAnimation *)animate {
    if (_animate == nil) {
        _animate = [CABasicAnimation animationWithKeyPath:@"position.x"];
        _animate.fromValue = @(self.amount.layer.position.x - animateOffsetX);
        _animate.toValue = @(self.amount.layer.position.x + animateOffsetX);
        _animate.duration = animateDurationTime;
        _animate.repeatCount = 2;
        _animate.autoreverses = YES;
        _animate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }
    return _animate;
}


@end
