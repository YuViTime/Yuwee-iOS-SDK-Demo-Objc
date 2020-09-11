//
//  StatusManager.h
//  YuWee SDK
//
//  Created by Arijit Das on 10/02/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface StatusManager : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

-(void)setStatus:(Status)status;

-(void)getParticularUserStatusByEmail:(NSString*)email withCompletionBlock:(UserStatusCompletionBlock)completionBlock;

-(void)getParticularUserStatusByUserId:(NSString*)userId withCompletionBlock:(UserStatusCompletionBlock)completionBlock;

-(void)getParticularUserStatusByContactId:(NSString*)contactId withCompletionBlock:(UserStatusCompletionBlock)completionBlock;

-(void)fetchAllContactsStatus:(UserStatusCompletionBlock)completionBlock;

-(void)setContactStatusChangeDelegate:(id <YuWeeUserStatusChangeDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
