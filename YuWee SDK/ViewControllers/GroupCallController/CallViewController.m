//
//  CallViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 28/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "CallViewController.h"

@interface CallViewController (){
    YuviTimeAddMemberPopUpView *viewAdd;
    KLCPopup *popUpInvite;
}
@property (strong ,nonatomic) NSArray *arrExistingUsers;

@end

@implementation CallViewController
 
- (void)viewDidLoad{
    
    [AppDelegate sharedInstance].isAnyCallIsOngoing = true;
    
    if(self.isIncomingCall) {
        self.navigationItem.rightBarButtonItem.enabled = true;
        [self.videoView addSubview:self.videoView.remoteVideoView];
        [self.videoView addSubview:self.videoView.localVideoView];
        [[[Yuwee sharedInstance] getCallManager] setCallManagerDelegate:self];
        [[[Yuwee sharedInstance] getCallManager] initCallWithLocalView:self.videoView.localVideoView withRemoteView:self.videoView.remoteVideoView];
    }else {
        if ([self.arrMembers count]>0) //Dial
          [self startCallWithArrofEmail:self.arrMembers andCallType:@"Video"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

-(void)viewWillDisappear:(BOOL)animated {
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [super viewWillDisappear:animated];
}

-(void)move:(UIPanGestureRecognizer*)recognizer {
     CGPoint translation = [recognizer translationInView:[[Yuwee sharedInstance] getCallManager].videoView];
     recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                     recognizer.view.center.y + translation.y);
     [recognizer setTranslation:CGPointMake(0, 0) inView:[[Yuwee sharedInstance] getCallManager].videoView];

     if (recognizer.state == UIGestureRecognizerStateEnded) {

         CGPoint velocity = [recognizer velocityInView:[[Yuwee sharedInstance] getCallManager].videoView];
         CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
         CGFloat slideMult = magnitude / 200;
         NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);

         float slideFactor = 0.1 * slideMult; // Increase for more of a slide
         CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                     recognizer.view.center.y + (velocity.y * slideFactor));
         finalPoint.x = MIN(MAX(finalPoint.x, 0), [[Yuwee sharedInstance] getCallManager].videoView.bounds.size.width);
         finalPoint.y = MIN(MAX(finalPoint.y, 0), [[Yuwee sharedInstance] getCallManager].videoView.bounds.size.height);

         [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
             recognizer.view.center = finalPoint;
         } completion:nil];

    }
}

- (void)moveScreen:(UIPanGestureRecognizer*)recognizer {
     CGPoint translation = [recognizer translationInView:[[Yuwee sharedInstance] getCallManager].screenView];
     recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                     recognizer.view.center.y + translation.y);
     [recognizer setTranslation:CGPointMake(0, 0) inView:self.screenView];

     if (recognizer.state == UIGestureRecognizerStateEnded) {

         CGPoint velocity = [recognizer velocityInView:[[Yuwee sharedInstance] getCallManager].screenView];
         CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
         CGFloat slideMult = magnitude / 200;
         NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);

         float slideFactor = 0.1 * slideMult; // Increase for more of a slide
         CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                     recognizer.view.center.y + (velocity.y * slideFactor));
         finalPoint.x = MIN(MAX(finalPoint.x, 0), [[Yuwee sharedInstance] getCallManager].screenView.bounds.size.width);
         finalPoint.y = MIN(MAX(finalPoint.y, 0), [[Yuwee sharedInstance] getCallManager].screenView.bounds.size.height);

         [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
             recognizer.view.center = finalPoint;
         } completion:nil];
    }
}

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

#pragma mark- Start Call

- (void)startCallWithArrofEmail:(NSArray*)arrEmail andCallType:(NSString*)strCallType{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    CallParams *callParams = [[CallParams alloc] init];
    callParams.invitationMessage = @"Test Message";
    callParams.groupEmailList = [arrEmail mutableCopy];
    callParams.groupName = _strGroupName;
    callParams.mediaType = VIDEO;
    callParams.isGroup = true;
    
    [[CallManager sharedInstance] setUpCall:callParams withClassListnerObject:self];
}


#pragma mark-

- (void)onReadyToInitiateCall:(CallParams *)callParams withBusyUserList:(NSArray *)arrBusyUserList{
    self.navigationItem.rightBarButtonItem.enabled = true;
    [self.videoView addSubview:self.videoView.remoteVideoView];
    [self.videoView addSubview:self.videoView.localVideoView];
    [[[Yuwee sharedInstance] getCallManager] setCallManagerDelegate:self];
    [[Yuwee sharedInstance] getCallManager].videoView = self.videoView;
    [[Yuwee sharedInstance] getCallManager].screenView = self.screenView;
    [[Yuwee sharedInstance] getCallManager].isCallTypeVideo = true;
    [[[Yuwee sharedInstance] getCallManager] initCallWithLocalView:self.videoView.localVideoView withRemoteView:self.videoView.remoteVideoView];
}

- (void)onCallConnected {
    if ([[Yuwee sharedInstance] getCallManager].isScreenSharingOn) {
        [self setViewOfControlsOrigin:self.viewOfControls onParentView:[[Yuwee sharedInstance] getCallManager].screenView];
        [self.view bringSubviewToFront:[[Yuwee sharedInstance] getCallManager].screenView];
    } else {
        [self setViewOfControlsOrigin:self.viewOfControls onParentView:[[Yuwee sharedInstance] getCallManager].videoView];
        [self.view bringSubviewToFront:[[Yuwee sharedInstance] getCallManager].videoView];
    }
}

- (void)onCallReconnecting {
}

- (void)onAllUsersBusy {
    NSLog(@"onAllUsersBusy");
}


- (void)onAllUsersOffline {
}


- (void)onError:(CallParams *)callParams withMessage:(NSString *)strMessage {
}


- (void)setUpAditionalViewsOnRemoteVideoView:(YuweeRemoteVideoView *)remoteView withSize:(CGSize)size{
    if (remoteView) {
    }
}

-(void)onSuccessToSentCallRequest:(NSString *)strMessage{
    [self showInviteCallAlert:strMessage];
}

-(void)onErrorToSentCallRequest:(NSString *)strMessage{
    [self showInviteCallAlert:strMessage];
}

-(void)onCallEnd:(NSDictionary *)callData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:true completion:nil];
    });
}

-(void)onRemoteCallHangUp:(NSDictionary *)callData{
    [[CallManager sharedInstance] hangUpCallWithCompletionBlockHandler:^(BOOL isCallSuccess, NSDictionary *dictCallResponse){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewOfControls = [[AppDelegate sharedInstance].window viewWithTag:215];
            if (self.viewOfControls) {
                [self.viewOfControls removeFromSuperview];
                [self.screenView removeFromSuperview];
                self.videoView.hidden = false;
                self.viewOfControls = [[AppDelegate sharedInstance].window viewWithTag:115];
                [self.viewOfControls removeFromSuperview];
                NSArray *subViewArray = [[AppDelegate sharedInstance].window subviews];
                for (id obj in subViewArray)
                {
                    if ([obj isKindOfClass:[YuweeControl class]]) {
                        [obj removeFromSuperview];
                    }
                }
            }else {
                self.viewOfControls = [[AppDelegate sharedInstance].window viewWithTag:115];
                [self.viewOfControls removeFromSuperview];
                NSArray *subViewArray = [[AppDelegate sharedInstance].window subviews];
                for (id obj in subViewArray)
                {
                    if ([obj isKindOfClass:[YuweeControl class]]) {
                        [obj removeFromSuperview];
                    }
                }
            }
            [[AppDelegate sharedInstance].window.rootViewController dismissViewControllerAnimated:true completion:nil];
        });
    }];
}

- (void)methodForShowingPopUpGroup{
    viewAdd = [YuviTimeAddMemberPopUpView initWithNib];
    viewAdd.delegate_addMember = (id)self;
    viewAdd.layer.cornerRadius = 10;
    
    viewAdd.lblInviteStringPlaceholder.hidden = true;
    viewAdd.arrExistingUsers = _arrExistingUsers;
    [viewAdd initialize];
    popUpInvite = [KLCPopup popupWithContentView:viewAdd
                                        showType:KLCPopupShowTypeSlideInFromBottom
                                     dismissType:KLCPopupDismissTypeSlideOutToBottom
                                        maskType:KLCPopupMaskTypeDimmed
                        dismissOnBackgroundTouch:NO
                           dismissOnContentTouch:NO];
    viewAdd.popUpInvite = popUpInvite;
    [popUpInvite show];
}

- (void)setViewOfControlsOrigin:(YuweeControl *)viewOfControls onParentView:(YuweeVideoView *)videoView {
    
    //viewOfControls.translatesAutoresizingMaskIntoConstraints=NO;
    
    if (videoView==[[Yuwee sharedInstance] getCallManager].videoView) {
        [[[AppDelegate sharedInstance].window viewWithTag:215] removeFromSuperview];
    }else {
        [[[AppDelegate sharedInstance].window viewWithTag:115] removeFromSuperview];
    }
    
    UIPanGestureRecognizer *panRecognizer = nil;
    
    CGFloat viewY= ((kSCREENHEIGHT - 44) - (51 + 40.0));
    
    CGFloat viewX= ((kSCREENWIDTH - 315)/2);
    
    //viewOfControls.translatesAutoresizingMaskIntoConstraints=YES;
    
    CGRect frameControl = viewOfControls.frame;
    
    frameControl.origin = CGPointMake(viewX, viewY);
    frameControl.size = CGSizeMake(315, 51);
    
    viewOfControls = [YuweeControl initWithNib];
    viewOfControls.frame = frameControl;
    viewOfControls.delegate = (id)self;
    [viewOfControls initialize];
    if (videoView==[[Yuwee sharedInstance] getCallManager].videoView) {
        viewOfControls.tag = 115;
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [viewOfControls addGestureRecognizer:panRecognizer];
    } else {
        viewOfControls.tag = 215;
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveScreen:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [viewOfControls addGestureRecognizer:panRecognizer];
    }
    
    [[AppDelegate sharedInstance].window addSubview:viewOfControls];
}

# pragma mark - YuviTimeAddMemberPopUpViewDelegate Methods

- (void)didAddUsersWithEmails:(NSArray *)emails{
    [popUpInvite dismiss:true];
    
    if (emails.count) {
        
        NSMutableArray *arrAllUsersTemp = [NSMutableArray new];
        
        for (NSDictionary *dict in emails.mutableCopy) {
            if (![arrAllUsersTemp containsObject:dict]) {
                [arrAllUsersTemp addObject:dict];
            }
        }
        
        [[CallManager sharedInstance] addMemberOnCall:arrAllUsersTemp andGroupName:nil withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
            
        }];
    }
}

#pragma mark- UIButton Action events

- (IBAction)btnAddMemberToOngoingCallClicked:(UIBarButtonItem *)sender{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    _isAddMemberOnFly = true;
    [[NSUserDefaults standardUserDefaults] setBool:_isAddMemberOnFly forKey:@"isAddMemberOnFly"];
    [self methodForShowingPopUpGroup];
}

- (void)endCallPressed:(id)sender{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    if (sender){
        UIButton *btnHangup = (UIButton*)sender;
        btnHangup.enabled = false;
    }
    
    [[CallManager sharedInstance] hangUpCallWithCompletionBlockHandler:^(BOOL isCallSuccess, NSDictionary *dictCallResponse){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewOfControls = [[AppDelegate sharedInstance].window viewWithTag:215];
            if (self.viewOfControls) {
                [self.viewOfControls removeFromSuperview];
                [self.screenView removeFromSuperview];
                self.videoView.hidden = false;
                self.viewOfControls = [[AppDelegate sharedInstance].window viewWithTag:115];
                [self.viewOfControls removeFromSuperview];
            }else {
                self.viewOfControls = [[AppDelegate sharedInstance].window viewWithTag:115];
                [self.viewOfControls removeFromSuperview];
            }
            [[AppDelegate sharedInstance].window.rootViewController dismissViewControllerAnimated:true completion:nil];
        });
    }];
}

- (void)hideAudioPressed:(BOOL)isSelected{
    [[CallManager sharedInstance] setAudioEnabled:isSelected];
}


- (void)switchSpeakerPressed:(BOOL)isSelected{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setProximityMonitoringEnabled:isSelected];
    });
    
    [[CallManager sharedInstance] onMuteAudioOutputSpeaker:isSelected];
}

- (void)hideVideoPressed:(BOOL)isSelected{
    [[CallManager sharedInstance] setVideoEnabled:isSelected];
}

- (IBAction)btnSwipeCameraPressed:(UIBarButtonItem *)sender{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [[CallManager sharedInstance] switchCamera];
}

@end
