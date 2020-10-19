//
//  ChatManager.h
//  YuWee SDK
//
//  Created by Prasanna Gupta on 26/09/18.
//  Copyright © 2018 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

- (void)fetchChatRoomByUserIds:(NSArray*)arrUserIds withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;//Tanay Tested

- (void)fetchChatRoomByEmails:(NSArray*)arrEmails withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;//Tanay Tested

- (void)fetchChatListWithCompletionBlock:(ChatOperationCompletionBlock)completionBlock; //Tanay Tested

- (void)fetchChatMessagesForRoomId:(NSString*)strRoomId totalMessagesCountToSkip:(NSInteger)totalFetchedMessages withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;//Tanay Tested

- (void)markMessagesAsReadInRoomId:(NSString*)strRoomId;//Tanay Tested

- (void)markSingleMessageAsReadInRoomId:(NSString*)strRoomId
                              messageId:(NSString*)messageId; // Tanay Tested

- (void)sendTypingStatusToRoomId:(NSString*)strRoomId; //Tested

- (void)sendMessage:(NSString*)strMessage
           toRoomId:(NSString*)strRoomId
  messageIdentifier:(NSString*)strBrowserMessageId
withQuotedMessageId:(nullable NSString*)quotedMessageId; // Tanay tested but not quote

- (void)clearChatsForRoomId:(NSString*)strRoomId withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;//Tanay Tested

- (void)deleteChatRoom:(NSString*)strRoomId withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;//Tanay Tested


- (void)deleteMessageForMessageId:(NSString*)strMessageId roomId:(NSString*)strRoomId deleteType:(enum DeleteType)deleteType withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

- (void)getUserLastSeen:(NSString *)userId
    withCompletionBlock:(UserLastSeenCompletionBlock)completionBlock;

- (void)setOnNewMessageReceivedDelegate:(id <YuWeeNewMessageReceivedDelegate>) listenerObject; // Tanay Tested

- (void)shareFile:(NSString*)roomId messageIdentifier:(NSString*)messageIdentifier fileDictionary:(NSDictionary*)fileDictionary quotedMessageId:(nullable NSString*)quotedMessageId; // Tanay Tested

- (void)setOnTypingEventDelegate:(id <YuWeeTypingEventDelegate>) listenerObject;

- (void)setOnMessageDeliveredDelegate:(id <YuWeeMessageDeliveredDelegate>) listenerObject;

- (void) forwardMessage:(NSString*)message withRoomId:(NSString*)roomId withMessageIdentifier:(NSString*)messageIdentifier;

- (void) forwardFile:(NSDictionary*)fileDictionary withRoomId:(NSString*) roomId withMessageIdentifier:(NSString*)messageIdentifier;

- (void) addMembersInGroupByEmail:(NSString*)roomId withArrayOfEmails:(NSArray*)emailArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

- (void) addMembersInGroupByUserId:(NSString*)roomId withArrayOfUserIds:(NSArray*)userArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

- (void) removeMembersFromGroupByUserId:(NSString*)roomId withArrayOfUserIds:(NSArray*)userArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

- (void) removeMembersFromGroupByEmail:(NSString*)roomId withArrayOfEmails:(NSArray*)emailArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

- (void) setOnMessageDeleteDelegate:(id <YuWeeMessageDeletedDelegate>) listenerObject;

@end

NS_ASSUME_NONNULL_END
