//
//  ConnectionManager.h
//  YuWee SDK
//
//  Created by Tanay on 12/02/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConnectionManager : NSObject
+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

//boolean isConnected();
//
//void forceConnect();
//
//void setConnectionListener(@NonNull YuWee.OnYuWeeConnectionListener listener);

- (BOOL) isConnected;

- (void) forceReconnect;

- (void) disconnect;

- (void) setConnectionDelegate:(id <YuWeeConnectionDelegate>) yuweeConnectionDelegate;
@end

NS_ASSUME_NONNULL_END
