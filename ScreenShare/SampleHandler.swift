//
//  SampleHandler.swift
//  ScreenShare
//
//  Created by Tanay on 23/02/21.
//  Copyright © 2021 Prasanna Gupta. All rights reserved.
//

import ReplayKit
import YuWeeScreenShare
import MMWormhole

class SampleHandler: RPBroadcastSampleHandler {
    
    var ywScreenShare : YWScreenShare
    var authToken : String, nickName : String, userId : String, email : String, meetingId : String, passCode : String
    
    override init() {
        ywScreenShare = YWScreenShare()
        ywScreenShare.setEnvironment(true)
    
//        let wormhole = MMWormhole(applicationGroupIdentifier: "group.com.yuwee.sdkdemo.new", optionalDirectory: "wormhole")
//        let data = wormhole.message(withIdentifier: "data");
//        print(data)
        
        let ud = UserDefaults(suiteName: "group.com.yuwee.sdkdemo.new")
        authToken = ud?.object(forKey: "ss_auth_token") as! String
        nickName = ud?.value(forKey: "ss_nick_name") as! String
        userId = ud?.value(forKey: "ss_user_id") as! String
        email = ud?.value(forKey: "ss_email") as! String
        meetingId = ud?.value(forKey: "ss_meeting_id") as! String
        passCode = ud?.value(forKey: "ss_pass_code") as! String
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {

        
        ywScreenShare.initScreenSharing(withAuthToken: authToken, withNickName: nickName, withUserId: userId, withEmail: email, withMeetingId: meetingId, withPasscode: passCode) { (message, isSuccess) in
            print(message)
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            ywScreenShare.processScreenFrame(with: pixelBuffer)
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}
