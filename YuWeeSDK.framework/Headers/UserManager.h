//
//  UserManager.h
//  YuWee SDK
//
//  Created by Prasanna Gupta on 05/09/18.
//  Copyright © 2018 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"
#import "CallManager.h"
#import "InitParam.h"
#import "ScheduleManager.h"
#import "ChatManager.h"
#import "NotificationManager.h"
#import "RecentCallManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject

+ (instancetype)sharedInstance;
- (nonnull instancetype)init NS_UNAVAILABLE;

//Create User/Register User
- (void)createUserWithName:(NSString*)strUserName
              Email:(NSString*)strEmail
           Password:(NSString*)strPassword
withCompletionBlock:(CreateUserCompletionBlock)createUserCompletionHandler;

//Register Push Token
- (void)registerPushTokenAPNS:(NSString*)strAPNS
              VOIP:(NSString*)strVOIP
          withCompletionBlock:(OnRegisterPushTokenCompletionBlock)registerTokenCompletionHandler;

//Create Session
- (void)createSessionViaCredentialsWithEmail:(nonnull NSString *)strEmail
           Password:(nonnull NSString *)strPassword
         ExpiryTime:(nonnull NSString *)expiryTime
withCompletionBlock:(LoginCompletionBlock)loginCompletionHandler;

- (void)createSessionViaToken:(InitParam *)initParam withCompletionBlock:(OnCreateSessionViaTokenCompletionBlock)completionHandler;

- (BOOL)isLoggedIn;

- (void)logout;

@end

NS_ASSUME_NONNULL_END
