//
//  VirtualKeyboard.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/5.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EXRVirtualKeyboardDelegate <NSObject>

- (void)clickOn:(NSString *)title;
- (void)clearTextContent;

@end

@interface EXRVirtualKeyboard : UIView

@property (weak, nonatomic) id<EXRVirtualKeyboardDelegate> delegate;

@end
