//
//  RecentCallManager.h
//  YuWee SDK
//
//  Created by Prasanna Gupta on 08/10/18.
//  Copyright © 2018 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface RecentCallManager : NSObject

- (void)getRecentCallsWithTotalNumberOfRecentCalls:(NSInteger)skipFetchedCallsCount withCompletionBlockHandler:(CallCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
