//
//  YWScreenShare.h
//  YuWeeScreenShare
//
//  Created by Tanay on 10/11/20.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnInitScreenSharingCompletionHandler)(NSString *dict, BOOL success);

@interface YWScreenShare : NSObject

/// Initiate screen sharing with data. The data needs to be in below format
-(void)initScreenSharingWithAuthToken:(NSString*)authToken
                         withNickName:(NSString*)nickName
                           withUserId:(NSString*)userId
                            withEmail:(NSString*)email
                        withMeetingId:(NSString*)meetingId
                         withPasscode:(NSString*)passcode
                withCompletionHandler:(OnInitScreenSharingCompletionHandler)handler;

/// Send CVPixelBufferRef to process.
-(void)processScreenFrameWithPixelBuffer:(CVPixelBufferRef)cvPixelBuffer;

/// Call this when screen sharing ends.
-(void)cleanUp;

-(void)setEnvironment:(BOOL)isDev;

@end

NS_ASSUME_NONNULL_END
