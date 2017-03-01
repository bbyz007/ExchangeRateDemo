//
//  CurrentExchangeRateViewController.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrentExchangeRateViewController.h"

#import "EXRVirtualKeyboard.h"
#import "EXRCurrentExchangeRateCell.h"
#import "EXRCurrentExchangeRateCell+Currency.h"
#import "EXRCurrency.h"
#import "EXRCurrentService.h"
#import "EXRHistoricalService.h"
#import "EXRCustomTextField.h"
#import "EXRCustomTextField+Formatter.h"

#import "EXRCurrenciesChosenViewController.h"
#import "EXRHistoricalDataViewController.h"
#import "EXRBaseNavigationController.h"

#import "EXRCustomDismissTransition.h"
#import "EXRCustomPresentTransition.h"

static const CGFloat keyboardHeithScale = 0.4f;
static const CGFloat cellHeightOffset = 0.3f;               //当地货币的cell比其它cell高
static const CGFloat defaultAmount = 100.0f;
static const NSInteger defaultUpdateInterval = 600;         //汇率自动更新时间间隔
static const CGFloat indicatorCenterOffsetY = 0.05f;
static const CGFloat animateDurationTime = 0.1f;
static const NSInteger defaultStrLength = 13;


@interface EXRCurrentExchangeRateViewController () <EXRVirtualKeyboardDelegate, UITableViewDelegate, UITableViewDataSource, EXRCurrentExchangeRateCellDelegate, EXRCurrenciesChosenViewControllerDelegate, EXRHistoricalDataViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) EXRVirtualKeyboard *keyboard;                //虚拟键盘
@property (copy, nonatomic) NSArray<EXRCurrency *> *currencies;
@property (strong, nonatomic) EXRCurrentExchangeRateCell *editCell;
@property (strong, nonatomic) EXRCurrentExchangeRateCell *changeCell;
@property (strong, nonatomic) NSIndexPath *editCellIndexPath;

@property (assign, nonatomic) BOOL changeCurrency;
@property (assign, nonatomic) BOOL historicalDetail;
@property (assign, nonatomic) BOOL initSucc;

@property (copy, nonatomic) NSArray *calculateChar;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSTimer *timer;

//金额textField属性
@property (copy, nonatomic) NSNumberFormatter *formatter;               //小数点格式
@property (assign, nonatomic) NSInteger decimalsNumber;

//自定义转场动画
@property (strong, nonatomic) EXRCustomDismissTransition *dismissTransition;
@property (strong, nonatomic) EXRCustomPresentTransition *presentTransition;

@end

@implementation EXRCurrentExchangeRateViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self p_setUp];
    [self p_loadData];
    [self p_createTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_changeCell) {
        [self p_recoverChangeCell];
        self.changeCurrency = NO;
    }
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (void)p_setUp {
    self.navigationItem.title = @"极简汇率";
    self.calculateChar = @[@"+", @"−", @"×", @"÷"];
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    
    self.tableView.tableFooterView = self.keyboard;
    self.tableView.bounces = NO;
    self.tableView.delaysContentTouches = NO;
}


#pragma mark - data

- (void)p_loadData {
    [self p_getData];
    [EXRHistoricalService getDefualtCurrenciesHistoricalExchangeRate];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    EXRCurrentExchangeRateCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    _editCell = cell;
    [_editCell.amount becomeFirstResponder];

    [self p_updateCellPlaceHolder];
}

- (void)p_getData {
    self.currencies = [EXRCurrentService getCurrencies];
    EXRCurrency *currency = [_currencies firstObject];
    if ([currency.placeHolder floatValue] > 0) {
        self.initSucc = YES;
        [self p_updateCellPlaceHolder];
    } else {
        self.initSucc = NO;
        [self p_getCurrentExchangeRate];
    }
}

- (void)p_getCurrentExchangeRate {
    [self.indicator startAnimating];
    
    [EXRCurrentService getCurrentExchangeRate:self.currencies withCompletionHandler:^(NSDictionary *dic) {
        [_indicator stopAnimating];
        if (_changeCurrency || _historicalDetail) {
            return;
        }
        
        for (EXRCurrency *currency in self.currencies) {
            NSString *value = [dic objectForKey:currency.abbreviation];
            if (value != nil) {
                currency.placeHolder = value;
            }
        }
        [self p_updateCellPlaceHolder];
        
    } withFailedHandler:^(NSString *error) {
        [_indicator stopAnimating];
        
        if (!_initSucc) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self p_getCurrentExchangeRate];
            });
        }
    }];
}

- (void)p_getCurrentExchangeRateImmediate {
    [self p_getCurrentExchangeRate];
}

#pragma mark - timer

- (void)p_createTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:defaultUpdateInterval target:self selector:@selector(p_getCurrentExchangeRateImmediate) userInfo:nil repeats:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_timer fire];
    });
}

#pragma mark - others

- (void)p_recoverChangeCell {
    [self.tableView selectRowAtIndexPath:_editCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [_editCell.amount becomeFirstResponder];
    
    CGPoint center = CGPointMake(self.view.center.x, self.changeCell.center.y);
    [UIView animateWithDuration:animateDurationTime * 5 delay:animateDurationTime usingSpringWithDamping:0.5f initialSpringVelocity:5.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.changeCell.center = center;
    } completion:nil];
    
    [self p_getData];
}

- (NSString *)p_removeCommaSepatator:(NSString *)string {
    return [string stringByReplacingOccurrencesOfString:@"," withString:@""];
}

#pragma mark - calculate exchange rate

//根据编辑cell输入的金额，计算其它cell对应的金额
- (void)p_updateExchangeRate {
    if (_editCell.amount.text.length) {
        NSString *str = _editCell.amount.text;
        double value = [[self p_removeCommaSepatator:str] doubleValue];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:_editCell];
        double rate1 = [_currencies[indexPath.row].placeHolder doubleValue];
        
        for (EXRCurrentExchangeRateCell *cell in self.tableView.visibleCells) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            double rate2 = [_currencies[indexPath.row].placeHolder doubleValue];
            double newValue = value;
            if (rate1 > 0) {
                newValue = rate2 / rate1 * value;
            }
            
            if (cell != _editCell) {
                if (fabs(newValue) < 1 && fabs(newValue) >= 0.0001) {
                    self.formatter.positiveFormat = @"0.0000";
                } else {
                    self.decimalsNumber = _decimalsNumber;
                }
                NSString *str = [self.formatter stringFromNumber:@(newValue)];
                cell.amount.text = [_editCell.amount setStringFormat:str];
            }
            
            [cell labelHiddenSet];
        }
        
    } else {
        for (EXRCurrentExchangeRateCell *cell in self.tableView.visibleCells) {
            cell.amount.text = nil;
            cell.abbreviationLabel.hidden = NO;
            if ([cell.abbreviationLabel.text isEqualToString:@"CNY"]) {
                cell.localIcon.hidden = NO;
            }
        }
    }
}


- (void)p_updateCellPlaceHolder {
    NSIndexPath *index = [self.tableView indexPathForCell:_editCell];
    
    for (EXRCurrentExchangeRateCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (cell == _editCell) {
            cell.amount.placeholder = [NSString stringWithFormat:@"%.0f", defaultAmount];
        } else {
            CGFloat rate1 = [_currencies[indexPath.row].placeHolder floatValue];
            CGFloat rate2 = [_currencies[index.row].placeHolder floatValue];
            CGFloat rate = defaultAmount;
            if (rate2 > 0) {
                rate = rate1 / rate2 * defaultAmount;
            }
            
            self.formatter.positiveFormat = @"0.00";
            NSString *str = [_formatter stringFromNumber:@(rate)];
            cell.amount.placeholder = [cell.amount setStringFormat:str];
        }
    }
    
    [self p_updateExchangeRate];
}


#pragma mark - keyboard delegate

- (void)clickOn:(NSString *)title {
    if ([_calculateChar containsObject:title] || _editCell.calculateTextField.text.length > 0) {
        if (![self p_calculateCanInput:title]) {
            return;
        }
        
        [_editCell.calculateTextField becomeFirstResponder];
        BOOL legalInput = [_editCell.calculateTextField setCalculateTextWith:title];
        if (_editCell.calculateTextField.text.length == 0) {
            [_editCell.amount becomeFirstResponder];
        
        } else if (legalInput) {
            double value = [_editCell.calculateTextField calculateTextValueWithInput:title];
            NSString *str = [_editCell.amount adjustDecimalsWith:[@(value) stringValue]];
            NSInteger num = [_editCell.amount calculateDecimalsNum:str];
            
            if (num < 2 || num > 4) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.positiveFormat = @"0.00";
                if (fabs(value) < 1 && fabs(value) >= 0.0001) {
                    formatter.positiveFormat = @"0.0000";
                }
                str = [formatter stringFromNumber:@([str doubleValue])];
                
            } else {
                self.decimalsNumber = num;
            }

            _editCell.amount.text = [_editCell.amount setStringFormat:str];
            [self p_updateExchangeRate];
            
        } else {
            [_editCell calculateIllegalInput];
        }
        
    } else {
        [self p_withoutOperatorInput:title];
    }
}

- (BOOL)p_calculateCanInput:(NSString *)title {
    BOOL input = YES;
    NSString *str = [self p_removeCommaSepatator:_editCell.amount.text];
    NSInteger num = [_editCell.amount calculateDecimalsNum:str];
    if (num) {
        num++;
    }
    
    if (_editCell.calculateTextField.text.length == 0) {
        if (str.length - num < defaultStrLength) {
            _editCell.calculateTextField.text = [self p_removeCommaSepatator:_editCell.amount.text];
        } else {
            [_editCell amountIllegalInput];
            input = NO;
        }
        
    } else if (str.length - num >= defaultStrLength && title != nil) {
        [_editCell calculateIllegalInput];
        input = NO;
    }
    
    return input;
}

- (void)p_withoutOperatorInput:(NSString *)title {
    BOOL stop = [_editCell.amount legalInput:title];
    
    if (stop) {
        [_editCell amountIllegalInput];
    } else {
        [_editCell.amount textInput:title];
        
        NSRange range = [_editCell.amount.text rangeOfString:@"."];
        NSInteger index = range.length + range.location;
        NSInteger number = _editCell.amount.text.length - index;
        self.decimalsNumber = number;
    }
    
    [self p_updateExchangeRate];
}

- (void)clearTextContent {
    _editCell.amount.text = nil;
    _editCell.calculateTextField.text = nil;
    [_editCell.amount becomeFirstResponder];
    [self p_updateCellPlaceHolder];
}


#pragma mark - cell delegate

- (void)beginEditing:(EXRCurrentExchangeRateCell *)cell {
    if (cell != _editCell) {
        _editCell.calculateTextField.text = nil;
        _editCell = cell;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        _editCellIndexPath = indexPath;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
        
    if (_editCell.amount.text.length == 0) {
        [self p_updateCellPlaceHolder];
    }
}

- (NSNumberFormatter *)endEditingSetFormatter {
    return _formatter;
}

- (void)changeCurrency:(EXRCurrentExchangeRateCell *)cell {
    EXRCurrenciesChosenViewController *exchangeVC = [[EXRCurrenciesChosenViewController alloc] init];
    exchangeVC.delegate = self;
    self.changeCell = cell;
    
    NSMutableArray *array = [NSMutableArray array];
    for (EXRCurrency *currency in _currencies) {
        NSString *str = [currency.name stringByAppendingString:[NSString stringWithFormat:@" %@", currency.abbreviation]];
        if (![currency.abbreviation isEqualToString:cell.abbreviationLabel.text]) {
            [array addObject:str];
        } else {
            exchangeVC.currentCurrencies = str;
        }
    }
    
    exchangeVC.selectCurrencies = array;
    self.changeCurrency = YES;
    [self.navigationController pushViewController:exchangeVC animated:YES];
}

- (void)currencyDetail:(EXRCurrentExchangeRateCell *)cell {
    EXRHistoricalDataViewController *vc = [[EXRHistoricalDataViewController alloc] init];
    self.historicalDetail = YES;
    self.changeCell = cell;
    vc.exchangeCurrency = cell.abbreviationLabel.text;
    vc.delegate = self;
    vc.transitioningDelegate = self;
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - historical delegate

- (void)dismissVC:(EXRHistoricalDataViewController *)vc {
    if (_historicalDetail) {
        [vc dismissViewControllerAnimated:YES completion:nil];
        self.historicalDetail = NO;
        [self p_recoverChangeCell];
    }
}

#pragma mark - transition delegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:[EXRHistoricalDataViewController class]]) {
        return self.dismissTransition;
    }
    return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:[EXRHistoricalDataViewController class]]) {
        return self.presentTransition;
    }
    return nil;
}

#pragma mark - currency chosen  delegate

- (void)chosenCurrency:(EXRCurrency *)currency with:(EXRCurrenciesChosenViewController *)selfVC {
    if (currency != nil) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self.changeCell];
        NSMutableArray *array = [_currencies mutableCopy];
        [array removeObjectAtIndex:indexPath.row];
        [array insertObject:currency atIndex:indexPath.row];
        self.currencies = array;
        [self.changeCell configureWithCurrency:currency];
        
        if (self.changeCell == _editCell) {
            _editCell.amount.text = nil;
            [self p_updateCellPlaceHolder];
        } else {
            [self p_setChangeCurrencyWith:currency];
        }
    }
    
    [selfVC.navigationController popViewControllerAnimated:YES];
}

- (void)p_setChangeCurrencyWith:(EXRCurrency *)currency {
    BOOL succ = NO;
    for (EXRCurrentExchangeRateCell *cell in self.tableView.visibleCells) {
        if (cell.amount.text.length > 0 && cell != self.changeCell) {
            double value = [[self p_removeCommaSepatator:cell.amount.text] doubleValue];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            double rate1 = [_currencies[indexPath.row].placeHolder doubleValue];
            double rate2 = [currency.placeHolder doubleValue];
            double newValue = value;
            if (rate1 > 0) {
                newValue = rate2 / rate1 * value;
            }
            
            if (fabs(newValue) < 1 && fabs(newValue) >= 0.0001) {
                self.formatter.positiveFormat = @"0.0000";
            } else {
                self.decimalsNumber = _decimalsNumber;
            }
            
            NSString *str = [self.formatter stringFromNumber:@(newValue)];
            _changeCell.amount.text = [_editCell.amount setStringFormat:str];
            [self.changeCell labelHiddenSet];
            succ = YES;
        }
        
        if (succ) {
            break;
        }
    }
    
    for (EXRCurrentExchangeRateCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        CGFloat rate1 = [_currencies[indexPath.row].placeHolder floatValue];
        CGFloat rate2 =  [self.changeCell.amount.placeholder floatValue];
        CGFloat value = [cell.amount.placeholder floatValue];
        CGFloat newValue = value;
        if (rate1 > 0) {
            newValue = rate2 / rate1 * value;
        }
        
        NSString *str = [self.formatter stringFromNumber:@(newValue)];
        self.changeCell.amount.placeholder = [_changeCell.amount setStringFormat:str];
        break;
    }
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = (self.tableView.frame.size.height - CGRectGetHeight(self.keyboard.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame)) / (self.currencies.count + cellHeightOffset);
    
    if (_editCellIndexPath == nil) {
        if (indexPath.row == 0) {
            height = height * (1 + cellHeightOffset);
        }
    } else {
        if (_editCellIndexPath.row == indexPath.row) {
            height = height * (1 + cellHeightOffset);
        }
    }
    return height;
}

#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currencies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseTableViewCell = @"reuse_table_view_cell";
    
    EXRCurrentExchangeRateCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseTableViewCell];
    if (cell == nil) {
        cell = [[EXRCurrentExchangeRateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseTableViewCell];
    }
    
    EXRCurrency *currency = _currencies[indexPath.row];
    [cell configureWithCurrency:currency];
    
    cell.delegate = self;
    return cell;
}

#pragma mark - lazy initialization

- (UIActivityIndicatorView *)indicator {
    if (_indicator == nil) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGPoint center = self.tableView.center;
        _indicator.center = CGPointMake(center.x, center.y - indicatorCenterOffsetY * CGRectGetHeight(self.view.frame));
        [self.tableView addSubview:_indicator];
    }
    return _indicator;
}

- (EXRVirtualKeyboard *)keyboard {
    if (_keyboard == nil) {
        _keyboard = [[EXRVirtualKeyboard alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.tableView.frame) * keyboardHeithScale)];
        _keyboard.backgroundColor = UIColorFromRGB(0X999999);
        _keyboard.delegate = self;
    }
    return _keyboard;
}

- (NSNumberFormatter *)formatter {
    if (_formatter == nil) {
        _formatter = [[NSNumberFormatter alloc] init];
        _formatter.positiveFormat = @"0.00";
    }
    return _formatter;
}

- (void)setDecimalsNumber:(NSInteger)decimalsNumber {
    _decimalsNumber = decimalsNumber;
    
    if (_decimalsNumber == 3) {
        self.formatter.positiveFormat = @"0.000";
    } else if (_decimalsNumber == 4) {
        self.formatter.positiveFormat = @"0.0000";
    } else {
        self.formatter.positiveFormat = @"0.00";
    }
}

- (EXRCustomDismissTransition *)dismissTransition {
    if (_dismissTransition == nil) {
        _dismissTransition = [[EXRCustomDismissTransition alloc] init];
    }
    return _dismissTransition;
}

- (EXRCustomPresentTransition *)presentTransition {
    if (_presentTransition == nil) {
        _presentTransition = [[EXRCustomPresentTransition alloc] init];
    }
    return _presentTransition;
}



@end
