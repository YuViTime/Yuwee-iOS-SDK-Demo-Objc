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

//static String appId = "CMOZm27a5KxXagVen6vyxeiddpX2lkHJ";
//    static String appSecret = "HERjEYJP1LmMOK0t5Q1sUyv0vRsNzIH50lyt8NyNkRb7QgDxSiomq1EJtVFzmRft";
//    static String clientId = "5fa3e8108cb9b56d05ef9b4b";

// MiBhagya
//static String appId = "IcdKxf7SHsJ6kc4I6jxC6FD7ZxeRrH3X";
//    static String appSecret = "jnByLZqTG1pBo4Uv6DBMBbx8gTkFCoXcrCD8OyakvNiuqKd0FCr8jdHktbfiwpYz";
//    static String clientId = "5f8e92ffc089f30fbf6e0f5b";

/////CONNECT  ******///
#define kAppId @"IcdKxf7SHsJ6kc4I6jxC6FD7ZxeRrH3X"
#define kAppSecretId @"jnByLZqTG1pBo4Uv6DBMBbx8gTkFCoXcrCD8OyakvNiuqKd0FCr8jdHktbfiwpYz"
#define kClientIdKey @"5f8e92ffc089f30fbf6e0f5b"


///DEV  ******///
//#define kAppId @"kAILMWL8qzGBetS77fUSIRSiMz6hyjIK"
//#define kAppSecretId @"WVDaXh5akOGvQflXcMb1I8QTRxozwygCBvy3w5SJfdj3BYvUVp47ta6ffsznhbU4"
//#define kClientIdKey @"5f367584e732241ff4ba71b3"

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
- (void)showToast:(NSString *)message;
- (UIViewController *)topViewController;
- (void)pushRegistrationAndGetToken:(TokenCompletionBlock)block;
- (void)openGroupCallWithDetails:(NSDictionary *)dict;
- (void)showIncomingCallingScreen:(NSDictionary *)dictCall;
- (void)showCallScreenWithIsGroup:(BOOL)isGroupCall isIncomingCall:(BOOL)isIncomingCall andResponceDictionary:(NSDictionary *)dictResponse;

@end

