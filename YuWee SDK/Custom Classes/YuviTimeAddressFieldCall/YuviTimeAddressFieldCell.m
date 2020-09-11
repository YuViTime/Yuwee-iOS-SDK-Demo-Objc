//
//  YuviTimeAddressFieldCell.m
//  YuViTime
//
//  Created by Mac-1 on 7/25/17.
//  Copyright © 2017 DAT-Asset-158. All rights reserved.
//

#import "YuviTimeAddressFieldCell.h"

#define kAmpleSoftFontName @"AmpleSoft"

@implementation YuviTimeAddressFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width / 2;
    self.imgClose.layer.cornerRadius = self.imgClose.frame.size.width / 2;
    
    _lblEmail.font = [UIFont fontWithName:kAmpleSoftFontName size:18];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
