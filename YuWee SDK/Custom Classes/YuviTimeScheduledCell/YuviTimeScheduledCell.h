//
//  YuviTimeScheduledCell.h
//  YuViTime
//
//  Created by Mac-1 on 7/10/17.
//  Copyright © 2017 satabdi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScheduleCallHistoryCellButtonCallBackEvent <NSObject>

- (void)btnScheduleCallHistoryCellClickedFromCell:(UIButton*)btnSender ofIndexPathObject:(NSIndexPath*)indexPath;

@end

@interface YuviTimeScheduledCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblScheduleCallType;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIButton *btnScheduleJoin;
@property (weak, nonatomic) IBOutlet UIButton *btnScheduledCallUser;
@property (weak ,nonatomic) id <ScheduleCallHistoryCellButtonCallBackEvent> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewScheduleTime;
@property (strong ,nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *imgJoinSelected;
- (IBAction)btnScheduleCallHistoryCellClickedFromCell:(UIButton *)sender;

@end
