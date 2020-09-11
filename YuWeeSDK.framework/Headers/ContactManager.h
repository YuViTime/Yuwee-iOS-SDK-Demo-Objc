//
//  ContactManager.h
//  YuWee SDK
//
//  Created by Tanay on 04/02/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"
#import "ContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactManager : NSObject
+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

-(void)addContact:(ContactModel *)contactModel withCompletionBlock:(ContactOperationCompletionBlock) completionBlock;
-(void)fetchContactDetailsWithContactId:(NSString *) contactId withCompletionBlock:(ContactOperationCompletionBlock) completionBlock;
-(void)fetchContactList:(ContactOperationCompletionBlock) completionBlock;
-(void)deleteContactWithContactId:(NSString *) contactId withCompletionBlock:(ContactOperationCompletionBlock) completionBlock;


@end

NS_ASSUME_NONNULL_END
