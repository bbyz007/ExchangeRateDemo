//
//  CurrenciesChosenViewController.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/8.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCurrenciesChosenViewController.h"

#import "EXRCurrency.h"
#import "EXRChosenService.h"
#import "EXRChosenCustomCell.h"
#import "EXRCustomView.h"
#import "EXRCustomDismissTransition.h"
#import "EXRSearchResultTableViewController.h"

static const CGFloat tableViewCellHeight = 45.0f;
static const CGFloat headerSectionHeight = 30.0f;
static const CGFloat constrainToMargins = 18.0f;

@interface EXRCurrenciesChosenViewController () <EXRSearchResultTableViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (copy, nonatomic) NSArray *currencies;
@property (copy, nonatomic) NSArray *sections;
@property (copy, nonatomic) NSArray *sectionIndexs;

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIView *selectBackgroundView;
@property (strong, nonatomic) EXRCustomDismissTransition *dismissTransition;

@end

@implementation EXRCurrenciesChosenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self p_setUp];
    [self p_loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)p_setUp {
    self.navigationItem.title = @"切换货币";
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-100, 0) forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = self.backgroundColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(p_searchAction:)];
    
    self.tableView.backgroundColor = self.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexColor = UIColorFromRGB(0X0080FF);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
}


- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
}


- (void)p_searchAction:(UIBarButtonItem *)button {
    EXRSearchResultTableViewController *filteredVC = [[EXRSearchResultTableViewController alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    if (_currencies.count > 3) {
        for (NSInteger index = 3; index < _currencies.count; index++) {
            id obj = _currencies[index];
            if ([obj isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:obj];
            }
        }
    }
    filteredVC.dataArray = array;
    filteredVC.selectCurrencies = _selectCurrencies;
    filteredVC.currentCurrencies = _currentCurrencies;
    filteredVC.delegate = self;
    filteredVC.transitioningDelegate = self;
    
    [self presentViewController:filteredVC animated:YES completion:nil];
}

#pragma mark - data

- (void)p_loadData {
    [[EXRChosenService class] getCurrenciesWithCompletionHandler:^(NSArray *currencies, NSArray *sections) {
        self.currencies = currencies;
        self.sections = sections;
    }];
}


#pragma mark - lazy initialization

- (NSArray *)sectionIndexs {
    if (_sectionIndexs.count == 0) {
        NSMutableArray *array = [@[@"#", @"$"] mutableCopy];
        
        for (NSString *str in _sections) {
            if (str.length < 2) {
                [array addObject:str];
            }
        }
        _sectionIndexs = [array copy];
    }
    return _sectionIndexs;
}

- (UIColor *)backgroundColor {
    if (_backgroundColor == nil) {
        _backgroundColor = UIColorFromRGB(0X455064);
    }
    return _backgroundColor;
}

- (EXRCustomDismissTransition *)dismissTransition {
    if (_dismissTransition == nil) {
        _dismissTransition = [[EXRCustomDismissTransition alloc] init];
    }
    return _dismissTransition;
}


#pragma mark - search result delegate

- (void)searchCurrency:(NSString *)info {
    [self p_selectCurrency:info];
}


#pragma mark - transition delegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:[EXRSearchResultTableViewController class]]) {
        return self.dismissTransition;
    }
    return nil;
}



#pragma mark - table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifierCell = @"reuse_identifier_cell";
    
    EXRChosenCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierCell];
    if (cell == nil) {
        cell = [[EXRChosenCustomCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifierCell];
    }
    
    NSArray *array = _currencies[indexPath.section];
    cell.nameLabel.text = array[indexPath.row];
    cell.backgroundColor = self.backgroundColor;
    
    if (indexPath.row == array.count - 1) {
        cell.separatorLine.hidden = YES;
    }
    
    if ([_selectCurrencies containsObject:cell.nameLabel.text]) {
        cell.chosenLable.text = @"已选择";
    }
    
    if ([cell.nameLabel.text isEqualToString:@"人民币 CNY"]) {
        cell.localIcon.hidden = NO;
    }
    
    if ([cell.nameLabel.text isEqualToString:_currentCurrencies]) {
        cell.chosenLable.text = @"当前选择";
    }
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = _currencies[section];
    return array.count;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}


- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    EXRChosenCustomCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (_selectBackgroundView == nil) {
        self.selectBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        _selectBackgroundView.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, cell.contentView.frame.size.width, cell.frame.size.height - 0.5)];
        view.backgroundColor = UIColorFromRGB(0X455056);
        [_selectBackgroundView addSubview:view];
    }
    cell.selectedBackgroundView = _selectBackgroundView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EXRChosenCustomCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self p_selectCurrency:cell.nameLabel.text];
}

- (void)p_selectCurrency:(NSString *)info {
    if ([_selectCurrencies containsObject:info]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    if (info.length > 3) {
        NSString *abbreviation = [info substringFromIndex:info.length - 3];
        EXRCurrency *currency = [[EXRCurrency alloc] initWithCurrencyAbbreviation:abbreviation];
        
        if (![info isEqualToString: _currentCurrencies]) {
            [EXRChosenService updateCommonCurrencies:abbreviation];
            if (_currentCurrencies.length > 3) {
                NSString *previous = [_currentCurrencies substringFromIndex:_currentCurrencies.length - 3];
                [EXRChosenService updateDefaultCurrencies:previous withNew:abbreviation];
            }
        } else {
            currency = nil;
        }
        
        if ([self.delegate respondsToSelector:@selector(chosenCurrency:with:)]) {
            [self.delegate chosenCurrency:currency with:self];
        }
    }
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return headerSectionHeight;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionIndexs;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat width = self.tableView.frame.size.width;
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, headerSectionHeight)];
    sectionView.backgroundColor = self.backgroundColor;

    if (section) {
        width -= constrainToMargins;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, headerSectionHeight)];
    view.backgroundColor = UIColorFromRGB(0X333333);
    
    UILabel *label = [[UILabel alloc] initWithFrame:UIEdgeInsetsInsetRect(sectionView.frame, UIEdgeInsetsMake(0, constrainToMargins, 0, 0))];
    label.text = _sections[section];
    label.textColor = UIColorFromRGB(0XE6E6E6);
    label.font = [UIFont systemFontOfSize:sectionView.frame.size.height / 2];
    
    [view addSubview:label];
    [sectionView addSubview:view];
    return sectionView;
}



@end
