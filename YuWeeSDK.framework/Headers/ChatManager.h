//
//  ChatManager.h
//  YuWee SDK
//
//  Created by Prasanna Gupta on 26/09/18.
//  Copyright © 2018 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"
#import "FileManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

- (void)fetchChatRoomByUserIds:(NSArray*)arrUserIds
          withAllowReuseOfRoom:(BOOL)allowReuseOfRoom
               withIsBroadcast:(BOOL)isBroadcast
                 withGroupName:(NSString*)groupName
           withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;//Tanay Tested

- (void)fetchChatRoomByEmails:(NSArray*)arrEmails
         withAllowReuseOfRoom:(BOOL)allowReuseOfRoom
              withIsBroadcast:(BOOL)isBroadcast
                withGroupName:(NSString*)groupName
          withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;//Tanay Tested

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

- (void)setNewMessageReceivedDelegate:(id <YuWeeNewMessageReceivedDelegate>) listenerObject; // Tanay Tested

//- (void)shareFile:(NSString*)roomId messageIdentifier:(NSString*)messageIdentifier fileDictionary:(NSDictionary*)fileDictionary quotedMessageId:(nullable NSString*)quotedMessageId; // Tanay Tested

- (void)setTypingEventDelegate:(id <YuWeeTypingEventDelegate>) listenerObject;

- (void)setMessageDeliveredDelegate:(id <YuWeeMessageDeliveredDelegate>) listenerObject;

- (void) forwardMessage:(NSString*)message withRoomId:(NSString*)roomId withMessageIdentifier:(NSString*)messageIdentifier;

//- (void) forwardFile:(NSDictionary*)fileDictionary withRoomId:(NSString*) roomId withMessageIdentifier:(NSString*)messageIdentifier;

- (void) addMembersInGroupByEmail:(NSString*)roomId withArrayOfEmails:(NSArray*)emailArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

- (void) addMembersInGroupByUserId:(NSString*)roomId withArrayOfUserIds:(NSArray*)userArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

- (void) removeMembersFromGroupByUserId:(NSString*)roomId withArrayOfUserIds:(NSArray*)userArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

- (void) removeMembersFromGroupByEmail:(NSString*)roomId withArrayOfEmails:(NSArray*)emailArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

- (void) setMessageDeleteDelegate:(id <YuWeeMessageDeletedDelegate>) listenerObject;

- (FileManager*) getFileManager;

- (void) getRoomDetailsWithRoomId:(NSString*)roomId
              withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

- (void) broadcastMessageWithRoomId:(NSString*)roomId
                        withMessage:(NSString*)message
                withUniqueMessageId:(NSString*)uniqueMessageId
                       withDelegate:(id <YuWeeBroadcastMessageDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
