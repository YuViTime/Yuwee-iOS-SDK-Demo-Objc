//
//  NotificationService.m
//  notification
//
//  //Created by Yuwee on 23/03/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "NotificationService.h"
#import <YuWeeSDK/YuWeeProtocol.h>
#define kData @"data"
#define kName @"name"
#define kMessage @"message"
#define kSender @"sender"
#define kGroup @"group"

@interface NotificationService () <YuWeePushManagerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
     
     NSLog(@"%@",self.bestAttemptContent.userInfo);
     
     NSMutableDictionary *dictResponse = [NSMutableDictionary dictionaryWithDictionary:self.bestAttemptContent.userInfo];
    
  //  [[[Yuwee sharedInstance] getNotificationManager] initWithListnerObject:self];
    
  //  [[[Yuwee sharedInstance] getNotificationManager] processMessageDataFromNotificationDetails:dictResponse];

}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
   // self.contentHandler(self.bestAttemptContent);
}

#pragma mark- YuWeePushManagerDelegate

- (void)onChatMessageReceivedFromPush:(NSDictionary *)dictResponse{
    
    NSLog(@"dictResponse: %@",dictResponse);
     
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@",dictResponse[kName]];
     
    self.bestAttemptContent.body = [NSString stringWithFormat:@"%@", dictResponse[kMessage]];
    
    NSLog(@"%@",self.bestAttemptContent);
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)onReceiveCallFromPush:(NSDictionary *)dictResponse{
    
    NSLog(@"dictResponse: %@",dictResponse);
}

- (void)onNewScheduleMeetingFromPush:(NSDictionary *)dictResponse{
    
    NSLog(@"dictResponse: %@",dictResponse);
}

- (void)onScheduleMeetingJoinFromPush:(NSDictionary *)dictResponse{
    
    NSLog(@"dictResponse: %@",dictResponse);
}

@end
