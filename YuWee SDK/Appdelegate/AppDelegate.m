//
//  AppDelegate.m
//  YuWee SDK
//
//Created by Yuwee on 29/07/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "AppDelegate.h"
#import "HUD.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate () <YuWeePushManagerDelegate,PKPushRegistryDelegate,CXProviderDelegate,UNUserNotificationCenterDelegate>
{
    CXProvider *provider;
}
@property (copy,nonatomic) TokenCompletionBlock block_Token;
@property (strong,nonatomic) NSString *callerName;
@property (strong,nonatomic) NSString *uniqueIdentifier;
@property (nonatomic,strong) UILocalNotification *localNotification;
@end

@implementation AppDelegate
static id app;

+ (AppDelegate*)sharedInstance{
    //Returns Singleton object instance
    
    dispatch_async(dispatch_get_main_queue(),^{
        app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    });
    
    if(app){
        return app;
    }
    else{
       return (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
//    [FIRApp configure];
//    [[Fabric sharedSDK] setDebug:YES];
//    [Fabric with:@[[Crashlytics class]]];
    
    [[Yuwee sharedInstance] initWithAppId:kAppId
                                AppSecret:kAppSecretId
                                 ClientId:kClientIdKey];
    
    //[[Yuwee sharedInstance] setMode:TRUE with:TRUE];
    
   /* InitParam *param = [[InitParam alloc] init];
    
    param.userInfo = (NSDictionary *)[[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:kUser];
    param.accessToken = [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:kToken];
    
    [[[Yuwee sharedInstance] getUserManager] createSessionViaToken:param withCompletionBlock:^(BOOL isSuccess, NSString *error) {
        if (isSuccess) {
            NSLog(@"Create token method success.");
        } else {
            NSLog(@"Create token method faliure.");
        }
    }]; */
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //isApplicationInBackground = YES;
    
   // [[Yuwee sharedInstance] dismissAppConnection];
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"UIApplicationDidEnterBackgroundNotification" object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
   // isApplicationInBackground = NO;
    
//    NSString *strEmail =  [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:kEmail];
//
//    if (strEmail != nil) {
//
//        [[Yuwee sharedInstance] restartAppConnection];
//        [self resetAllNotificationsFromNotificationCenter];
//
//        //If logged in
//        if (![AppDelegate sharedInstance].window.rootViewController.presentedViewController &&
//            ![AppDelegate sharedInstance].window.rootViewController.presentedViewController.presentedViewController){
//
//            //Show incoming call screen if app opened while incoming call without notification
//            if (timer_Call){
//
//                [self abortCallNotification];
//                [self showIncomingCallingScreen:self.dictResponceForCurrentCall];
//            }
//        }
//    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
   // [[Yuwee sharedInstance] restartAppConnection];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
   // [[Yuwee sharedInstance] dismissAppConnection];
    
   // isApplicationInBackground = NO;
   // isApplicationTerminated = YES;
}


- (void)openGroupCallWithDetails:(NSDictionary *)dict{
    
    [self presentGroupCallScreen:true withGroupName:dict[kGroup][kName] andMembers:dict[kReceivers]];
}

- (void)presentGroupCallScreen:(BOOL)isIncoming withGroupName:(NSString *)groupName andMembers:(NSArray *)arrMembers{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callControllerVC.isGroupCall = true;
    callControllerVC.strGroupName = groupName;
    callControllerVC.isIncomingCall = isIncoming;
    callControllerVC.arrMembers = [arrMembers mutableCopy];
    callControllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    ViewController *objVC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    [objVC presentViewController:callControllerVC animated:true completion:nil];
}

#pragma mark- VOIP Registration

/*
 * @Method Name : voipRegistration:
 * @purpose     : Register for VoIP notifications
 * @parameters  : (TokenCompletionBlock)block
 */
- (void)pushRegistrationAndGetToken:(TokenCompletionBlock)block{
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    self.block_Token = block;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
   // dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    // Create a push registry object
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:mainQueue];
    // Set the registry's delegate to self
    self.voipRegistry.delegate = self;
    // Set the push type to VoIP
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    [self registerForRemoteNotifications];
   
    NSLog(@"Push & VoIP registered");
}


- (void)registerForRemoteNotifications {
    
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        
        center = [UNUserNotificationCenter currentNotificationCenter];
        
        center.delegate = self;
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            
            if(!error){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
            
        }];
    }
}

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }

    return [token copy];
}


#pragma mark- PUSH Notifications
   
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)(void))completionHandler{
 //handle the actions
  if ([identifier isEqualToString:@"declineAction"]){
  }
 else if ([identifier isEqualToString:@"answerAction"]){
  }
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken %@",deviceToken);
    
    // _apnsRegistry_Token = deviceToken;
    
    _apnsRegistry_Token = deviceToken;
    
    if (_voipRegistry_Token && ![[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"yuwee_data"]){
        
        NSDictionary *dictTokens = [NSDictionary dictionaryWithObjects:@[[self stringWithDeviceToken:_voipRegistry_Token],[self stringWithDeviceToken:_apnsRegistry_Token]] forKeys:@[@"voip",@"apns"]];
        
        NSLog(@"%@",dictTokens);
        
        self.block_Token(dictTokens);
    }
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@",error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    NSLog(@"%s:%@",__PRETTY_FUNCTION__,userInfo);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
        NSLog(@"UIApplicationStateInactive");
    }else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        NSLog(@"UIApplicationStateActive");
        if (@available(iOS 10, *)) {
            // iOS 10 (or newer) ObjC code
           // [self createUserNotificationToShowIncomingsOnForegroundWithUserInfo:userInfo[kData]];
        }
    }
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
    NSLog(@"application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings");
}


#pragma mark- VOIP PUSH KIT Delegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    //give that to users that want to call this user.
    if([credentials.token length] == 0){
        NSLog(@"voip token NULL");
        return;
    }
    
    self.voipRegistry_Token = credentials.token;
    NSLog(@"PushCredentials: %@", self.voipRegistry_Token);
    
    if (_apnsRegistry_Token && ![[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"yuwee_data"]){
        
        NSDictionary *dictTokens = [NSDictionary dictionaryWithObjects:@[[self stringWithDeviceToken:_voipRegistry_Token],[self stringWithDeviceToken:_apnsRegistry_Token]] forKeys:@[@"voip",@"apns"]];
        
        NSLog(@"%@",dictTokens);
        
       self.block_Token(dictTokens);
    }
}


- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion
{
    NSLog(@"<<<<<<<<<<<<<<************* %s",__PRETTY_FUNCTION__);
    NSLog(@"payload.dictionaryPayload = %@",payload.dictionaryPayload);
    NSLog(@"UTC payload.dictionaryPayload = %f",[[NSDate date] timeIntervalSince1970]);
    
    if (type == PKPushTypeVoIP) {
        
        UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
        
        if (applicationState == UIApplicationStateInactive || applicationState == UIApplicationStateBackground) {
            
            self->dictCall = payload.dictionaryPayload[@"data"];
            //Call kit configration
            CXProviderConfiguration *providerConfig = [[CXProviderConfiguration alloc] initWithLocalizedName:@"my app Call"];
            providerConfig.supportsVideo = NO;
            providerConfig.supportedHandleTypes = [[NSSet alloc] initWithObjects:[NSNumber numberWithInteger:CXHandleTypeEmailAddress], nil];
                      
            CXCallUpdate *callUpdate = [CXCallUpdate new];
            
            NSString *uniqueIdentifier = @"Max test";
            CXCallUpdate *update = [[CXCallUpdate alloc] init];
            update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeEmailAddress value:uniqueIdentifier];
            update.localizedCallerName = uniqueIdentifier;
            update.hasVideo = NO;
                      
            NSUUID *callId = [NSUUID UUID];
            
            CXProvider *provider = [[CXProvider alloc]initWithConfiguration:providerConfig];
            [provider setDelegate:self queue:nil];
                      
            [provider reportNewIncomingCallWithUUID:callId update:callUpdate completion:^(NSError * _Nullable error) {
                NSLog(@"reportNewIncomingCallWithUUID error: %@",error);
                
                //completion();
            }];
            
            completion();
        }
    }
    
   /* if (type == PKPushTypeVoIP) {
        
        UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
        
        if (applicationState == UIApplicationStateInactive || applicationState == UIApplicationStateBackground) {
            
            [self pushRegistryDidReceivedPushWithPayload:payload forType:type withCompletionHandler:completion];
            
        }
    } */
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
    NSLog(@"token invalidated");
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action{
    [action fulfill];
    NSUUID *callbackUUIDToken = [NSUUID UUID];
    NSDate *now = [[NSDate alloc] init];
    if (provider) {
        [provider reportCallWithUUID:callbackUUIDToken endedAtDate:now reason:CXCallEndedReasonRemoteEnded];
        
        [[[Yuwee sharedInstance] getCallManager] acceptIncomingCall:self->dictCall];
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CallController *calVC = [storyboard instantiateViewControllerWithIdentifier:@"CallController"];
        //calVC.isGroupCall = false;
        //calVC.isIncomingCall = true;
//        if ([[self->dictCall allKeys] containsObject:@"senderEmail"]) {
//            calVC.strEmailAddress = self->dictCall[@"senderEmail"];
//        }
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calVC];
        
        [self.window.rootViewController presentViewController:navigationController
          animated:false
        completion:nil];
    }
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action{
    [action fulfill];
    NSUUID *callbackUUIDToken = [NSUUID UUID];
    NSDate *now = [[NSDate alloc] init];
    if (provider) {
        [provider reportCallWithUUID:callbackUUIDToken endedAtDate:now reason:CXCallEndedReasonRemoteEnded];
    }
}

- (void)pushRegistryDidReceivedPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion{
    
    //Call kit configration
    CXProviderConfiguration *providerConfig = [[CXProviderConfiguration alloc] initWithLocalizedName:@"my app Call"];
    providerConfig.supportsVideo = NO;
    providerConfig.maximumCallGroups = 1;
    providerConfig.maximumCallsPerCallGroup = 1;
    providerConfig.supportedHandleTypes = [[NSSet alloc] initWithObjects:[NSNumber numberWithInteger:CXHandleTypeGeneric], nil];


    CXProvider *provider = [[CXProvider alloc] initWithConfiguration:providerConfig];
    [provider setDelegate:self queue:nil];

    //generate token
    NSUUID *callbackUUIDToken = [NSUUID UUID];

    //Display callkit

    NSString *uniqueIdentifier = @"Max test";
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:uniqueIdentifier];
    update.supportsGrouping = FALSE;
    update.supportsUngrouping = FALSE;
    update.supportsHolding = FALSE;
    update.localizedCallerName = uniqueIdentifier;
    update.hasVideo = NO;
    [provider reportNewIncomingCallWithUUID:callbackUUIDToken update:update completion:^(NSError * _Nullable error) {
        NSLog(@"reportNewIncomingCallWithUUID error: %@",error);
    }];

   /* if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    } */
    
   /* dictCall = (id)payload.dictionaryPayload;
    
    self.dictResponceForCurrentCall = dictCall[kData];
     
    // NSLog(@"%@",[dictCall[kData] allKeys]);
     
     NSString *strCallerName = nil;
     
     if ([[self->dictCall[kData] allKeys] containsObject:kRequest_Type]) {
         if ([dictCall[kData][kisGroup] boolValue]) {
             strCallerName = [NSString stringWithFormat:@"%@ group call ended.",_callerName];
         } else {
             strCallerName = [NSString stringWithFormat:@"%@ is ended the call",_callerName];
         }
     } else {
         if ([dictCall[kData][kisGroup] boolValue]) {
             strCallerName = [NSString stringWithFormat:@"Call from %@ group.",dictCall[kData][kGroup][kName]];
             _callerName = dictCall[kData][kGroup][kName];
         } else {
             strCallerName = [NSString stringWithFormat:@"%@ is calling you.",dictCall[kData][kSender][kName]];
             _callerName = dictCall[kData][kSender][kName];
         }
     }
     
     NSString *strMessage = dictCall[kData][kMessage];
     NSError *jsonError;
     NSData *objectData = [strMessage dataUsingEncoding:NSUTF8StringEncoding];
     NSDictionary *jsonDictMessage = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
     
     //Call kit configration
     CXProviderConfiguration *providerConfig = [[CXProviderConfiguration alloc] initWithLocalizedName:strCallerName];
     providerConfig.supportsVideo = [jsonDictMessage[kCallType] isEqualToString:@"AUDIO"] ? false : true;
     providerConfig.supportedHandleTypes = [[NSSet alloc] initWithObjects:[NSNumber numberWithInteger:CXHandleTypeEmailAddress], nil];
     
     
    provider = [[CXProvider alloc] initWithConfiguration:providerConfig];
    [provider setDelegate:self queue:nil];
     
     //generate token
     NSUUID *callbackUUIDToken = [NSUUID UUID];
     
     //Display callkit
     if ([dictCall[kData][kisGroup] boolValue]) {
         _uniqueIdentifier = [NSString stringWithFormat:@"%@",_callerName];
     } else {
         _uniqueIdentifier = [NSString stringWithFormat:@"%@",_callerName];
     }
     
     CXCallUpdate *update = [[CXCallUpdate alloc] init];
     update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeEmailAddress value:_uniqueIdentifier];
     update.localizedCallerName = _uniqueIdentifier;
     update.hasVideo = [jsonDictMessage[kCallType] isEqualToString:@"AUDIO"] ? false : true;
     
    [provider reportNewIncomingCallWithUUID:callbackUUIDToken update:update completion:^(NSError * _Nullable error) {
         NSLog(@"error: %@",error);
         if ([[self->dictCall[kData] allKeys] containsObject:kRequest_Type]) {
             NSDate *now = [[NSDate alloc] init];
             [self->provider reportCallWithUUID:callbackUUIDToken endedAtDate:now reason:CXCallEndedReasonRemoteEnded];
         } else {
             
            [[[Yuwee sharedInstance] getNotificationManager] initWithListnerObject:self];
             
            [[[Yuwee sharedInstance] getNotificationManager] processMessageDataFromNotificationDetails:self->dictCall];
             
             //NSLog(@"dictCall[kData]: %@",self->dictCall[kData]);
         }
     }];
     
     NSDate *now = [[NSDate alloc] init];
     [provider reportCallWithUUID:callbackUUIDToken endedAtDate:now reason:CXCallEndedReasonRemoteEnded]; */
}


#pragma mark - User Notification delegate

- (void)processReceivedPushNotification:(NSDictionary *)dictResponse response:(UNNotificationResponse * _Nonnull)response {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    NSLog(@"response %@ : userInfo %@",response.notification.request.identifier,response.notification.request.content.userInfo);
    
    NSDictionary *dictResponse = response.notification.request.content.userInfo[kData];
   // NSDictionary *dictAPS = response.notification.request.content.userInfo[@"aps"];//PUSH payload
    
    if (!dictResponse)
        return;
    
    if (dictResponse[kReceivers] || ![dictResponse[kisGroup] boolValue]){
        [self processReceivedPushNotification:dictResponse response:response];
    }
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //For notification Banner - when app in foreground
    NSDictionary *dictUserInfo = notification.request.content.userInfo[kData];
    
    NSLog(@"%s %@ notification.request.content.userInfo= %@",__PRETTY_FUNCTION__,dictUserInfo,notification.request.content.userInfo);
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"willPresentNotification: withCompletionHandler" message:@"" delegate:nil cancelButtonTitle:@"" otherButtonTitles:@"OK", nil];
//    [alert show];
    
    NSString *strPurpose = @"";
    
    if (![[dictUserInfo objectForKey:@"purpose"] isKindOfClass:[NSNull class]])
        strPurpose = [dictUserInfo objectForKey:@"purpose"];


    if ([[dictUserInfo[kMessageType] lowercaseString] isEqualToString:@"call"]){
        completionHandler(UNNotificationPresentationOptionNone);
    }
}

#pragma mark- YuWeePushManagerDelegate

- (void)onReceiveCallFromPush:(NSDictionary *)dictResponse{
    
    NSLog(@"dictResponse: %@",dictResponse);
    
    [self insertLocalNotificationOnIncomingCallWithIncomingCallDictionary:dictResponse];
}

- (void)onNewScheduleMeetingFromPush:(NSDictionary *)dictResponse{
    
    NSLog(@"dictResponse: %@",dictResponse);
}

- (void)onScheduleMeetingJoinFromPush:(NSDictionary *)dictResponse{
    
    NSLog(@"dictResponse: %@",dictResponse);
}


#pragma mark- General Methods

- (void)createUserNotificationToShowIncomingsOnForegroundWithUserInfo:(NSDictionary*)userInfo{
    NSLog(@"%s  :- %@",__PRETTY_FUNCTION__,userInfo);
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    NSString *strTitle;
    if ([userInfo[kIs_Group] boolValue]){
        strTitle = userInfo[kGroup][kName];
    }else{
        strTitle = userInfo[kSender][kName];
    }
    content.title = strTitle;
    content.body = userInfo[kMessage];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = userInfo;
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:false];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:userInfo[kRoomId] content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:nil];
    
}

- (void)resetScheduledPreviousCallNotification:(NSTimer*)userInfo{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSDictionary *dictInfo = userInfo.userInfo;
    
    NSLog(@"(timerIndex==6) %s",__PRETTY_FUNCTION__);
    timerIndex ++;
    NSLog(@"timerIndex== %zd",timerIndex);
    if (timerIndex==4) {
        NSLog(@"(timerIndex==4 called)");
        [timer_Call invalidate];
        timerIndex = 0;
        _localNotification = nil;
        return;
    }
    
    if(center)
       [center removeAllDeliveredNotifications];
    
    [self fireCallNotificationSchedule:dictInfo];
    
}

- (void)scheduleUNNotification:(NSDictionary *)dictJSON dictUserInfo:(NSDictionary *)dictUserInfo{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"YuWee" arguments:nil];
    
    //Get local saved name
    NSString *strIdOfSender = nil;
    NSDictionary *dictTempUserInfo = dictUserInfo[kData];
    if (dictTempUserInfo[kSender][kSenderId]){
        strIdOfSender = dictTempUserInfo[kSender][kSenderId];
    }
    
    NSString *strContactName = dictUserInfo[kSender][kName];
    
    content.subtitle = [strContactName capitalizedString];
    content.body = [NSString stringWithFormat:@"%@ incoming call...",[dictJSON[kCallType] capitalizedString]];
    content.userInfo = dictUserInfo;
    //content.sound = [UNNotificationSound soundNamed:@"ringtone.caf"];
    content.categoryIdentifier = kUNNotificationCategoryIdentifier;
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:0.1f repeats:false];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:kUNNotificationCategoryIdentifier content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"add NotificationRequest succeeded!");
        }
    }];
}

- (void)scheduleLocalNotification:(NSDictionary *)dictJSON dictUserInfo:(NSDictionary *)dictUserInfo {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (_localNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:_localNotification];
        _localNotification = nil;
    }
    _localNotification = [[UILocalNotification alloc] init];
    _localNotification.fireDate = [NSDate date];
    NSLog(@"localNotification.fireDate %@",_localNotification.fireDate);
    _localNotification.soundName = @"ringtone.caf";
    _localNotification.userInfo = @{ @"CategoryIdentifier" : kUNNotificationCategoryIdentifier };
    
    //Get local saved name
    NSString *strIdOfSender = nil;
    NSDictionary *dictTempUserInfo = dictUserInfo[kData];
    if (dictTempUserInfo[kSender][k_Id]){
        strIdOfSender = dictTempUserInfo[kSender][k_Id];
    }else if (dictTempUserInfo[kSender][kSenderId]){
        strIdOfSender = dictTempUserInfo[kSender][kSenderId];
    }
    
    NSString *strContactName = dictTempUserInfo[kSender][kName];
    if (strIdOfSender){
        strContactName = dictTempUserInfo[kSender][kEmail];
    }
    
    _localNotification.alertTitle = [strContactName capitalizedString];
    _localNotification.alertBody = [NSString stringWithFormat:@"%@ incoming call...",[dictJSON[kCallType] capitalizedString]];
    _localNotification.userInfo = dictUserInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:_localNotification];
}

- (void)fireCallNotificationSchedule:(NSDictionary *)userInfo{
    NSLog(@"%s ",__PRETTY_FUNCTION__);
    NSString *strMessage = userInfo[kData][kMessage];
    NSError *jsonError;
    NSData *objectData = [strMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictMessage = [NSJSONSerialization JSONObjectWithData:objectData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&jsonError];
    
    [self triggerNotificationWithUserInfo:userInfo andJSONDictionary:jsonDictMessage];
}

- (void)triggerNotificationWithUserInfo:(NSDictionary *)dictUserInfo andJSONDictionary:(NSDictionary*)dictJSON{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    //Schedule notification....
    [self scheduleUNNotification:dictJSON dictUserInfo:dictUserInfo];
    
   /* if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        [self scheduleUNNotification:dictJSON dictUserInfo:dictUserInfo];
    }else if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"8.0")) {
        [self scheduleLocalNotification:dictJSON dictUserInfo:dictUserInfo];
    } */
}

-(void)insertLocalNotificationOnIncomingCallWithIncomingCallDictionary:(NSDictionary*)dictResponse
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    //start a timer for 30 sec
    if (!timer_showCallTimedOut) {
        timer_showCallTimedOut = [NSTimer scheduledTimerWithTimeInterval:30.0f
                                                                  target:self selector:@selector(timerToShowDailedCallTimedOut:) userInfo:self.dictResponceForCurrentCall repeats:false];
    }
    
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    
    NSMutableDictionary *dictAPS = dictResponse.mutableCopy;
    //Removing all null values from dictionary
    NSArray *arrNullKeys = [dictAPS allKeysForObject:[NSNull null]];
    for (int i=0; i<arrNullKeys.count; i++) {
        [dictAPS removeObjectForKey:arrNullKeys[i]];
    }
    NSDictionary *dictUserInfo = [NSDictionary dictionaryWithObject:dictAPS forKey:kData];
    [self fireCallNotificationSchedule:dictUserInfo];
    timer_Call = [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(resetScheduledPreviousCallNotification:) userInfo:dictUserInfo repeats:true];
}

- (void)showIncomingCallingScreen:(NSDictionary *)dictCall{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self.window endEditing:true]; //this code is responsible to resign any of the keyboard while incoming call
    
    self.dictResponceForCurrentCall = dictCall;
    
    if (viewCall) {
        [viewCall removeFromSuperview];
        viewCall = nil;
    }
    
    CGFloat widthRatio = (CGRectGetWidth(self.window.frame)/320.0);
    
    //Add View background
    viewCall = [[UIView alloc]initWithFrame:self.window.frame];
    viewCall.backgroundColor = [UIColor whiteColor];
    viewCall.tag = 12345;
    
    UIImageView *imgViewBackground = [[UIImageView alloc]init];
    imgViewBackground.frame = self.window.frame;
    imgViewBackground.contentMode = UIViewContentModeScaleToFill;
    imgViewBackground.backgroundColor = [UIColor whiteColor];
    [imgViewBackground setImage:[UIImage imageNamed:@"yuwee_bg"]];
    [viewCall addSubview:imgViewBackground];
    
    CGFloat frameButton = 70*widthRatio;
    CGFloat widthMargin = 30;
    CGFloat widthMargin_Name = 30;
    CGFloat heightMargin = 100;
    
    //Add Accept audio call button
    UIButton *btnRejectCall = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRejectCall.frame = CGRectMake((CGRectGetWidth(self.window.frame)-(frameButton+widthMargin)), CGRectGetHeight(self.window.frame)- heightMargin, frameButton, frameButton);
    btnRejectCall.backgroundColor = [UIColor clearColor];
    [btnRejectCall setImage:[UIImage imageNamed:@"call_reject"] forState:UIControlStateNormal];
    [btnRejectCall addTarget:self action:@selector(rejectCallActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    [viewCall addSubview:btnRejectCall];
    
    //Add Reject call button
    UIButton *btnAcceptAudio = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAcceptAudio.tag = 1;
    btnAcceptAudio.frame = CGRectMake(widthMargin, CGRectGetMinY(btnRejectCall.frame), frameButton, frameButton);
    btnAcceptAudio.backgroundColor = [UIColor clearColor];
    [btnAcceptAudio setImage:[UIImage imageNamed:@"call_accept"] forState:UIControlStateNormal];
    [btnAcceptAudio addTarget:self action:@selector(acceptCallActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    [viewCall addSubview:btnAcceptAudio];
    
    //Add Title label
    UILabel *lblAppTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, CGRectGetWidth(self.window.frame), 25)];
    [lblAppTitle setTextColor:[UIColor darkGrayColor]];
    [lblAppTitle setTextAlignment:NSTextAlignmentCenter];
    lblAppTitle.font = [UIFont fontWithName:kAmpleSoftFontName size:30];
    lblAppTitle.text = @"YuWee";
    [viewCall addSubview:lblAppTitle];
    
    //Add UILable to display caller name
    UILabel *lblCallerName = [[UILabel alloc]initWithFrame:CGRectMake(widthMargin_Name, CGRectGetMaxY(lblAppTitle.frame), CGRectGetWidth(self.window.frame)-widthMargin_Name*2, 25)];
    [lblCallerName setTextColor:[UIColor darkGrayColor]];
    [lblCallerName setTextAlignment:NSTextAlignmentCenter];
    lblCallerName.font = [UIFont fontWithName:kAmpleSoftFontName size:25];
    
    NSString *strMessage = dictCall[kMessage];
    NSError *jsonError;
    NSData *objectData = [strMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictMessage = [NSJSONSerialization JSONObjectWithData:objectData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&jsonError];
    
    strCurrentCall_MessageId = jsonDictMessage[kMessageId];
    strCurrentCall_CallHistoryId = dictCall[kCallId];

    UIImageView *imgViewUser = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 170*widthRatio, 170*widthRatio)];
    imgViewUser.center = self.window.center;
    imgViewUser.layer.cornerRadius = CGRectGetWidth(imgViewUser.frame)/2;
    imgViewUser.layer.masksToBounds = true;
    imgViewUser.contentMode = UIViewContentModeScaleAspectFit;
    imgViewUser.backgroundColor = [UIColor clearColor];
    [viewCall addSubview:imgViewUser];
    
    //Show user image if exists
    if ([dictCall[@"isGroup"] boolValue]){
        lblCallerName.text = [NSString stringWithFormat:@"Video call from %@...",dictCall[kGroup][kName]];
    }else{
        NSString *strIdOfSender = nil;
        if (dictCall[kSender][k_Id]){
            strIdOfSender = dictCall[kSender][k_Id];
        }else if (dictCall[kSender][kSenderId]){
            strIdOfSender = dictCall[kSender][kSenderId];
        }
        
        NSString *strContactName = dictCall[kSender][kName];
        
        lblCallerName.text = [NSString stringWithFormat:@"%@ call from %@...",[jsonDictMessage[kCallType] capitalizedString],strContactName];
        
    }
    
    [viewCall addSubview:lblCallerName];
    
    [self.window addSubview:viewCall];
    
   // [self playRingtone];
    
    //start a timer for 30 sec
    if (!timer_showCallTimedOut){
        timer_showCallTimedOut = [NSTimer scheduledTimerWithTimeInterval:30.0f
                                                                  target:self selector:@selector(timerToShowDailedCallTimedOut:) userInfo:self.dictResponceForCurrentCall repeats:false];
    }
  
}

- (void)timerToShowDailedCallTimedOut:(NSDictionary *)dictRecentCall{
    
    if (self.dictResponceForCurrentCall) {
        [[[Yuwee sharedInstance] getNotificationManager] dailedCallTimedOutSend:self.dictResponceForCurrentCall];
    }
    
    //show toast "call timeout"
    [self showToast: @"Call timed out!"];
    
    self.dictResponceForCurrentCall = nil;
    [self clearUpCallTimers];
}


- (void)acceptCallActionEvent:(UIButton*)sender{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [self abortCallNotification];
    [self clearUpCallTimers];
    
    [[[Yuwee sharedInstance] getCallManager] acceptIncomingCall:self.dictResponceForCurrentCall];
    
    NSString *strLoginUserEmail =  [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:kEmail];
    
    if ([self.dictResponceForCurrentCall[kSender][k_Id] isEqualToString:strLoginUserEmail]) {
        [self showCallScreenWithIsGroup:[self.dictResponceForCurrentCall[kisGroup] boolValue] isIncomingCall:true andResponceDictionary:self.dictResponceForCurrentCall];
    }else {
        [self showCallScreenWithIsGroup:[self.dictResponceForCurrentCall[kisGroup] boolValue] isIncomingCall:false andResponceDictionary:self.dictResponceForCurrentCall];
    }
}

- (void)rejectCallActionEvent:(UIButton*)sender{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [self abortCallNotification];
    
    [[[Yuwee sharedInstance] getCallManager] rejectIncomingCall:self.dictResponceForCurrentCall];
    
    //invalidate call timeout timer
    [timer_showCallTimedOut invalidate];
    timer_showCallTimedOut = nil;
    
    if (viewCall) {
        [UIView animateWithDuration:0.5
                              delay:0.3
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self->viewCall.alpha = 0;
                         }completion:^(BOOL finished){
                             [self->viewCall removeFromSuperview];
                         }];
    }
    
    self.dictResponceForCurrentCall = nil;
    
    [self showToast:@"call rejected by you."];
}


- (void)abortCallNotification{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [timer_Call invalidate];
    timerIndex = 0;
    timer_Call = nil;
    
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        //ios10>=
        [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            
            for (UNNotification *notification in notifications) {
                if ([notification.request.content.categoryIdentifier isEqualToString:kUNNotificationCategoryIdentifier]){
                    NSLog(@"<<<<<<<<<<<<<< %@ : %@ : %@",notification.request.content.title,notification.request.content.subtitle, notification.request.content.body);
                    [self->center removeDeliveredNotificationsWithIdentifiers:@[kUNNotificationCategoryIdentifier]];
                    
                    break;
                }
            }
        }];
    }
}


- (void)resetAllNotificationsFromNotificationCenter{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (@available(iOS 10, *)) {
        [center removeAllDeliveredNotifications];
    }
}

- (void)clearUpCallTimers {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [timer_showCallTimedOut invalidate];
    timer_showCallTimedOut = nil;
   
    if (viewCall) {
        [viewCall removeFromSuperview];
        viewCall = nil;
    }
}

- (void)showToast:(NSString *)message {
    if ([self topViewController]!=nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self topViewController].view animated:YES];
        hud.userInteractionEnabled = false;
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = message;
        hud.margin = 10.f;
        hud.yOffset = 70.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:3];
    }
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

- (void)showCallScreenWithIsGroup:(BOOL)isGroupCall isIncomingCall:(BOOL)isIncomingCall andResponceDictionary:(NSDictionary *)dictResponse{
    
    NSLog(@"*************< showVideoCallScreenWithIsCaller Called >*************");
    
    [self callerScreenWithDetails:dictResponse isGroupCall:isGroupCall isIncomingCall:isIncomingCall];
}


- (void)callerScreenWithDetails:(NSDictionary *)dictResponse isGroupCall:(BOOL)isGroupCall isIncomingCall:(BOOL)isIncomingCall{
    
    UINavigationController *navigationController;
    
    if (isGroupCall){
        
        NSArray *arrMembers = dictResponse[kReceivers];
        
        if([arrMembers count]> 2)
        {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
            callControllerVC.isGroupCall = isGroupCall;
            callControllerVC.strGroupName = dictResponse[kGroup][kName];
            callControllerVC.isIncomingCall = isIncomingCall;
            callControllerVC.arrMembers = [arrMembers mutableCopy];
            navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
        }
        else
        {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CallController *calVC = [storyboard instantiateViewControllerWithIdentifier:@"CallController"];
            calVC.isGroupCall = isGroupCall;
            calVC.isIncomingCall = isIncomingCall;
            if ([[dictResponse allKeys] containsObject:@"senderEmail"]) {
                calVC.strEmailAddress = dictResponse[@"senderEmail"];
            }
            navigationController = [[UINavigationController alloc] initWithRootViewController:calVC];
        }
        
    }else{
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CallController *calVC = [storyboard instantiateViewControllerWithIdentifier:@"CallController"];
        calVC.isGroupCall = isGroupCall;
        calVC.isIncomingCall = isIncomingCall;
        if ([[dictResponse allKeys] containsObject:@"senderEmail"]) {
            calVC.strEmailAddress = dictResponse[@"senderEmail"];
        }
        navigationController = [[UINavigationController alloc] initWithRootViewController:calVC];
        
    }
    
    NSLog(@"*************Call has been accepted, now opening the ARTCVideoChatController*************");

  /*  if (self.window.rootViewController.presentedViewController) {
        [self.window.rootViewController.presentedViewController presentViewController:navigationController
                                                                             animated:false
                                                                           completion:nil];
    } else { */
       
        [self.window.rootViewController presentViewController:navigationController
                                                     animated:false
                                                   completion:nil];
   // }
}

@end
