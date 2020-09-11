//
//  AppDelegate.h
//  YuWee SDK
//
//  //Created by Yuwee on 29/07/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CallKit/CallKit.h>
#import <PushKit/PushKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <YuWeeSDK/Yuwee.h>
#import "DashboardViewController.h"
#import "CallViewController.h"
#import "CallController.h"
#import "ViewController.h"


///CONNECT  ******///
#define kAppId @"5mNTkN7o5Z6uyRrg1XoUVDXP3JhYBxHe"
#define kAppSecretId @"fQagO1AGo5kb9Gl0IJVXRYlCM4KuTJ5qH2ztE1b0ilZv8v3MR2U0aB19bH1eaUYS"
#define kClientIdKey @"5ece403cedf5d71348e8969f"

/////DEV  ******///
//#define kAppId @"3ulLlGDM5feppT22jof1YUXg5btMxrHj"
//#define kAppSecretId @"LPdKFRLKsGe4f1yyj2B2K0okzbnbfSESVgrpb07U4ciwixMeFBiT7Eh6u9YHjF5g"
//#define kMasterAccountId @"5b4d1ba96fa40c21f079a8e2"
//#define kClientIdKey @"5f5b5e249acf3b2f74caa645"

#define kRequest_Type @"requestType"
#define KDefaultCallType @"VIDEO"
#define kMessageType @"messageType"
#define kMessage @"message"
#define kLastMessage @"lastMessage"
#define kCallType @"callType"
#define kResult @"result"
#define kResults @"results"
#define kCalls @"calls"
#define kEmail @"email"
#define kName @"name"
#define kUser @"user"
#define kData @"data"
#define k_Id @"_id"
#define kCallId @"callId"
#define kGroupId @"groupId"
#define kConferenceId @"conferenceId"
#define kToken @"token"
#define kMembers @"members"
#define kAddMembers @"addMembers"
#define kResult @"result"
#define kRoom @"room"
#define kSender @"sender"
#define kRoomId @"roomId"
#define kMessageId @"messageId"
#define kSenderId @"senderId"
#define kGroup @"group"
#define kGroupAdmins @"groupAdmins"
#define kisGroup @"isGroup"
#define kIs_Group @"is_group"
#define kReceivers @"receivers"
#define kIsOngoing @"isOngoing"
#define kUserInfo @"userinfo"
#define kGroupInfo @"groupInfo"
#define kMembersInfo @"membersInfo"
#define kReceiverInfo @"receiverInfo"
#define kSenderInfo @"senderInfo"
#define kICSCallResourceId @"ICSCallResourceId"
#define kUserActiveStatus @"userActiveStatus"
#define kStatus @"status"
#define kStatusIdentifier_Success @"success"
#define kStatusIdentifier_Error @"error"
#define kTotal_Record @"total_record"
#define kLogout @"logout"
#define kMessageType_CALL @"CALL"
#define kMessageType_TEXT @"TEXT"
#define kMessageType_FILE @"FILE"
#define kAmpleSoftFontName @"AmpleSoft"
#define kSCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define kUNNotificationCategoryIdentifier @"com.yuwee.iosapp.sdk"

typedef void(^TokenCompletionBlock)(NSDictionary *dictTokens);

@class SocketIOClient;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSInteger timerIndex;
    UIView *viewCall;
    NSDictionary *dictCall;
    UNUserNotificationCenter *center;
    BOOL isApplicationInBackground,isApplicationTerminated;
    NSTimer *timer_animateCallerName;
    NSTimer *timer_showCallTimedOut,*timer_Call;
    NSString *strCurrentCall_MessageId;
    NSString *strCurrentCall_CallHistoryId;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) SocketIOClient* socket;
@property (nonatomic,strong) NSString* strAppId;
@property (nonatomic,strong) PKPushRegistry * voipRegistry;
@property (nonatomic,strong) NSData *voipRegistry_Token;
@property (nonatomic,strong) NSData *apnsRegistry_Token;
@property (assign,nonatomic) BOOL hasInternet;
@property (assign,nonatomic) BOOL isHost;
@property(nonatomic,assign) BOOL isAnyCallIsOngoing;
@property(nonatomic,strong) NSDictionary *dictResponceForCurrentCall;

+ (AppDelegate*)sharedInstance;
- (UIViewController *)topViewController;
- (void)pushRegistrationAndGetToken:(TokenCompletionBlock)block;
- (void)openGroupCallWithDetails:(NSDictionary *)dict;
- (void)showIncomingCallingScreen:(NSDictionary *)dictCall;
- (void)showCallScreenWithIsGroup:(BOOL)isGroupCall isIncomingCall:(BOOL)isIncomingCall andResponceDictionary:(NSDictionary *)dictResponse;

@end

