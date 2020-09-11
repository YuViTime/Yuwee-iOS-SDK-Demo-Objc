//
//  YuviTimeScheduledCell.m
//  YuViTime
//
//  Created by Mac-1 on 7/10/17.
//  Copyright © 2017 satabdi. All rights reserved.
//

#import "YuviTimeScheduledCell.h"

@implementation YuviTimeScheduledCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btnScheduledCallUser.layer.cornerRadius = CGRectGetWidth(self.btnScheduledCallUser.frame)/2;
    
    self.btnScheduleJoin.layer.cornerRadius = 15;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (IBAction)btnScheduleCallHistoryCellClickedFromCell:(UIButton *)sender {
    
     [self.delegate btnScheduleCallHistoryCellClickedFromCell:sender ofIndexPathObject:_indexPath];
}

@end
