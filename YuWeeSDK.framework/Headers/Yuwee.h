//
//  Yuwee.h
//  YuWee SDK
//
//  Created by Tanay on 30/01/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManager.h"
#import "ChatManager.h"
#import "StatusManager.h"
#import "ContactManager.h"
#import "ConnectionManager.h"
#import "NotificationManager.h"
#import "CallManager.h"
#import "CallParams.h"
#import "YuWeeProtocol.h"
#import "YuweeVideoView.h"
#import "YuweeLocalVideoView.h"
#import "YuweeRemoteVideoView.h"
#import "MeetingManagerObjc.h"
//#import "YuWee_SDK-Swift.h"

//@class UserManager;
//@class NotificationManager;

NS_ASSUME_NONNULL_BEGIN

@interface Yuwee : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

- (void)initApp;

- (void)initWithAppId:(NSString *) appId
            AppSecret:(NSString *) appSecret
             ClientId:(NSString *) clientId;

- (void)restartAppConnection;

- (void)dismissAppConnection;

- (void)setMode:(BOOL)isLogEnabled with:(BOOL)isDev;

- (UserManager *)getUserManager;
- (ChatManager *)getChatManager;
- (ConnectionManager *)getConnectionManager;
- (StatusManager *)getStatusManager;
- (ContactManager *)getContactManager;
- (NotificationManager *)getNotificationManager;
- (CallManager *)getCallManager;
- (MeetingManagerObjc *)getMeetingManager;

@end

NS_ASSUME_NONNULL_END
