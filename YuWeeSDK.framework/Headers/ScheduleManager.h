//
//  ScheduleManager.h
//  YuWee SDK
//
//  Created by Prasanna Gupta on 20/09/18.
//  Copyright © 2018 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleManager : NSObject <YuWeeScheduleCallManagerDelegate>

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

- (void)setOnScheduleCallEventsDelegate:(id <YuWeeScheduleCallManagerDelegate>)listenerObject;

- (void)scheduleMeeting:(NSDictionary *)dictCallParamsObj withCompletionBlock:(ScheduleCallCompletionBlock)completionBlock;

- (void)deleteMeeting:(NSDictionary*)dictRequest withCompletionBlock:(ScheduleCallCompletionBlock)completionBlock;

- (void)joinMeetingWithCallId:(NSString*)callId withMediaType:(NSString*)mediaType;

- (void)getAllUpcomingCalls:(ScheduleCallCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
