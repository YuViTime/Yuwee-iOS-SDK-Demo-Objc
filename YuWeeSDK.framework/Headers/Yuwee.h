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
#import "YuweeControl.h"
#import "YuweeVideoView.h"
#import "YuweeLocalVideoView.h"
#import "YuweeRemoteVideoView.h"

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

- (UserManager *)getUserManager;
- (ChatManager *)getChatManager;
- (StatusManager *)getStatusManager;
- (ContactManager *)getContactManager;
- (ConnectionManager *)getConnectionManager;
- (NotificationManager *)getNotificationManager;
- (CallManager *)getCallManager;

@end

NS_ASSUME_NONNULL_END
