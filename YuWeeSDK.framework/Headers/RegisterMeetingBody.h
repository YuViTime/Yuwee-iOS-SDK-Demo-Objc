//
//  RegisterMeetingBody.h
//  YuWee SDK
//
//  Created by Arijit Das on 23/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JoinMedia.h"

NS_ASSUME_NONNULL_BEGIN

@interface RegisterMeetingBody : NSObject

//private var platform: String = "mobile"

//var joinMedia = JoinMedia()

@property (strong,nonatomic) NSString *nickName;
@property (strong,nonatomic) NSString *meetingTokenId;
@property (strong,nonatomic) NSString *passcode;
@property (strong,nonatomic) NSString *guestId;
@property (strong,nonatomic) JoinMedia *joinMedia;

@end

NS_ASSUME_NONNULL_END
