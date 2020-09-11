//
//  ViewController.m
//  YuWee SDK
//
//Created by Yuwee on 29/07/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "ViewController.h"
#import "HUD.h"
#import "CallController.h"
#import "CallViewController.h"

@interface ViewController (){
    BOOL isGroupCallEnabled;
    NSString *strLoginUserEmail;
    NSDictionary *dictCallParameter;
    NSMutableArray *arrUsers;
}
@property (weak, nonatomic) IBOutlet UITextField *txtGroup;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UISwitch *groupCall;
@property (weak, nonatomic) IBOutlet UIButton *btnStartCall;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToGroupCall;
@property (weak, nonatomic) IBOutlet UIButton *btnJoinLastCall;
@property (weak, nonatomic) IBOutlet UILabel *lblLoginUserEmail;
@property (weak, nonatomic) IBOutlet UITableView *tblEmails;

- (IBAction)btnStartCallClicked:(UIButton *)sender;

@end


@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    isGroupCallEnabled = false;
    _groupCall.on = false;
    self.txtGroup.hidden = true;
    self.btnAddToGroupCall.hidden = true;
    self.tblEmails.hidden = true;
    
    arrUsers = [NSMutableArray new];
    
   // [arrUsers addObject:[YuweeSocketManager sharedInstance].strLoginUserEmail];
    
    strLoginUserEmail =  [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
    
    NSString *strEmail = strLoginUserEmail;
    
    _lblLoginUserEmail.text = [NSString stringWithFormat:@"Login Email : %@",strEmail];
    
   // SessionHandler *sessionObject = [[SessionHandler alloc]init];
    
    [[[Yuwee sharedInstance] getCallManager] setUpIncomingCallWithClassListnerObject:self];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    self.view.userInteractionEnabled = YES;
    gestureRecognizer.cancelsTouchesInView = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"onAddMember" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onAddMember" object:nil];
}

- (void)receiveTestNotification:(NSNotification *)notification{
    
    [self performSelector:@selector(presentGroupCall:) withObject:notification.userInfo afterDelay:2.0];
}

- (void)presentGroupCall:(NSDictionary *)dictDetails{
    if (([dictDetails[kisGroup] boolValue]) && ([AppDelegate sharedInstance].isHost)) {
        [AppDelegate sharedInstance].isHost = false;
        [[AppDelegate sharedInstance] showCallScreenWithIsGroup:[dictDetails[kisGroup] boolValue] isIncomingCall:false andResponceDictionary:dictDetails];
    }else {
        [[AppDelegate sharedInstance] showCallScreenWithIsGroup:[dictDetails[kisGroup] boolValue] isIncomingCall:true andResponceDictionary:dictDetails[kResult]];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- Login

-(IBAction)onLoginPressed:(id)sender {
    NSLog(@"On Login Pressed");
    strLoginUserEmail =  [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
    if (strLoginUserEmail != nil) {
        [self showToast:@"Your are logged in"];
    } else {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *objVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
        [self presentViewController:objVC animated:true completion:nil];
    }
}


#pragma mark- Schedule Listeners

- (void)onMeetingScheduledWithDictParameter:(NSDictionary *)dictParameter{
    NSLog(@"%s %@",__PRETTY_FUNCTION__,dictParameter);
    
    //     _btnJoinLastCall.enabled = false;
}

- (void)onMeetingDeletedWithDictParameter:(NSDictionary *)dictParameter{
    NSLog(@"%s %@",__PRETTY_FUNCTION__,dictParameter);
    
    _btnJoinLastCall.enabled = false;
}

- (void)onMeetingExpiredWithDictParameter:(NSDictionary *)dictParameter{
    NSLog(@"%s %@",__PRETTY_FUNCTION__,dictParameter);
    
    _btnJoinLastCall.enabled = false;
}

//Add join button
- (void)onMeetingReminderWithDictParameter:(NSDictionary *)dictParameter{
    NSLog(@"%s %@",__PRETTY_FUNCTION__,dictParameter);
    
    _txtEmail.text = nil;
    dictCallParameter = dictParameter.copy;
    
    _btnJoinLastCall.enabled = true;
}


- (void)onJoinScheduledMeeting{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    _txtEmail.text = nil;
    isGroupCallEnabled = true;
    if (self->isGroupCallEnabled) {
        [self presentGroupCallScreen:false];
    }
}

#pragma mark- Call Listeners
- (void)onReadyToInitiateCall:(CallParams *)callParams withBusyUserList:(NSArray *)arrBusyUserList{
    
    NSMutableDictionary *dictReceiver = [[NSMutableDictionary alloc] init];
    
    [dictReceiver setObject:callParams.groupEmailList forKey:kReceivers];
    
    if (callParams.isGroup) {
        [[AppDelegate sharedInstance] showCallScreenWithIsGroup:callParams.isGroup isIncomingCall:true andResponceDictionary:dictReceiver];
    }else {
        [[AppDelegate sharedInstance] showCallScreenWithIsGroup:callParams.isGroup isIncomingCall:true andResponceDictionary:dictReceiver];
    }
//    if (callParams.isGroup) {
//        [self presentGroupCallScreen:true];
//    } else {
//        [self presentCallScreen:true];
//    }
}

- (void)onAllUsersBusy{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
}

/*- (void)onIncomingCallWithCalledId:(NSDictionary *)dictCallInfo{
    NSLog(@"%s dictCallInfo =%@",__PRETTY_FUNCTION__,dictCallInfo);
    
    NSString *strCallerName = @"";
    if ([[dictCallInfo[kGroup] allKeys] containsObject:kGroupAdmins])
        strCallerName = dictCallInfo[kGroup][kName];
    else
        strCallerName =  dictCallInfo[kSender][kEmail];
    
    NSString *strIncomingCallerInfo = [NSString stringWithFormat:@"%@ call from %@...",[dictCallInfo[kCallType] capitalizedString],strCallerName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incoming Call" message:strIncomingCallerInfo preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [[CallManager sharedInstance] rejectIncomingCall:dictCallInfo];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[CallManager sharedInstance] acceptIncomingCall:dictCallInfo];
        self.txtEmail.text = nil;
        if ([[dictCallInfo[kGroup] allKeys] containsObject:kGroupAdmins]) {
            [self presentGroupCallScreen:true];
        }else {
            [self presentCallScreen:true];
        }
    }]];
    
    // Present alert.
    [self presentViewController:alertController animated:YES completion:nil];
} */

- (void)onAcceptCall{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

#pragma mark-

- (void)onConnectSocket:(NSDictionary*)dictSessionCreateResponse{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    //    NSString *strAccessToken = dictSessionCreateResponse[kAccess_Token];
    //    [[SocketManager sharedInstance] setUpSocketConnectionWithAccessToken:strAccessToken
    //                                                         completionBlock:^(BOOL isOnSuccess, NSDictionary *dictSocketResponse){
    
    dispatch_async(dispatch_get_main_queue(),^{
        
        //            [[SocketManager sharedInstance] setDelegate:(id)self];
        
        //            if(isOnSuccess){
        self.btnStartCall.enabled = true;
        [self.btnStartCall setTitle:@"Start Call" forState:UIControlStateNormal];
        [self.btnStartCall setTitle:@"" forState:UIControlStateHighlighted];
        //            }else{
        //                self.btnStartCall.enabled = false;
        //                [self.btnStartCall setTitle:@"Connection failed!" forState:UIControlStateNormal];
        //            }
        
    });
}

/*
 * @Method Name : isStringIsValidEmail:(NSString *)checkString
 * @purpose     : Method used to validate string as a valid email
 * @parameters  : (NSString*)checkString
 */
-(BOOL)isStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}


#pragma mark-

- (IBAction)isGroupCall:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        NSLog(@"its on!");
        isGroupCallEnabled = true;
        self.txtGroup.hidden = false;
        self.btnAddToGroupCall.hidden = false;
        self.tblEmails.hidden = false;
    } else {
        NSLog(@"its off!");
        isGroupCallEnabled = false;
        self.txtGroup.hidden = true;
        self.btnAddToGroupCall.hidden = true;
        self.tblEmails.hidden = true;
    }
}


- (IBAction)btnAddToGroupCallClicked:(UIButton *)sender{
    if (_txtEmail.text.length>0){
        if (isGroupCallEnabled){
            if (![strLoginUserEmail isEqualToString:_txtEmail.text]) {
                if ([self validateUnknownEmail:_txtEmail.text]) {
                    [arrUsers addObject:_txtEmail.text];
                    [self.tblEmails reloadData];
                }
            }
        }
    }
}


- (IBAction)btnStartCallClicked:(UIButton *)sender{
    
   // NSDictionary* mResponse = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"yuwee_data"];
  //  NSString* authToken = mResponse[kToken];
    
    NSMutableDictionary *dictReceiver = [[NSMutableDictionary alloc] init];
    
    if (isGroupCallEnabled) {
        if ([arrUsers count]>1) {
            [dictReceiver setObject:arrUsers forKey:kReceivers];
            [dictReceiver setObject:_txtGroup.text forKey:@"groupName"];
        } else {
            [dictReceiver setObject:arrUsers[0] forKey:@"senderEmail"];
        }
        
        [[AppDelegate sharedInstance] showCallScreenWithIsGroup:isGroupCallEnabled isIncomingCall:false andResponceDictionary:dictReceiver];
    }else {
        
        [dictReceiver setObject:_txtEmail.text forKey:@"senderEmail"];
        
        [[AppDelegate sharedInstance] showCallScreenWithIsGroup:isGroupCallEnabled isIncomingCall:false andResponceDictionary:dictReceiver];
    }
    
  /*  if (isGroupCallEnabled) {
        [self presentGroupCallScreen:false];
    } else {
        if (_txtEmail.text.length && authToken){
            if ([self isStringIsValidEmail:_txtEmail.text]){
                //Process start call
                [self presentCallScreen:false];
               // [sender settit];
                //Connecting...
            }
        }
    } */
}

- (void)hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:true];
}

-(IBAction)resignPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}


#pragma mark-

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
    
    //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
    
   /* if ([AppDelegate sharedInstance].window.rootViewController.presentedViewController) {
        [[AppDelegate sharedInstance].window.rootViewController.presentedViewController presentViewController:callControllerVC animated:false completion:nil];
    } */
}

- (void)presentGroupCallScreen:(BOOL)isIncoming{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callControllerVC.isGroupCall = isGroupCallEnabled;
    callControllerVC.strGroupName = _txtGroup.text;
    callControllerVC.isIncomingCall = isIncoming;
    callControllerVC.arrMembers = arrUsers;
    callControllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
    
    [self presentViewController:navigationController animated:false completion:nil];
    
  /*  if ([AppDelegate sharedInstance].window.rootViewController.presentedViewController) {
        [[AppDelegate sharedInstance].window.rootViewController.presentedViewController presentViewController:callControllerVC animated:false completion:nil];
    } */
}

- (void)presentCallScreen:(BOOL)isIncoming{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallController *callVC = [storyboard instantiateViewControllerWithIdentifier:@"CallController"];
    callVC.isGroupCall = isGroupCallEnabled;
    callVC.isIncomingCall = isIncoming;
    if ([strLoginUserEmail isEqualToString:_txtEmail.text]) {
        [self showToast:@"You cannot send call request yourself."];
    } else {
        callVC.strEmailAddress = _txtEmail.text;
    }
    callVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callVC];
    
    [self presentViewController:navigationController animated:false completion:nil];
    
  /*  if ([AppDelegate sharedInstance].window.rootViewController.presentedViewController) {
        [[AppDelegate sharedInstance].window.rootViewController.presentedViewController presentViewController:callVC animated:false completion:nil];
    } */
}

- (void)showToast:(NSString *) message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self topViewController].view animated:YES];
    hud.userInteractionEnabled = false;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:3];
}

- (UIViewController *)topViewController{
  return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
  if (rootViewController.presentedViewController == nil) {
    return rootViewController;
  }

  if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
    UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
    return [self topViewController:lastViewController];
  }

  UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
  return [self topViewController:presentedViewController];
}

- (BOOL)validateUnknownEmail:(NSString*)strEmail{
    if([self isStringIsValidEmail:strEmail]){
        if([arrUsers containsObject:strEmail]){
            
            _txtEmail.text = @"";
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You can't add existing member." preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            
            dispatch_async(dispatch_get_main_queue(),^{
                
                [self presentViewController:alertController animated:YES completion:nil];
            });
            return false;
        } else
            return true;
    }
    else{
        
        //This condition prevents from a UI bug while adding invalid email on ongoing call
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Email!"
                                                                                 message:@"Please enter a valid email."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        dispatch_async(dispatch_get_main_queue(),^{
            
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return false;
    }
}

# pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([arrUsers count]>0) {
        return arrUsers.count;
    }else {
        return 0;
    }
}

- (YuviTimeAddressFieldCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier = @"cellId";

    YuviTimeAddressFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil)
    {
        cell = [[YuviTimeAddressFieldCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }

    if ([arrUsers count]>0) {
        UIImage *defaultPeopleImage = [UIImage imageNamed:@"defult_people_icon"];
        UIImage *closeImage = [UIImage imageNamed:@"closequickcall"];
        
        cell.imgUser.image = defaultPeopleImage;
        cell.lblEmail.text = [arrUsers objectAtIndex:indexPath.row];
        cell.imgClose.image = closeImage;
        cell.constraintForImageWidth.constant = 40;
    }
    
    return cell;
}

# pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

@end
