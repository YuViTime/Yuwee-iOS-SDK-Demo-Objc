//
//  MeetingManagerObjc.h
//  YuWee SDK
//
//  Created by Arijit Das on 22/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "YuweeVideoView.h"
#import "YuWeeProtocol.h"
#import "EditMeetingBody.h"
#import "MeetingParams.h"
#import "MuteUnmuteBody.h"
#import "HandRaiseBody.h"
#import "HostMeetingBody.h"
#import "CallAdminBody.h"
#import "CallPresenterBody.h"
#import "RegisterMeetingBody.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnMeetingCompletionHandler)(NSDictionary *dict, BOOL success);

typedef NS_ENUM(NSUInteger, RoleType) {
    presenter,
    subPresenter,
    viewer,
};

@interface MeetingManagerObjc : NSObject

+ (nonnull instancetype)sharedInstance;
- (nonnull instancetype)init NS_UNAVAILABLE;

- (void)setMeetingDelegate:(nonnull id <OnHostedMeetingDelegate>)listenerObject;

// main call functions

- (void)joinMeeting:(MeetingParams *) meetingParams withlistener:(OnMeetingCompletionHandler)completionHandler;

- (void)hostMeeting:(HostMeetingBody *) hostMeetingBody withlistener:(OnMeetingCompletionHandler)completionHandler;

- (void)registerInMeeting:(RegisterMeetingBody *) registerMeetingBody withlistener:(OnMeetingCompletionHandler)completionHandler;

- (NSMutableArray<OWTRemoteStream *> *)getAllRemoteStream;


- (void)attachLocalCameraStream:(YuweeVideoView *)videoView;
//    - (void)attachLocalScreenStream(videoView: YuweeVideoView) // doc
- (void)detachLocalCameraStream:(YuweeVideoView *)videoView;
//    - (void)detachLocalScreenStream(videoView: YuweeVideoView) // doc

- (void)attachRemoteStream:(OWTRemoteStream *)stream withVideoView:(YuweeVideoView *)videoView withlistener:(OnMeetingCompletionHandler)completionHandler;
- (void)subscribeRemoteStream:(OWTRemoteStream *)stream withlistener:(id<YuWeeRemoteStreamSubscriptionDelegate>)listener;
- (void)publishCameraStream:(RoleType)roleType withlistener:(OnMeetingCompletionHandler)completionHandler;
- (void)unpublishCameraStream;


//- (void)publishScreenStream(roleType: RoleType, listener: OnPublishStreamCompletionHandler) // tested. doc
//- (void)unpublishScreenStream() // tested. doc

- (void)switchCamera:(RoleType)roleType withlistener:(OnMeetingCompletionHandler)completionHandler;
- (void)setSpeakerEnabled:(BOOL)isSpeakerEnabled;
- (void)setMediaEnabled:(BOOL)isAudioEnabled withVideoEnabled:(BOOL)isVideoEnabled withlistener:(OnMeetingCompletionHandler)completionHandler; // Need to test
- (void)leaveMeeting:(OnMeetingCompletionHandler)completionHandler;
- (void)endMeeting:(OnMeetingCompletionHandler)completionHandler;


// normal apis

- (void)fetchActiveMeetings:(OnMeetingCompletionHandler)completionHandler;
- (void)deleteMeeting:(NSString *)meetingTokenId withlistener:(OnMeetingCompletionHandler)completionHandler;
- (void)editMeeting:(EditMeetingBody *)body withlistener:(OnMeetingCompletionHandler)completionHandler;

// call specific apis

- (void)toggleParticipantAudio:(MuteUnmuteBody *)body withlistener:(OnMeetingCompletionHandler)completionHandler;
- (void)toggleHandRaise:(HandRaiseBody *)body withlistener:(OnMeetingCompletionHandler)completionHandler; // Need to test
- (void)dropParticipant:(NSString *)userId withlistener:(OnMeetingCompletionHandler)completionHandler;
- (void)updatePresenterStatus:(CallPresenterBody *)body roleType:(RoleType)roleType withlistener:(OnMeetingCompletionHandler)completionHandler;
- (void)makeOrRevokeAdmin:(CallAdminBody *)body withlistener:(OnMeetingCompletionHandler)completionHandler; 
- (void)fetchActiveParticipantsList:(OnMeetingCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
