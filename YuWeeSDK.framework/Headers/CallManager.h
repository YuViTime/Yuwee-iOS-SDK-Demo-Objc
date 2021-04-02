//
//  CallManager.h
//  YuWee SDK
//
//  Created by Prasanna Gupta on 04/09/18.
//  Copyright © 2018 Prasanna Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CallParams.h"
#import "YuWeeProtocol.h"
#import "ChatManager.h"
#import "YuweeVideoView.h"
#import "YuweeRemoteVideoView.h"
#import "YuweeLocalVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CallManager : NSObject <UIGestureRecognizerDelegate>

+ (nonnull instancetype)sharedInstance;
- (nonnull instancetype)init NS_UNAVAILABLE;

- (void)setUpCall:(nonnull CallParams *)callParams withClassListnerObject:(nonnull id <YuWeeCallSetUpDelegate>)listenerObject;

- (void)setCallManagerDelegate:(nonnull id <YuWeeCallManagerDelegate>)listenerObject;

- (void)setOnMemberAddedOnCallDelegate:(nonnull id <YuWeeOnMemberAddedOnCallDelegate>)listenerObject;

- (void)setIncomingCallEventDelegate:(nonnull id <YuWeeIncomingCallEventDelegate>)listenerObject;

- (void)setUpIncomingCallWithClassListnerObject:(nonnull id <YuWeeCallManagerDelegate>)listenerObject;

- (void)addMemberOnCall:(nonnull NSArray *)arrNewPaticipants andGroupName:(nullable NSString *)strGroupName withCompletionBlock:(AddMembersInGroupCompletionBlock _Nonnull)completionBlock;

- (void)hangUpCallWithCompletionBlockHandler:(nonnull CallHangUpCompletionBlock)completionBlock;

- (void)initCallWithLocalView:(nonnull YuweeLocalVideoView *)localView withRemoteView:(nonnull YuweeRemoteVideoView *)remoteView;

- (BOOL)isCallRunning;

- (void)timeOutIncomingCall;

- (void)notifyRingingWithCallId:(nonnull NSString*)callId withRoomId:(nonnull NSString*)roomId;

- (void)processAddMemberToInitiateMCUCallWithDictionary:(nonnull NSDictionary*)responseObject;

- (void)startVideoSource;

- (void)stopVideoSource;

- (void)setVideoEnabled:(BOOL)isEnabled;

- (void)switchCamera;

- (void)setAudioOutputType:(AudioOutputType)audioOutputType;

- (void)setAudioEnabled:(BOOL)isEnabled;

- (void)onMuteAudioOutputSpeaker:(BOOL)enabled;

- (void)rejectIncomingCall:(nonnull NSDictionary *)dictResponceForCurrentCall;

- (void)acceptIncomingCall:(nonnull NSDictionary *)dictResponceForCurrentCall;

- (void)getRecentCall:(nonnull NSString*)skip withCompletionBlock:(nonnull FetchRecentCallCompletionBlock)completionBlock;

- (void)joinOngoingCall:(nonnull NSString *)callId MediaType:(MediaType)mediaType withCompletionHandler:(RecentCallCompletionBlock)completionBlock;

- (void)joinMeeting:(NSString *)callId withGroup:(BOOL)isGroup GroupId:(nullable NSString *)groupId ConferenceId:(nullable NSString *)conferenceId MediaType:(MediaType)mediaType withCompletionHandler:(SecheduleCallCompletionBlock)completionBlock;


#pragma mark - ScheduleManager Methods

- (void)setOnScheduleCallEventsDelegate:(nonnull id <YuWeeScheduleCallManagerDelegate>)listenerObject;

- (void)scheduleMeeting:(nonnull NSDictionary *)dictCallParamsObj withCompletionBlock:(ScheduleCallCompletionBlock)completionBlock;

- (void)deleteMeeting:(nonnull NSDictionary*)dictRequest withCompletionBlock:(ScheduleCallCompletionBlock)completionBlock;

- (void)joinMeetingWithCallId:(nonnull NSString*)callId withMediaType:(nonnull NSString*)mediaType;

- (void)getAllUpcomingCalls:(ScheduleCallCompletionBlock)completionBlock;

- (void)getRecentCallsWithTotalNumberOfRecentCalls:(NSInteger)skipFetchedCallsCount withCompletionBlockHandler:(CallCompletionBlock)completionBlock;

@property (assign,nonatomic) BOOL isCallTypeVideo;
@property (assign,nonatomic) BOOL isScreenSharingOn;
@property (strong, nonatomic,nonnull) YuweeVideoView *videoView;
@property (strong, nonatomic,nonnull) YuweeVideoView *screenView;

@end

NS_ASSUME_NONNULL_END
