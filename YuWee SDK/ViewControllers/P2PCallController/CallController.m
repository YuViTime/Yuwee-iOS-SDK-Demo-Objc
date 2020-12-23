//
//  CallController.m
//  YuWee SDK
//
//Created by Yuwee on 29/07/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "CallController.h"
#import "ViewController.h"
#import "CallViewController.h"
//#import <YuWeeSDK/CallParams.h>

@implementation CallController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [AppDelegate sharedInstance].isAnyCallIsOngoing = true;
    
    [[[Yuwee sharedInstance] getCallManager] setOnMemberAddedOnCallDelegate:self];
    
    [[[Yuwee sharedInstance] getCallManager] setCallManagerDelegate:self];
    
    if(_isIncomingCall) {
       self.navigationItem.rightBarButtonItem.enabled = true;
       [[[Yuwee sharedInstance] getCallManager] initCallWithLocalView:self.localView withRemoteView:self.remoteView];
        
//        NSError *error;
//        NSData *jsonData = [self.dictCall[@"message"] dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &error];
//        
//        if ([json[@"callType"] isEqualToString:@"AUDIO"]) {
//            NSLog(@"Audio Call");
//            [[[Yuwee sharedInstance] getCallManager] setVideoEnabled:false];
//        }
        
    }else {
        //Local View
        if ([self.strEmailAddress length]>0) //Dial
          [self startCallWithEmail:self.strEmailAddress andCallType:@"Video"];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Call Setters

- (void)showInviteCallAlert:(NSString *)strMessage{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Call invitation sent"
                               message:strMessage
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    
    //Open UIAlert
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark-

- (void)onReadyToInitiateCall:(CallParams *)callParams withBusyUserList:(NSArray *)arrBusyUserList{
    self.navigationItem.rightBarButtonItem.enabled = true;
    if(!callParams.isGroup)
        [[[Yuwee sharedInstance] getCallManager] initCallWithLocalView:self.localView withRemoteView:self.remoteView];
}

- (void)onCallEnd:(NSDictionary *)callData{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AppDelegate sharedInstance].window.rootViewController dismissViewControllerAnimated:true completion:nil];
    });
}


- (void)onRemoteCallHangUp:(NSDictionary *)callData {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [[CallManager sharedInstance] hangUpCallWithCompletionBlockHandler:^(BOOL isCallSuccess, NSDictionary *dictCallResponse){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AppDelegate sharedInstance].window.rootViewController dismissViewControllerAnimated:true completion:nil];
        });
    }];
}

- (void)onCallConnected {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSError *error;
    NSData *jsonData = [self.dictCall[@"message"] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &error];
    
    if ([json[@"callType"] isEqualToString:@"AUDIO"]) {
        NSLog(@"Audio Call");
        [[[Yuwee sharedInstance] getCallManager] setVideoEnabled:false];
    }
}

- (void)onCallDisconnected {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [[CallManager sharedInstance] hangUpCallWithCompletionBlockHandler:^(BOOL isCallSuccess, NSDictionary *dictCallResponse){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AppDelegate sharedInstance].window.rootViewController dismissViewControllerAnimated:true completion:nil];
        });
    }];
}

- (void)onCallAccept{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)onAllUsersBusy{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)onAllUsersOffline {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)onCallRinging{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)onError:(CallParams *)callParams withMessage:(NSString *)strMessage {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"strMessage: %@",strMessage);
}

- (void)setUpAditionalViewsOnRemoteVideoView:(YuweeRemoteVideoView *)remoteView withSize:(CGSize)size{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

#pragma mark-

- (IBAction)btnAddMemberToOngoingCallClicked:(UIBarButtonItem *)sender{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    _isAddMemberOnFly = true;
    [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setBool:_isAddMemberOnFly forKey:@"isAddMemberOnFly"];
    [self setUpMethodForShowingPopUp];
}


- (void)setUpMethodForShowingPopUp{
    viewInvite = [YuviTimeStartCallView initWithNib];
    viewInvite.delegate_StartCall = (id)self;
    viewInvite.layer.cornerRadius = 10;
    
    viewInvite.lblInviteStringPlaceholder.hidden = true;
    viewInvite.arrExistingUsers = _arrMembers;
    [viewInvite initialize];
    popUpInvite = [KLCPopup popupWithContentView:viewInvite
                                        showType:KLCPopupShowTypeSlideInFromBottom
                                     dismissType:KLCPopupDismissTypeSlideOutToBottom
                                        maskType:KLCPopupMaskTypeDimmed
                        dismissOnBackgroundTouch:NO
                           dismissOnContentTouch:NO];
    viewInvite.popUpInvite = popUpInvite;
    [popUpInvite show];
}

#pragma mark - YuWeeOnMemberAddedOnCallDelegate Methods

- (void)onMemberAddedOnCall:(NSDictionary *)callData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppDelegate sharedInstance].isHost = true;
        [self dismissViewControllerAnimated:true completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onAddMember" object:nil userInfo:callData];
    });
}

#pragma mark - YuviTimeStartCallViewDelegate Methods

- (void)didAddUsersWithEmails:(NSArray *)emails andGroupName:groupName{
    [popUpInvite dismiss:true];
    
    if (emails.count) {
        
        NSMutableArray *arrAllUsersTemp = [NSMutableArray new];
        
        for (NSDictionary *dict in emails.mutableCopy) {
            if (![arrAllUsersTemp containsObject:dict]) {
                [arrAllUsersTemp addObject:dict];
            }
        }
        
        [[CallManager sharedInstance] addMemberOnCall:arrAllUsersTemp andGroupName:groupName withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:true completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onAddMember" object:nil userInfo:dictResponse];
            });
        }];
    }
    
    // [self dismissViewControllerAnimated:false completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showGroupCall"]) {
        CallViewController *destViewController = (CallViewController*) segue.destinationViewController;
        //NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        destViewController.dictCall = _dictCall;
    }
}

#pragma mark- Start Call

- (void)startCallWithEmail:(NSString*)strEmail andCallType:(NSString*)strCallType{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    CallParams *callParams = [[CallParams alloc] init];
    callParams.invitationMessage = @"Test Message";
    callParams.inviteeEmail = strEmail;
    callParams.inviteeName = strEmail;
    callParams.mediaType = VIDEO;
    
    [[[Yuwee sharedInstance] getCallManager] setUpCall:callParams withClassListnerObject:self];
}


#pragma mark- UIButton Action events
/*
 * @Method Name : hangupButtonPressed:
 * @purpose     : Method used to call drop button action event
 * @parameters  : (id)sender
 */
- (IBAction)hangupButtonPressed:(id)sender{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (sender){
        UIButton *btnHangup = (UIButton*)sender;
        btnHangup.enabled = false;
    }
    [[CallManager sharedInstance] hangUpCallWithCompletionBlockHandler:^(BOOL isCallSuccess, NSDictionary *dictCallResponse){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AppDelegate sharedInstance].window.rootViewController dismissViewControllerAnimated:true completion:nil];
        });
    }];
}

- (IBAction)btnMuteAudioClicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    [[CallManager sharedInstance] setAudioEnabled:sender.selected];
}


- (IBAction)btnSwitchSpeakerMode:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    [[CallManager sharedInstance] onMuteAudioOutputSpeaker:sender.selected];
}

- (IBAction)btnSwipeCameraPressed:(UIBarButtonItem *)sender{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [[CallManager sharedInstance] switchCamera];
}

- (IBAction)btnHideShowVideo:(UIButton *)sender{
    //sender.selected = !sender.selected;
    
    [[CallManager sharedInstance] setVideoEnabled:sender.selected];
}

- (void)presentGroupCallScreen:(BOOL)isIncoming withGroupName:(NSString *)groupName andMembers:(NSArray *)arrMembers{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callControllerVC.isGroupCall = true;
    callControllerVC.strGroupName = groupName;
    callControllerVC.isIncomingCall = isIncoming;
    callControllerVC.arrMembers = [arrMembers mutableCopy];
    callControllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
    
    [self presentViewController:navigationController animated:false completion:nil];
}

@end
