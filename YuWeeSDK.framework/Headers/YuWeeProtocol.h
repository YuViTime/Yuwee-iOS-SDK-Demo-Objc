//
//  YuWeeProtocol.h
//  YuWee SDK
//
//  Created by Prasanna Gupta on 07/09/18.
//  Copyright © 2018 Prasanna Gupta. All rights reserved.
//

#ifndef YuWeeProtocol_h
#define YuWeeProtocol_h

#import <Foundation/Foundation.h>
#import "CallParams.h"
#import "YuweeRemoteVideoView.h"
#import <OWT/OWT.h>

#pragma mark- Call Operation events

@protocol YuWeeCallSetUpDelegate <NSObject>

- (void)onAllUsersOffline;

- (void)onAllUsersBusy;

- (void)onReadyToInitiateCall:(CallParams *)callParams withBusyUserList:(NSArray *)arrBusyUserList;

- (void)onError:(CallParams *)callParams withMessage:(NSString *)strMessage;

@end

@protocol YuWeeIncomingCallEventDelegate <NSObject>

- (void)onIncomingCall:(NSDictionary *)callData;

- (void)onIncomingCallAcceptSuccess:(NSDictionary *)callData;

- (void)onIncomingCallRejectSuccess:(NSDictionary *)callData;

- (void)onIncomingCallActionPerformedFromOtherDevice:(NSDictionary *)data;

@end

@protocol YuWeeOnMemberAddedOnCallDelegate <NSObject>

- (void)onMemberAddedOnCall:(NSDictionary *)callData;

@end

@protocol YuWeeCallManagerDelegate <NSObject>
@optional

#pragma mark- Call handling events

- (void)onCallTimeOut;

- (void)onCallReject;

- (void)onCallAccept;

- (void)onCallConnected;

- (void)onCallDisconnected;

- (void)onCallReconnecting;

- (void)onCallReconnected;

- (void)onCallRinging;

- (void)onRemoteCallHangUp:(NSDictionary *)callData;

- (void)onRemoteVideoToggle:(NSDictionary *)callData;

- (void)onRemoteAudioToggle:(NSDictionary *)callData;

- (void)onCallEnd:(NSDictionary *)callData;

- (void)onCallConnectionFailed;

- (void)setUpAditionalViewsOnRemoteVideoView:(YuweeRemoteVideoView *)remoteView withSize:(CGSize)size;

@end


#pragma mark- Schedule handlers
@protocol YuWeeScheduleCallManagerDelegate <NSObject>

- (void)onScheduledCallActivated:(NSDictionary *)dictParameter;

- (void)onNewScheduledCall:(NSDictionary *)dictParameter;

- (void)onScheduleCallExpired:(NSDictionary *)dictParameter;

- (void)onScheduledCallDeleted:(NSDictionary *)dictParameter;

@end


#pragma mark- Hosted Meeting Management events
@protocol OnHostedMeetingDelegate  <NSObject>

- (void)onStreamAdded:(OWTRemoteStream *)remoteStream;

- (void)onStreamRemoved:(OWTRemoteStream *)remoteStream;

- (void)onCallParticipantRoleUpdated:(NSDictionary *)dict;

- (void)onCallAdminsUpdated:(NSDictionary *)dict;

- (void)onCallParticipantMuted:(NSDictionary *)dict;

- (void)onCallParticipantDropped:(NSDictionary *)dict;

- (void)onCallParticipantJoined:(NSDictionary *)dict;

- (void)onCallParticipantLeft:(NSDictionary *)dict;

- (void)onCallParticipantStatusUpdated:(NSDictionary *)dict;

- (void)onCallHandRaised:(NSDictionary *)dict;

- (void)onMeetingEnded:(NSDictionary *)dict;

- (void)onCallActiveSpeaker:(NSDictionary *)dict;

- (void)onCallRecordingStatusChanged:(NSDictionary *)dict;

- (void)onError:(NSString *)error;

@end


#pragma mark- Push Management events
@protocol YuWeePushManagerDelegate <NSObject>

- (void)onReceiveCallFromPush:(NSDictionary *)dictResponse;

- (void)onNewScheduleMeetingFromPush:(NSDictionary *)dictResponse;

- (void)onScheduleMeetingJoinFromPush:(NSDictionary *)dictResponse;

- (void)onChatMessageReceivedFromPush:(NSDictionary *)dictResponse;

@end

#pragma mark- Subscribe Remote Stream Management events
@protocol YuWeeRemoteStreamSubscriptionDelegate <NSObject>

- (void)onSubscribeRemoteStreamResult:(OWTConferenceSubscription *)subsription withStream:(OWTRemoteStream *)remoteStream withMessage:(NSString *)message withStatus:(BOOL)success;

@end


#pragma mark- Status Management events
@protocol YuWeeUserStatusChangeDelegate <NSObject>

- (void)onUserStatusChange:(NSDictionary *)dictParameter;

@end


#pragma mark- Incoming Message Handler
@protocol YuWeeNewMessageReceivedDelegate <NSObject>

- (void)onNewMessageReceived:(NSDictionary *)dictParameter;

@end

#pragma mark- Typing Event Delegate
@protocol YuWeeTypingEventDelegate <NSObject>

- (void)onUserTypingInRoom:(NSDictionary*)dictObject;

@end

#pragma mark- Message Delivered Handler
@protocol YuWeeMessageDeliveredDelegate <NSObject>

- (void)onMessageDelivered:(NSDictionary *)dictParameter;

@end

#pragma mark- Message Deleted Handler
@protocol YuWeeMessageDeletedDelegate <NSObject>

- (void)onMessageDeleted:(NSDictionary *)dictParameter;

@end

#pragma mark- Message Deleted Handler
@protocol YuWeeBroadcastMessageDelegate <NSObject>

- (void)onMessageBroadcastSuccess:(NSString*)uniqueMessageId;
- (void)onMessageBroadcastError:(NSString*)error;

@end

#pragma mark- Yuwee Connection Handler
@protocol YuWeeConnectionDelegate <NSObject>

- (void) onConnected;

- (void) onDisconnected;

- (void) onReconnection;

- (void) onReconnected;

- (void) onReconnectionFailed;

- (void) onClose;

@end

#pragma mark- Yuwee File Manager

@protocol YuWeeFileUploadDelegate <NSObject>

- (void) onUploadSuccess;

- (void) onUploadStarted;

- (void) onUploadFailed;

- (void) onProgressUpdateWithProgress:(double)progress;

@end

/**********<Event Completion Handlers>*********/
typedef void(^NotificationManagerCompletionBlock)(NSDictionary *dictNotificationManagerResponse);
typedef void(^CallHangUpCompletionBlock)(BOOL isCallHangUpSuccess,NSDictionary *dictCallHangUpResponse);
typedef void(^CallCompletionBlock)(BOOL isCallSuccess,NSDictionary *dictCallResponse);
typedef void(^LoginCompletionBlock)(BOOL isSessionCreateSuccess,NSDictionary *dictSessionCreateResponse);
typedef void(^CreateUserCompletionBlock)(BOOL isCreateUserSuccess,NSDictionary *dictCreateUserResponse);
typedef void(^LogoutUserCompletionBlock) (BOOL isLogoutSuccess, NSDictionary *dictLogoutResponse);
typedef void(^ScheduleCallCompletionBlock)(BOOL isCallScheduledSuccess,NSDictionary *dictCallScheduleResponse);
typedef void(^SocketCompletionBlock)(BOOL isOnSuccess,NSDictionary *dictSocketResponse);
typedef void(^PushCompletionBlock)(BOOL isCompleted ,NSArray *arrResponse,NSString *strCallBackType);
typedef void(^AddMembersToCallCompletionBlock)(BOOL isOnSuccess,NSDictionary *dictAddMembersResponse);
typedef void(^ChatOperationCompletionBlock)(BOOL isSuccess,NSDictionary *dictChatResponse);
typedef void(^UserLastSeenCompletionBlock)(BOOL isSuccess, NSDictionary *dictLastSeenResponse);
typedef void(^ContactOperationCompletionBlock) (BOOL isSuccess, NSDictionary *dictResponse);
typedef void(^AddMembersInGroupCompletionBlock) (BOOL isSuccess, NSDictionary *dictResponse);
typedef void(^RemoveMembersInGroupCompletionBlock) (BOOL isSuccess, NSDictionary *dictResponse);
typedef void(^SetOnMemberAddedOnCallCompletionBlock) (BOOL isSuccess, NSDictionary *dictResponse);
typedef void(^FetchRecentCallCompletionBlock) (BOOL isSuccess, NSDictionary *dictResponse);
typedef void(^TokenCompletionBlock)(NSDictionary *dictTokens);
typedef void(^UserSessionCompletionBlock)(NSDictionary *userSessionResponse);
typedef void(^GetMessageDataCompletionBlock)(NSString *strMsg);
typedef void(^NetworkTimeCompletionBlock)(NSString *strNetworkTime);
typedef void(^FetchRoomIdCompletionBlock)(NSDictionary *dictRoomIdResponse);
typedef void(^FetchRoomKeyCompletionBlock)(NSDictionary *dictRoomKeyResponse);
typedef void(^SecheduleCallCompletionBlock)(NSDictionary *secheduleCallResponse);
typedef void(^RecentCallCompletionBlock)(NSDictionary *recentCallResponse);
typedef void(^CallParticipantCompletionBlock)(NSDictionary *callParticipantResponse);
typedef void(^CallStartCompletionBlock)(NSDictionary *callStartResponse);
typedef void(^CallStageCompletionBlock)(NSDictionary *callStageResponse);
typedef void(^OffScreenCompletionBlock)(NSDictionary *offScreenResponse);
typedef void(^PhoneCallCompletionBlock)(NSDictionary *phoneCallResponse);
typedef void(^AddContactCompletionBlock) (BOOL isSuccess, NSDictionary *dictAddContactResponse);
typedef void(^FetchContactCompletionBlock) (BOOL isSuccess, NSDictionary *dictFetchContactResponse);
typedef void(^FetchContactListCompletionBlock) (BOOL isSuccess, NSDictionary *dictFetchContactListResponse);
typedef void(^DeleteContactCompletionBlock) (BOOL isSuccess, NSDictionary *dictDeleteContactResponse);
typedef void(^UserStatusCompletionBlock) (BOOL isSuccess, NSDictionary *dictResponse);
typedef void(^OnCreateSessionViaTokenCompletionBlock) (BOOL isSuccess, NSString *error);
typedef void(^OnRegisterPushTokenCompletionBlock) (BOOL isSuccess, NSString *error);
typedef void(^OnInitFileShareCompletionHandler)(NSString *message, BOOL success);
typedef void(^OnGetFilePathCompletionHandler)(NSString *fileDownloadUrl, BOOL success);
typedef void(^OnGetAwsCredHandler)(NSDictionary *dictResponse, BOOL success);

typedef NS_ENUM(NSInteger, DeleteType) {
    DELETE_FOR_ME = 1,
    DELETE_FOR_ALL = 2
};

typedef NS_ENUM(NSInteger, Status) {
    ONLINE = 1,
    BUSY,
    AWAY,
    INVISIBLE
};

typedef NS_ENUM(NSInteger, AudioOutputType) {
    SPEAKER = 1,
    EARPIECE,
    WIRED_HEADSET
};

#endif /* YuWeeProtocol_h */
