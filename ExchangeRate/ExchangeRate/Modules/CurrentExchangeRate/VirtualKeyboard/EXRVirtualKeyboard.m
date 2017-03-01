//
//  VirtualKeyboard.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRVirtualKeyboard.h"

#import <Masonry/Masonry.h>

static const CGFloat buttonInterval = 0.5f;
static const NSUInteger itemsPerRow = 4;
static const CGFloat fontSizeScale = 0.2f;
static const CGFloat fontSizeOffset = 1.5f;         //算术符号比数字小，用该参数补偿

@interface EXRVirtualKeyboard ()

@property (copy, nonatomic) NSArray<NSString *> *buttons;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) UIImage *selectedBackgroundImage;

@end

@implementation EXRVirtualKeyboard


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _buttons = @[@"7", @"8", @"9", @"+", @"4", @"5", @"6", @"−", @"1", @"2", @"3", @"×", @".", @"0", @"delete", @"÷"];
        
        CGFloat width = (self.frame.size.width - (itemsPerRow - 1)) / itemsPerRow;
        CGFloat heigth = (self.frame.size.height - (itemsPerRow - 1)) / itemsPerRow;
        
        NSUInteger row = 0;
        NSUInteger rank = 0;
        for (NSInteger index = 0; index < _buttons.count; index++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:self.backgroundImage forState:UIControlStateNormal];
            [button setBackgroundImage:self.selectedBackgroundImage forState:UIControlStateHighlighted];
            
            [button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *title = _buttons[index];
            row = index / itemsPerRow;
            rank = index % itemsPerRow;
            
            if (![title isEqualToString:@"delete"]) {
                [button setTitle:title forState:UIControlStateNormal];
                
                if (rank == 3) {
                    button.titleLabel.font = [UIFont systemFontOfSize:width * fontSizeScale * fontSizeOffset];
                } else {
                    button.titleLabel.font = [UIFont systemFontOfSize:width * fontSizeScale];
                }

            } else {
                [button setImage:[UIImage imageNamed:@"deleteIcon"] forState:UIControlStateNormal];
                UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(clearAction:)];
                [button addGestureRecognizer:longGesture];
            }
            
            [self addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(rank * width + rank * buttonInterval);
                make.top.mas_equalTo(row * heigth + row * buttonInterval);
                make.size.mas_equalTo(CGSizeMake(width, heigth));
            }];
        }
    }
    return self;
}


#pragma mark - click delegate

- (void)clickAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickOn:)]) {
        [self.delegate clickOn:sender.titleLabel.text];
    }
}


- (void)clearAction:(UILongPressGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(clearTextContent)]) {
        [self.delegate clearTextContent];
    }
}


#pragma mark - lazy initialization

- (UIImage *)backgroundImage {
    if (_backgroundImage == nil) {
        CGRect rect = CGRectMake(0, 0, 1.0f, 1.0f);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorFromRGBA(0X50638F, 0.6).CGColor);
        CGContextFillRect(context, rect);
        _backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _backgroundImage;
}

- (UIImage *)selectedBackgroundImage {
    if (_selectedBackgroundImage == nil) {
        CGRect rect = CGRectMake(0, 0, 1.0f, 1.0f);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
        CGContextFillRect(context, rect);
        _selectedBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _selectedBackgroundImage;
}

@end
