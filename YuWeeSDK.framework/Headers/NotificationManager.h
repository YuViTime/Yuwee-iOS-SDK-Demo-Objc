//
//  NotificationManager.h
//  YuWee SDK
//
//  Created by Prasanna Gupta on 09/10/18.
//  Copyright © 2018 Prasanna Gupta. All rights reserved.
//

#import <CallKit/CallKit.h>
#import <PushKit/PushKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationManager : NSObject <PKPushRegistryDelegate,CXProviderDelegate,UNUserNotificationCenterDelegate>

@property (weak,nonatomic) id <YuWeePushManagerDelegate> delegate;
@property (strong,nonatomic) NSString *callerName;
@property (strong,nonatomic) NSString *uniqueIdentifier;
@property (strong,nonatomic) CXProvider *provider;

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

- (void)dailedCallTimedOutSend:(NSDictionary *)dictRecentCall;

- (void)initWithListnerObject:(id <YuWeePushManagerDelegate>)listenerObject;

- (void)processMessageDataFromNotificationDetails:(NSDictionary *)dictResponse;

- (void)pushRegistryDidReceivedPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
