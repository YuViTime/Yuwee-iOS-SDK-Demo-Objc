//
//  YWRTCFrameCapturer.h
//  YuWeeScreenShare
//
//  Created by Tanay on 11/11/20.
//

#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@interface YWRTCFrameCapturer : RTCVideoCapturer

-(void)capture:(CVPixelBufferRef)cvPixelBufferref;

@end

NS_ASSUME_NONNULL_END
