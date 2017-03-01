//
//  SearchResultTableViewController.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/21.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRSearchResultTableViewController.h"

static const CGFloat searchTextFieldHeight = 25.0f;
static const CGFloat searchTextFieldOffsetX = 10.0f;
static const CGFloat searchTextFieldWidthScale = 0.8f;
static const CGFloat searchTextFieldFontSize = 12.0f;

@interface EXRSearchResultTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UITextField *searchText;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSArray *filteredArray;
@property (assign, nonatomic) CGFloat keyboardHeight;

@end

@implementation EXRSearchResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self p_setUp];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)p_setUp {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, searchTextFieldHeight, searchTextFieldHeight)];
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:leftView.frame];
    [searchImage setImage:[UIImage imageNamed:@"searchIcon"]];
    [leftView addSubview:searchImage];
    
    self.searchText = [[UITextField alloc] initWithFrame:CGRectMake(searchTextFieldOffsetX, searchTextFieldHeight, (self.view.frame.size.width - searchTextFieldOffsetX) * searchTextFieldWidthScale, searchTextFieldHeight)];
    self.searchText.placeholder = @"请出入货币名称";
    self.searchText.leftView = leftView;
    self.searchText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchText.leftViewMode = UITextFieldViewModeAlways;
    self.searchText.backgroundColor = [UIColor whiteColor];
    self.searchText.layer.cornerRadius = 3.0f;
    self.searchText.font = [UIFont systemFontOfSize:searchTextFieldFontSize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_searchTextChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * (1 - searchTextFieldWidthScale), searchTextFieldHeight)];
    self.cancelButton.center = CGPointMake(CGRectGetMaxX(_searchText.frame) + _cancelButton.frame.size.width / 2, _searchText.center.y);
    self.cancelButton.titleLabel.textColor = [UIColor whiteColor];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont systemFontOfSize:searchTextFieldFontSize + 3]];
    [self.cancelButton addTarget:self action:@selector(p_cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_searchText];
    [_searchText becomeFirstResponder];
    [self.view addSubview:_cancelButton];
    self.view.backgroundColor = self.backgroundColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)p_cancelAction:(UIButton *)button {
    [_searchText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - notification

- (void)p_searchTextChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if (textField.text.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [c] %@", textField.text];
        self.filteredArray = [_dataArray filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredArray = nil;
    }
    
    [self.tableView reloadData];
}

- (void)p_keyboardShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect rect = [(NSValue *)[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardHeight = rect.size.height;
}

#pragma mark - lazt initialization

- (UIColor *)backgroundColor {
    if (_backgroundColor == nil) {
        _backgroundColor = UIColorFromRGB(0X455064);
    }
    return _backgroundColor;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        CGRect rect = CGRectMake(0, CGRectGetMaxY(_searchText.frame) + 5, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_searchText.frame) - _keyboardHeight);
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _tableView.backgroundColor = self.backgroundColor;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIndentifier = @"reuse_indentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIndentifier];
    }
    cell.backgroundColor = self.backgroundColor;
    cell.textLabel.text = _filteredArray[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if ([_selectCurrencies containsObject:cell.textLabel.text]) {
        cell.detailTextLabel.text = @"已选择";
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    if ([cell.textLabel.text isEqualToString:_currentCurrencies]) {
        cell.detailTextLabel.text = @"当前选择";
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = _filteredArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(searchCurrency:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate searchCurrency:str];
    }
}



@end
