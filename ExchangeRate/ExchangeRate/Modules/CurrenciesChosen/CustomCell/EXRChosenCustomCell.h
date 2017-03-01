//
//  ChosenCustomCell.h
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/10.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EXRCustomView;

@interface EXRChosenCustomCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *chosenLable;
@property (strong, nonatomic) UIImageView *localIcon;
@property (strong, nonatomic) EXRCustomView *separatorLine;

@end
