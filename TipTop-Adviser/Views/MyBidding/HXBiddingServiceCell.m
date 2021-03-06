//
//  HXBiddingServiceCell.m
//  TipTop-Adviser
//
//  Created by ShiCang on 15/11/2.
//  Copyright © 2015年 Outsourcing. All rights reserved.
//

#import "HXBiddingServiceCell.h"
#import "UIButton+WebCache.h"
#import "UIConstants.h"

@implementation HXBiddingServiceCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    _icon.tintColor = selected ? [UIColor orangeColor] : [UIColor lightGrayColor];
    _nameLabel.textColor = selected ? [UIColor orangeColor] : [UIColor darkGrayColor];
    self.backgroundColor = selected ? [UIColor whiteColor] : UIColorWithRGBA(246.0f, 246.0f, 246.0f, 1.0f);
}

#pragma mark - Public Methods
- (void)displayWithService:(HXBiddingService *)service {
    [_icon sd_setImageWithURL:[NSURL URLWithString:service.icon] forState:UIControlStateNormal];
    [_icon sd_setImageWithURL:[NSURL URLWithString:service.iconActive] forState:UIControlStateSelected];
    _nameLabel.text = service.name;
}

@end
