//
//  ChartView.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/12.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRChartView.h"

#import "EXRCurveView.h"
#import "EXRate.h"

#import <Masonry/Masonry.h>

static const CGFloat periodButtonHeight = 16.0f;
static const CGFloat buttonFontSize = 13.0f;
static const CGFloat constrainToBottomScale = 0.09f;
static const CGFloat curveViewHeightScale = 0.25f;
static const CGFloat presentLabelWidth = 80.0f;
static const CGFloat presentLabelHeight = 38.0f;
static const CGFloat valueLabelFontSize = 12.0f;
static const CGFloat labelPositionYScale = 0.2f;
static const CGFloat selectedPointDiameter = 8.0f;
static const CGFloat lineDashPattern = 3.0f;

typedef NS_ENUM(NSInteger, TouchActionState) {
    TouchActionStateBegin,
    TouchActionStateMoved,
    TouchActionStateEnded
};

@interface EXRChartView () <EXRCurveViewDelegate>

@property (strong, nonatomic) UIButton *weekButton;
@property (strong, nonatomic) UIButton *monthButton;
@property (strong, nonatomic) UIButton *sixMonthsButton;
@property (strong, nonatomic) UIButton *yearButton;
@property (strong, nonatomic) UIButton *threeYearsButton;
@property (strong, nonatomic) UIButton *previousButton;

@property (strong, nonatomic) UILabel *maxLabel;
@property (strong, nonatomic) UILabel *minLabel;
@property (strong, nonatomic) UILabel *currentLabel;
@property (strong, nonatomic) UILabel *noticeLabel;

@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *valueLabel;
@property (strong, nonatomic) CAShapeLayer *dashedLayer;
@property (strong, nonatomic) CAShapeLayer *selectedPoint;

@property (copy, nonatomic) UIColor *defaultFontColor;
@property (strong, nonatomic) EXRCurveView *curve;
@property (assign, nonatomic) BOOL isConvert;
@property (assign, nonatomic) BOOL haveCurve;
@property (copy, nonatomic) NSArray *dataBuffer;
@property (copy, nonatomic) NSArray *positionYArray;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation EXRChartView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setSubviews];
    }
    return self;
}


- (void)setSubviews {
    
    //周期时间段按钮
    self.weekButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_weekButton setTitle:@"7天" forState:UIControlStateNormal];
    [_weekButton setTitleColor:self.defaultFontColor forState:UIControlStateNormal];
    [_weekButton addTarget:self action:@selector(changePeriodAction:) forControlEvents:UIControlEventTouchUpInside];
    _weekButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    [self addSubview:_weekButton];
    
    [_weekButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.frame.size.width / 5);
        make.height.mas_equalTo(periodButtonHeight);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    self.monthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_monthButton setTitle:@"1月" forState:UIControlStateNormal];
    [_monthButton setTitleColor:UIColorFromRGB(0XE6E6E6) forState:UIControlStateNormal];
    [_monthButton addTarget:self action:@selector(changePeriodAction:) forControlEvents:UIControlEventTouchUpInside];
    _monthButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    [self addSubview:_monthButton];
    self.previousButton = _monthButton;

    
    [_monthButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_weekButton);
        make.left.equalTo(_weekButton.mas_right);
        make.top.mas_equalTo(0);
    }];
    
    self.sixMonthsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sixMonthsButton setTitle:@"6月" forState:UIControlStateNormal];
    [_sixMonthsButton setTitleColor:self.defaultFontColor forState:UIControlStateNormal];
    [_sixMonthsButton addTarget:self action:@selector(changePeriodAction:) forControlEvents:UIControlEventTouchUpInside];
    _sixMonthsButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    [self addSubview:_sixMonthsButton];
    
    [_sixMonthsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_weekButton);
        make.left.equalTo(_monthButton.mas_right);
        make.top.mas_equalTo(0);
    }];
    
    self.yearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_yearButton setTitle:@"1年" forState:UIControlStateNormal];
    [_yearButton setTitleColor:self.defaultFontColor forState:UIControlStateNormal];
    [_yearButton addTarget:self action:@selector(changePeriodAction:) forControlEvents:UIControlEventTouchUpInside];
    _yearButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    [self addSubview:_yearButton];
    
    [_yearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_weekButton);
        make.left.equalTo(_sixMonthsButton.mas_right);
        make.top.mas_equalTo(0);
    }];
    
    self.threeYearsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_threeYearsButton setTitle:@"3年" forState:UIControlStateNormal];
    [_threeYearsButton setTitleColor:self.defaultFontColor forState:UIControlStateNormal];
    [_threeYearsButton addTarget:self action:@selector(changePeriodAction:) forControlEvents:UIControlEventTouchUpInside];
    _threeYearsButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    [self addSubview:_threeYearsButton];
    
    [_threeYearsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_weekButton);
        make.left.equalTo(_yearButton.mas_right);
        make.top.mas_equalTo(0);
    }];
    
    //最大、最小及当前值label
    self.minLabel = [[UILabel alloc] init];
    _minLabel.textAlignment = NSTextAlignmentCenter;
    _minLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    _minLabel.textColor = self.defaultFontColor;
    [self addSubview:_minLabel];
    
    [_minLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.frame.size.width / 3);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-self.frame.size.height * constrainToBottomScale);
        make.height.mas_equalTo(periodButtonHeight);
    }];
    
    self.currentLabel = [[UILabel alloc] init];
    _currentLabel.textAlignment = NSTextAlignmentCenter;
    _currentLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    _currentLabel.textColor = self.defaultFontColor;
    [self addSubview:_currentLabel];
    
    [_currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_minLabel);
        make.left.equalTo(_minLabel.mas_right);
        make.bottom.equalTo(_minLabel.mas_bottom);
    }];

    self.maxLabel = [[UILabel alloc] init];
    _maxLabel.textAlignment = NSTextAlignmentCenter;
    _maxLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    _maxLabel.textColor = self.defaultFontColor;
    [self addSubview:_maxLabel];
    
    [_maxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_minLabel);
        make.right.mas_equalTo(0);
        make.bottom.equalTo(_minLabel.mas_bottom);
    }];
    
    //加载动画
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:_indicator];
    [_indicator startAnimating];
    
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(0, -self.frame.size.height * curveViewHeightScale / 2));
    }];
    
    //无数据通知
    self.noticeLabel = [[UILabel alloc] init];
    _noticeLabel.text = @"此时间段暂无历史数据,请稍后重试";
    _noticeLabel.hidden = YES;
    _noticeLabel.textColor = [UIColor whiteColor];
    _noticeLabel.font = [UIFont systemFontOfSize:buttonFontSize + 2];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_noticeLabel];
    
    [_noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(-self.frame.size.height * curveViewHeightScale / 2);
        make.height.mas_equalTo(periodButtonHeight);
    }];
}


#pragma mark - draw curve

- (void)setCurveWithMaxValue:(CGFloat)maxValue withMinValue:(CGFloat)minValue {
    if (_dataBuffer.count > 1) {
        if (_curve != nil) {
            [_curve removeFromSuperview];
            self.curve = nil;
        }
        
        CGFloat height = self.frame.size.height * curveViewHeightScale;
        self.curve = [[EXRCurveView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - height * 1.5) / 2, self.frame.size.width, height)];
        _curve.delegate = self;
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *str in _dataBuffer) {
            CGFloat value = [str floatValue];
            value = value - minValue;
            if (value < 0) {
                value = 0;
            }
            [array addObject:@(value)];
        }
        _curve.pointsArray = array;
        _curve.rateSpan = maxValue - minValue;
        _curve.backgroundColor = [UIColor clearColor];
        [self addSubview:_curve];
        [_indicator stopAnimating];
        [_curve startDrawCurve];
        
        self.haveCurve = YES;
        [self.dashedLayer removeFromSuperlayer];
        [self.selectedPoint removeFromSuperlayer];
        [self.layer addSublayer:self.selectedPoint];
        [self.layer addSublayer:self.dashedLayer];
    }
}


- (void)changePeriodAction:(UIButton *)button {
    if (button != _previousButton) {
        [_previousButton setTitleColor:self.defaultFontColor forState:UIControlStateNormal];
        self.previousButton = button;
        [_previousButton setTitleColor:UIColorFromRGB(0XE6E6E6) forState:UIControlStateNormal];
        
        [self resetDataAction];
        
        NSString *title = button.titleLabel.text;
        NSInteger time = 0;
        if ([title isEqualToString:@"7天"]) {
            time = 7;
        } else if ([title isEqualToString:@"1月"]) {
            time = 30;
        } else if ([title isEqualToString:@"6月"]) {
            time = 182;
        } else if ([title isEqualToString:@"1年"]) {
            time = 365;
        } else if ([title isEqualToString:@"3年"]) {
            time = 365 * 3;
        }
        
        if (time > 0 && [self.delegate respondsToSelector:@selector(changeHistoricalPeriod:)]) {
            [self.delegate changeHistoricalPeriod:time];
        }
    }
}

- (void)resetDataAction {
    [_curve removeFromSuperview];
    _noticeLabel.hidden = YES;
    _maxLabel.text = nil;
    _minLabel.text = nil;
    _currentLabel.text = nil;
    self.haveCurve = NO;
    [_indicator startAnimating];
}


- (void)convertCurrencies {
    self.isConvert = !_isConvert;
    if (!_dataBuffer.count) {
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    CGFloat maxValue = 0.0f;
    CGFloat minValue = CGFLOAT_MAX;
    CGFloat currentValue = 0.0f;
    CGFloat val = [[_dataBuffer lastObject] floatValue];
    if (val > 0) {
        currentValue = 1 / val;
    }
    
    for (NSNumber *num in _dataBuffer) {
        CGFloat value = [num floatValue];
        if (value > 0) {
            value = 1 / value;
            if (value > maxValue) {
                maxValue = value;
            }
            if (value < minValue) {
                minValue = value;
            }
            [array addObject:@(value)];
        }
    }
    self.dataBuffer = array;
    
    if (maxValue > 0 && minValue < CGFLOAT_MAX && currentValue > 0) {
        [self setLabelWithMaxValue:maxValue withMinValue:minValue withCurrentValue:currentValue];
        
        self.dataBuffer = array;
        [self setCurveWithMaxValue:maxValue withMinValue:minValue];
    }
}

#pragma mark - curve view delegate

- (void)feedbackPointYArray:(NSArray *)pointYArray {
    self.positionYArray = pointYArray;
}

#pragma mark - touch action


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (!_haveCurve) {
        return;
    }

    UITouch *touch = [touches anyObject];
    [self setLabelWith:touch withState:TouchActionStateBegin];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (!_haveCurve) {
        return;
    }

    UITouch *touch = [touches anyObject];
    [self setLabelWith:touch withState:TouchActionStateMoved];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (!_haveCurve) {
        return;
    }

    UITouch *touch = [touches anyObject];
    [self setLabelWith:touch withState:TouchActionStateEnded];
}


- (void)setLabelWith:(UITouch *)touch withState:(TouchActionState)state {

    CGPoint point = [touch locationInView:self];
    CGFloat value = point.x / self.frame.size.width * (_dataBuffer.count - 1);
    NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.0f", value]];
    NSInteger index = [num integerValue];
    
    if (index < _dataArray.count) {
        EXRate *rate = _dataArray[index];
        self.dateLabel.text = rate.date;
        
        if (index < _dataBuffer.count) {
            NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%0.6f", [_dataBuffer[index] floatValue]]];
            self.valueLabel.text = [num stringValue];
        }
    }
    
    if (state == TouchActionStateEnded) {
        self.dateLabel.hidden = YES;
        self.valueLabel.hidden = YES;
        self.dashedLayer.hidden = YES;
        self.selectedPoint.hidden = YES;
        
    } else {
        CGFloat positionX = point.x;
        if (positionX < presentLabelWidth / 2) {
            positionX = presentLabelWidth / 2;
        } else if (positionX > self.frame.size.width - presentLabelWidth / 2) {
            positionX = self.frame.size.width - presentLabelWidth / 2;
        }
        
        self.dateLabel.center =  CGPointMake(positionX, self.dateLabel.center.y);
        self.valueLabel.center = CGPointMake(positionX, self.valueLabel.center.y);
        
        //dashed line
        positionX = 0;
        if (_dataArray.count > 0) {
            CGFloat proportion = index * 1.0 / (_dataArray.count - 1);
            positionX = proportion * self.frame.size.width;
            if (positionX == 0) {
                positionX = 1.0f;
            } else if (positionX >= self.frame.size.width) {
                positionX = self.frame.size.width - 1;
            }
        }
        
        CGFloat positionY = 0;
        if (index < _positionYArray.count) {
            CGFloat value = [_positionYArray[index] floatValue];
            positionY = CGRectGetMinY(_curve.frame) + value;
        } else {
            positionY = [[_positionYArray lastObject] floatValue] + CGRectGetMinY(_curve.frame);
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.selectedPoint.position = CGPointMake(positionX, positionY);
        self.dashedLayer.position = CGPointMake(positionX, self.dashedLayer.position.y);
        [CATransaction commit];
        
        if (state == TouchActionStateBegin) {
            self.dateLabel.hidden = NO;
            self.valueLabel.hidden = NO;
            self.dashedLayer.hidden = NO;
            self.selectedPoint.hidden = NO;
        }
    }
}


#pragma mark - lazy initialization

- (UIColor *)defaultFontColor {
    if (_defaultFontColor == nil) {
        _defaultFontColor = UIColorFromRGBA(0XE6E6E6, 0.3);
    }
    return _defaultFontColor;
}

- (void)setDataArray:(NSArray<EXRate *> *)dataArray {
    if (dataArray == nil) {
        self.dataBuffer = nil;
        _dataArray = nil;
        [_indicator stopAnimating];
        _noticeLabel.hidden = NO;
        self.haveCurve = NO;
        return;
    }
    
    NSMutableArray<EXRate *> *adjustArray = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    CGFloat maxValue = 0.0f;
    CGFloat minValue =  CGFLOAT_MAX;
    
    for (EXRate *obj in dataArray) {
        if (obj.rate > maxValue) {
            maxValue = obj.rate;
        }
        if (obj.rate < minValue) {
            minValue = obj.rate;
        }
        [array insertObject:@(obj.rate) atIndex:0];
        [adjustArray insertObject:obj atIndex:0];
    }
    
    CGFloat currentValue = [adjustArray lastObject].rate;
    
    if (maxValue > 0 && minValue < CGFLOAT_MAX && currentValue > 0) {
        [self setLabelWithMaxValue:maxValue withMinValue:minValue withCurrentValue: currentValue];
        
        _dataArray = [adjustArray copy];
        self.dataBuffer = array;
        
        if (_isConvert) {
            self.isConvert = NO;
            [self convertCurrencies];
        } else {
            [self setCurveWithMaxValue:maxValue withMinValue:minValue];
        }
    }
}


- (UILabel *)valueLabel {
    if (_valueLabel == nil) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.bounds = CGRectMake(0, 0, presentLabelWidth, presentLabelHeight);
        _valueLabel.center = CGPointMake(presentLabelWidth / 2, self.frame.size.height * labelPositionYScale);
        _valueLabel.font = [UIFont systemFontOfSize:valueLabelFontSize];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.textColor = [UIColor whiteColor];
        [self addSubview:_valueLabel];
    }
    return _valueLabel;
}

- (UILabel *)dateLabel {
    if (_dateLabel == nil) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.bounds = CGRectMake(0, 0, presentLabelWidth, presentLabelHeight);
        _dateLabel.center = CGPointMake(presentLabelWidth / 2, self.frame.size.height * labelPositionYScale - presentLabelHeight / 2);
        _dateLabel.font = [UIFont systemFontOfSize:valueLabelFontSize];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.textColor = self.defaultFontColor;
        [self addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (CAShapeLayer *)dashedLayer {
    if (_dashedLayer == nil) {
        _dashedLayer = [CAShapeLayer layer];
        CGFloat height = (CGRectGetHeight(self.frame) * (1 - constrainToBottomScale) - periodButtonHeight) - CGRectGetMaxY(self.valueLabel.frame) - lineDashPattern;
        _dashedLayer.bounds = CGRectMake(0, 0, 1, height);
        _dashedLayer.position = CGPointMake(0.5, CGRectGetMaxY(_valueLabel.frame) + height / 2);
        [_dashedLayer setStrokeColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor];
        [_dashedLayer setLineWidth:0.5];
        [_dashedLayer setLineDashPattern:@[@(lineDashPattern), @(lineDashPattern)]];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(1, 0)];
        [path addLineToPoint:CGPointMake(1, height)];
        _dashedLayer.path = path.CGPath;
        
        _dashedLayer.hidden = YES;
        [self.layer addSublayer:_dashedLayer];
    }
    return _dashedLayer;
}


- (CAShapeLayer *)selectedPoint {
    if (_selectedPoint == nil) {
        _selectedPoint = [CAShapeLayer layer];
        _selectedPoint.frame = CGRectMake(0, 0, selectedPointDiameter, selectedPointDiameter);
        [_selectedPoint setFillColor:[UIColor whiteColor].CGColor];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, selectedPointDiameter, selectedPointDiameter)];
        _selectedPoint.path = path.CGPath;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(0, 0, selectedPointDiameter * 2, selectedPointDiameter * 2);
        layer.position = CGPointMake(selectedPointDiameter / 2, selectedPointDiameter / 2);
        [layer setFillColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor];
        
        UIBezierPath *outCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, selectedPointDiameter * 2, selectedPointDiameter * 2)];
        layer.path = outCircle.CGPath;
        
        [_selectedPoint addSublayer:layer];
        _selectedPoint.hidden = YES;
        [self.layer addSublayer:_selectedPoint];
    }
    return _selectedPoint;
}

- (void)setLabelWithMaxValue:(CGFloat)maxValue withMinValue:(CGFloat)minValue withCurrentValue:(CGFloat)currentValue {
    NSDecimalNumber *max = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.6f", maxValue]];
    _maxLabel.text = [NSString stringWithFormat:@"最高:%@", max];
    NSDecimalNumber *current = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.6f", currentValue]];
    _currentLabel.text = [NSString stringWithFormat:@"当前:%@", current];
    NSDecimalNumber *min = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.6f", minValue]];
    _minLabel.text = [NSString stringWithFormat:@"最低:%@", min];
}


@end
