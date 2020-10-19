//
//  MessageDetails.h
//  YuWee SDK
//
//  //Created by Yuwee on 30/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageDetails : NSObject

@property (strong, nonatomic) IBOutlet NSString *senderName, *senderId, *senderEmail;
@property (strong, nonatomic) IBOutlet NSString *message, *messageType, *messageId, *browserMessageId, *messageTime;
@property (strong, nonatomic) IBOutlet NSString *fileUrl;

@end

NS_ASSUME_NONNULL_END
