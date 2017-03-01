//
//  HistoricalDataViewController.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/12.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRHistoricalDataViewController.h"

#import "EXRHeaderView.h"
#import "EXRChartView.h"
#import "EXRCustomButton.h"
#import "EXRCustomDismissTransition.h"
#import "EXRHistoricalService.h"

@class EXRate;

static const CGFloat headerViewHeightScale = 0.1f;
static const CGFloat headerViewCenterYOffset = 0.3f;
static const CGFloat chartViewHeightScale = 0.65;
static const CGFloat backButtonWidth = 20.0f;
static const CGFloat titleCenterOffsetY = 40.0f;
static const CGFloat titleLableWidth = 100.0f;
static const CGFloat titleLableHeight = 64.0f;
static const NSInteger secondsPerDay = 24 * 60 * 60;
static const NSInteger defaultDatePeriod = 30;

@interface EXRHistoricalDataViewController () <EXRHeaderViewDelegate, EXRChartViewDelegate>

@property (copy, nonatomic) NSString *localCurrency;
@property (strong, nonatomic) EXRHeaderView *headerView;
@property (strong, nonatomic) EXRChartView *chartView;
@property (assign, nonatomic) NSTimeInterval currentTimeInterval;
@property (assign, nonatomic) BOOL isLocal;
@property (assign, nonatomic) BOOL canConverCurrencies;

@end

@implementation EXRHistoricalDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUp];
    [self setSubviews];
    [self setData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUp {
    self.view.backgroundColor = UIColorFromRGBA(0X72B1FF, 0.4);
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:effectView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleLableWidth, titleLableHeight)];
    title.center = CGPointMake(self.view.center.x, titleCenterOffsetY);
    title.textAlignment = NSTextAlignmentCenter;
    [title setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    title.text = @"汇率详情";
    title.textColor = [UIColor whiteColor];
    [self.view addSubview:title];
    
    EXRCustomButton *backButton = [EXRCustomButton buttonWithType:UIButtonTypeSystem];
    [backButton setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, backButtonWidth, backButtonWidth);
    backButton.center = CGPointMake(backButtonWidth, titleCenterOffsetY);
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    EXRCustomButton *questionButton = [EXRCustomButton buttonWithType:UIButtonTypeSystem];
    [questionButton setImage:[UIImage imageNamed:@"helperIcon"] forState:UIControlStateNormal];
    questionButton.frame = CGRectMake(0, 0, backButtonWidth, backButtonWidth);
    questionButton.center = CGPointMake(self.view.frame.size.width - backButtonWidth, titleCenterOffsetY);
    [questionButton setTintColor:[UIColor whiteColor]];
    [questionButton addTarget:self action:@selector(questionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:questionButton];
}

- (void)setSubviews {

    self.headerView = [[EXRHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * headerViewHeightScale) withLocalCurrency:_localCurrency withExchangeCurrency:_exchangeCurrency];
    CGFloat centerY = self.view.center.y - self.view.frame.size.height * headerViewCenterYOffset;
    _headerView.center = CGPointMake(_headerView.center.x, centerY);
    _headerView.delegate = self;
    [self.view addSubview:_headerView];
    
    CGFloat height  = self.view.frame.size.height * chartViewHeightScale;
    self.chartView = [[EXRChartView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)];
    _chartView.delegate = self;
    [self.view addSubview:_chartView];
}

- (void)backButtonAction:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(dismissVC:)]) {
        [self.delegate dismissVC:self];
    }
}

- (void)questionButtonAction:(UIButton *)button {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"数据异常，重新更新？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self resetData];
    }];
    
    __weak typeof(alert) weakAlert = alert;
    UIAlertAction *back = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakAlert.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:delete];
    [alert addAction:back];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - lazy initialization

- (void)setExchangeCurrency:(NSString *)exchangeCurrency {
    if ([exchangeCurrency isEqualToString: self.localCurrency]) {
        _exchangeCurrency = @"USD";
        self.isLocal = YES;
    } else {
        _exchangeCurrency = exchangeCurrency;
    }
}

- (NSString *)localCurrency {
    if (_localCurrency == nil) {
        _localCurrency = @"CNY";
    }
    return _localCurrency;
}


#pragma mark - data 

- (void)setData {
    NSTimeInterval monthTime = defaultDatePeriod *secondsPerDay;
    self.currentTimeInterval = monthTime;
    [self getDataWithTimeInterval:monthTime];
}


- (void)getDataWithTimeInterval:(NSTimeInterval)timeInterval {
    NSDate *endDate = [[NSDate alloc] init];
    NSString *abb = _exchangeCurrency;
    if (_isLocal) {
        abb = _localCurrency;
    }
    self.canConverCurrencies = NO;

    [EXRHistoricalService getDateOfCurrency:abb WithEndDate:endDate withTimeInterval:timeInterval withCompletionHandler:^(NSArray<EXRate *> *dataArray, NSTimeInterval time) {
        [self getDataSuccWithTimeInterval:time withDateArray:dataArray];
        
    } withFailedHandler:^(NSString *error, NSTimeInterval time) {
        [self getDataSuccWithTimeInterval:time withDateArray:nil];
    }];
}

- (void)getDataSuccWithTimeInterval:(NSTimeInterval)time withDateArray:(NSArray<EXRate *> *)dataArray {
    if (_currentTimeInterval == time) {
        NSDate *date = [[NSDate alloc] init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *endDate =[formatter stringFromDate:date];
        
        EXRate *rate = [EXRHistoricalService getCurrentRateWithLocaCurrency:_localCurrency withExchangeCurrency:_exchangeCurrency withDate:endDate];
        
        NSMutableArray<EXRate *> *array = [dataArray mutableCopy];
        if (rate != nil) {
            [array insertObject:rate atIndex:0];
        }
        
        [self updateChartViewWith:array];
    }
}


- (void)updateChartViewWith:(NSArray<EXRate *> *)array {
    if (_chartView != nil) {
        _chartView.dataArray = array;
        self.canConverCurrencies = YES;
    }
}

- (void)resetData {
    [_chartView resetDataAction];
    [EXRHistoricalService resetCurrency:_exchangeCurrency];
    [self getDataWithTimeInterval:_currentTimeInterval];
}


#pragma mark - chart view delegate

- (void)changeHistoricalPeriod:(NSInteger)timeIntevral {
    NSTimeInterval time = timeIntevral * secondsPerDay;
    self.currentTimeInterval = time;
    [self getDataWithTimeInterval:time];
}


#pragma mark - header view delegate

- (void)converCurrencies {
    [_chartView convertCurrencies];
}

- (BOOL)canConverCurrencies {
    return _canConverCurrencies;
}



@end
