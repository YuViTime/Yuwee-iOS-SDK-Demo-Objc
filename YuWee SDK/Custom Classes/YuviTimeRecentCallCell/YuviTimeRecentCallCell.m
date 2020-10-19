//
//  YuviTimeRecentCallCell.m
//  YuViTime
//
//  Created by Mac-1 on 7/10/17.
//  Copyright © 2017 satabdi. All rights reserved.
//

#import "YuviTimeRecentCallCell.h"

@implementation YuviTimeRecentCallCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.btnProfilePic.layer.cornerRadius =  self.btnProfilePic.frame.size.width / 2;
    self.btnJoinOngoingCall.layer.cornerRadius = 15;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)btnCallClicked:(UIButton *)sender{
    
    [self.delegate btnCallHistoryCellClickedFromCell:sender ofIndexPathObject:_indexPath];
}

- (IBAction)btnJoinOngoingCallClicked:(UIButton *)sender {
    
     [self.delegate btnJoinOngoingCallClickedFromCell:sender ofIndexPathObject:_indexPath];
}

- (IBAction)btnSelectCallHistoryClicked:(UIButton *)sender {
    
     [self.delegate btnSelectCallHistoryClickedFromCell:sender ofIndexPathObject:_indexPath];
}

@end
