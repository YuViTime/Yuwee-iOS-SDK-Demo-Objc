//
//  YuviTimeRecentCallCell.h
//  YuViTime
//
//  Created by Mac-1 on 7/10/17.
//  Copyright © 2017 satabdi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CallHistoryCellButtonCallBackEvent <NSObject>

- (void)btnCallHistoryCellClickedFromCell:(UIButton*)btnSender ofIndexPathObject:(NSIndexPath*)indexPath;

- (void)btnJoinOngoingCallClickedFromCell:(UIButton*)btnSender ofIndexPathObject:(NSIndexPath*)indexPath;

- (void)btnSelectCallHistoryClickedFromCell:(UIButton*)btnSender ofIndexPathObject:(NSIndexPath*)indexPath;

@end

@interface YuviTimeRecentCallCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewCallType;
@property (weak ,nonatomic) id <CallHistoryCellButtonCallBackEvent> delegate;
@property (strong ,nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIButton *btnJoinOngoingCall;
@property (weak, nonatomic) IBOutlet UIButton *btnVideoCall;
@property (weak, nonatomic) IBOutlet UIButton *btnAudioCall;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCallHistory;
@property (weak, nonatomic) NSLayoutConstraint *layoutConstraintForWidthOfCheckBox;
- (IBAction)btnCallClicked:(UIButton *)sender;
- (IBAction)btnJoinOngoingCallClicked:(UIButton *)sender;
- (IBAction)btnSelectCallHistoryClicked:(UIButton *)sender;


@end
