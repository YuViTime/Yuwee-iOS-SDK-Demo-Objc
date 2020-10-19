//
//  RecentCallViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 18/02/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "RecentCallViewController.h"
#import "YuviTimeRecentCallCell.h"
#import <YuWeeSDK/Yuwee.h>
#import "CallController.h"
#import "CallViewController.h"

@interface RecentCallViewController () <UITableViewDataSource, UITableViewDelegate,CallHistoryCellButtonCallBackEvent> {
    NSMutableArray* array;
    BOOL isGroupCallEnabled;
    CallParams *objCall;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RecentCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self->array = [[NSMutableArray alloc] init];
    [self getRecentCall];
}

- (void)getRecentCall{
    [[[Yuwee sharedInstance] getCallManager] getRecentCall:@"0" withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
        if (isSuccess) {
            NSLog(@"%@", dictResponse);
            NSMutableArray* mArray = dictResponse[@"result"][@"calls"];
            [self->array addObjectsFromArray:mArray];
            [[self tableView] reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = @"recentCallCell";
    
    YuviTimeRecentCallCell *cell = (YuviTimeRecentCallCell *)[_tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell){
        cell = [[YuviTimeRecentCallCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    NSDictionary *mDict = [array objectAtIndex:indexPath.row];
    //BOOL isConfCall = mDict[@"isConferenceCall"];
    cell.lblTitle.text = mDict[@"confName"];

    cell.lblDate.text = [self getFormattedTimeStringFromUnixTime:[mDict[@"initiationTime"] doubleValue]];
    
    if (![mDict[@"isP2PCall"] boolValue]){
       
        if ([mDict[kIsOngoing] boolValue]){
            //Show Join button
            cell.btnJoinOngoingCall.hidden = false;
        }else{
            //Hide Join button
            cell.btnJoinOngoingCall.hidden = true;
        }
       
    }else{
        //One to one call history
        cell.btnJoinOngoingCall.hidden = true;
    }
    
    return cell;
}

- (NSString*)getFormattedTimeStringFromUnixTime:(NSTimeInterval)unixTime{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:unixTime / 1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yy HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)btnJoinOngoingCallClickedFromCell:(UIButton*)btnSender ofIndexPathObject:(NSIndexPath*)indexPath{
    
    NSDictionary *ongoingCall = array[indexPath.row];
    
    [[[Yuwee sharedInstance] getCallManager] joinOngoingCall:ongoingCall[kCallId] MediaType:VIDEO withCompletionHandler:^(NSDictionary *recentCallResponse) {
        if ([ongoingCall[kisGroup] boolValue]) {
            self->isGroupCallEnabled = true;
            self->objCall = [[CallParams alloc] init];
            self->objCall.groupName = ongoingCall[kGroup][kName];
            self->objCall.groupEmailList = ongoingCall[kReceivers];
            [self presentGroupCallScreen:true];
        } else {
            self->isGroupCallEnabled = false;
            self->objCall = [[CallParams alloc] init];
            self->objCall.inviteeEmail = ongoingCall[kEmail];
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
