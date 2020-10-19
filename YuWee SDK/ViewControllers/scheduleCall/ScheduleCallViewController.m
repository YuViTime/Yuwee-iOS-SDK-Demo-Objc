//
//  ScheduleCallViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 18/02/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "ScheduleCallViewController.h"
#import <YuWeeSDK/Yuwee.h>
#import "CallController.h"
#import "CallViewController.h"
#import "YuviTimeScheduledCell.h"

@interface ScheduleCallViewController () <UITableViewDataSource, UITableViewDelegate, YuWeeScheduleCallManagerDelegate,ScheduleCallHistoryCellButtonCallBackEvent> {
    NSMutableArray* array;
    BOOL isGroupCallEnabled;
    CallParams *objCall;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ScheduleCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self->array = [[NSMutableArray alloc] init];
    [self getScheduleCall];
    [[ScheduleManager sharedInstance] setOnScheduleCallEventsDelegate:self];
}
- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void) getScheduleCall{
    [[[Yuwee sharedInstance] getCallManager] getAllUpcomingCalls:^(BOOL isCallScheduledSuccess, NSDictionary *dictCallScheduleResponse) {
        if (isCallScheduledSuccess) {
            NSLog(@"%@", dictCallScheduleResponse);
            [self->array addObjectsFromArray:dictCallScheduleResponse[@"result"]];
            [self->_tableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = @"scheduleCallCell";
    
    YuviTimeScheduledCell *cellScheduled = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cellScheduled)
        cellScheduled = [[YuviTimeScheduledCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    
    cellScheduled.delegate =(id) self;
    cellScheduled.indexPath = indexPath;
    
    NSDictionary *mDict = [array objectAtIndex:indexPath.row];
    
    cellScheduled.lblUsername.text = mDict[@"schedulerName"];
    
    if ([mDict[@"status"] integerValue] == 2)
        cellScheduled.btnScheduleJoin.hidden = false;
    else{
        cellScheduled.btnScheduleJoin.hidden = true;
        
        cellScheduled.lblDate.text = [NSString stringWithFormat:@"%@ %@", [self getFormattedTimeStringFromUnixTime:[mDict[@"dateOfStart"] doubleValue]], mDict[@"time"]];
    }
    
    cellScheduled.lblDate.hidden = !cellScheduled.btnScheduleJoin.hidden;
    
    return cellScheduled;
}

- (NSString*)getFormattedTimeStringFromUnixTime:(NSTimeInterval)unixTime{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:unixTime / 1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yy"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (void) removeScheduleCall:(NSString*)mID{

}

//This Event is received by each participants just before the reminder duration prior to the scheduled time
- (void)onScheduledCallActivated:(NSDictionary *)dictParameter{
    NSLog(@"%@", dictParameter);
    for (int i = 0; i< array.count; i++) {
        NSMutableDictionary *dict = [[array objectAtIndex:i] mutableCopy];
        if ([[dict[@"schedulerId"] uppercaseString] isEqualToString:[dictParameter[@"schedulerId"] uppercaseString]]) {
            [dict setValue:@"2" forKey:@"status"];
            [array replaceObjectAtIndex:i withObject:dict];
            [self->_tableView reloadData];
            break;
        }
    }
}

//This Event is received by each participants just after the reminder scheduled
- (void)onNewScheduledCall:(NSDictionary *)dictParameter{
    NSLog(@"%@", dictParameter);
    [self->array addObject:dictParameter];
    [self->_tableView reloadData];
}

//This event is received by each participant once a meeting has expired
- (void)onScheduleCallExpired:(NSDictionary *)dictParameter{
    NSLog(@"%@", dictParameter);

    for (int i = 0; i< array.count; i++) {
        NSDictionary *dict = [array objectAtIndex:i];
        if ([[dict[@"schedulerId"] uppercaseString] isEqualToString:[dictParameter[@"schedulerId"] uppercaseString]]) {
            [array removeObjectAtIndex:i];
            break;
        }
    }
    [[self tableView] reloadData];
}

//This event is received by each participant once a meeting has been deleted by the host
- (void)onScheduledCallDeleted:(NSDictionary *)dictParameter{
    NSLog(@"%@", dictParameter);
    
    for (int i = 0; i< array.count; i++) {
        NSDictionary *dict = [array objectAtIndex:i];
        if ([[dict[@"schedulerId"] uppercaseString] isEqualToString:[dictParameter[@"schedulerId"] uppercaseString]]) {
            [array removeObjectAtIndex:i];
            break;
        }
    }
    [[self tableView] reloadData];
}

- (void)btnScheduleCallHistoryCellClickedFromCell:(UIButton*)btnSender ofIndexPathObject:(NSIndexPath*)indexPath{
    
    NSDictionary *upcomingCall = array[indexPath.row];
    
    [[[Yuwee sharedInstance] getCallManager] joinMeeting:upcomingCall[kCallId] withGroup:true GroupId:upcomingCall[kGroupId] ConferenceId:upcomingCall[kConferenceId] MediaType:VIDEO withCompletionHandler:^(NSDictionary *secheduleCallResponse) {
        if (([secheduleCallResponse[kisGroup] boolValue]) && ([secheduleCallResponse[kReceivers] count]>2)) {
            self->isGroupCallEnabled = true;
            self->objCall = [[CallParams alloc] init];
            self->objCall.groupName = secheduleCallResponse[kGroup][kName];
            self->objCall.groupEmailList = secheduleCallResponse[kReceivers];
            [self presentGroupCallScreen:true];
        } else {
            self->isGroupCallEnabled = false;
            self->objCall = [[CallParams alloc] init];
            self->objCall.inviteeEmail = secheduleCallResponse[kEmail];
            [self presentCallScreen:true];
        }
    }];
}

- (void)presentGroupCallScreen:(BOOL)isIncoming{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callControllerVC.isGroupCall = isGroupCallEnabled;
    callControllerVC.strGroupName = objCall.groupName;
    callControllerVC.isIncomingCall = isIncoming;
    callControllerVC.arrMembers = objCall.groupEmailList;
    callControllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
    
    [self presentViewController:navigationController animated:false completion:nil];
}

- (void)presentCallScreen:(BOOL)isIncoming{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallController *callVC = [storyboard instantiateViewControllerWithIdentifier:@"CallController"];
    callVC.isGroupCall = isGroupCallEnabled;
    callVC.isIncomingCall = isIncoming;
    callVC.strEmailAddress = objCall.inviteeEmail;
    callVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callVC];
    
    [self presentViewController:navigationController animated:false completion:nil];
}

@end
