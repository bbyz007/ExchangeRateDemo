//
//  ChosenCustomCell.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/10.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRChosenCustomCell.h"

#import "EXRCustomView.h"

#import <Masonry/Masonry.h>

static const CGFloat constrainToMargins = 15.0f;


@implementation EXRChosenCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self p_setContentView];
    }
    return self;
}


- (void)p_setContentView {
    
    //名称及简称
    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:self.contentView.frame.size.height / 2.5];
    _nameLabel.textColor = UIColorFromRGB(0XE6E6E6);
    [self.contentView addSubview:_nameLabel];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(constrainToMargins);
        make.centerY.mas_equalTo(0);
    }];
    
    //本地标示icon
    self.localIcon = [[UIImageView alloc] init];
    _localIcon.image = [UIImage imageNamed:@"localIcon"];
    _localIcon.hidden = YES;
    [self.contentView addSubview:_localIcon];
    
    [_localIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_right).with.offset(constrainToMargins);
        make.centerY.mas_equalTo(0);
    }];
    
    //选择状态显示label
    self.chosenLable = [[UILabel alloc] init];
    _chosenLable.font = [UIFont systemFontOfSize:self.contentView.frame.size.height / 3];
    _chosenLable.textColor = UIColorFromRGB(0XCCCCCC);
    [self.contentView addSubview:_chosenLable];
    
    [_chosenLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-constrainToMargins);
        make.centerY.mas_equalTo(0);
    }];
    
    //分割线
    self.separatorLine = [[EXRCustomView alloc] init];
    [_separatorLine setPersistentBackgroundColor:[UIColor grayColor]];
    [self.contentView addSubview:_separatorLine];
    
    [_separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(constrainToMargins);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(0);
    }];
}


- (void)prepareForReuse {
    [super prepareForReuse];
    self.separatorLine.hidden = NO;
    self.chosenLable.text = nil;
    self.localIcon.hidden = YES;
    self.nameLabel.text = nil;
}

@end
