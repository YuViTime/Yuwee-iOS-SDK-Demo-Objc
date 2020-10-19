//
//  yuweeStream.h
//  YuWee SDK
//
//  Created by Arijit Das on 23/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OWT/OWT.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface yuweeStream : NSObject

@property (weak,nonatomic) id <YuWeeRemoteStreamSubscriptionDelegate> delegate;
@property (strong,nonatomic) OWTConferenceSubscription *subscriptionObj;
@property (strong,nonatomic) OWTRemoteStream *stream;

@end

NS_ASSUME_NONNULL_END
