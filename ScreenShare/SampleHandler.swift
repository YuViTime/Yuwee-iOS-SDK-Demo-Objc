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
import SwiftyJSON

class SampleHandler: RPBroadcastSampleHandler {
    
    var ywScreenShare : YWScreenShare
    var authToken : String, nickName : String, userId : String, email : String, meetingId : String, passCode : String
    var callRecordingId = ""
    var mongoId = ""
    var wormhole = MMWormhole(applicationGroupIdentifier: "group.com.yuwee.sdkdemo.new", optionalDirectory: "wormhole")

    
    override init() {
        ywScreenShare = YWScreenShare()
        
        
        
        let ud = UserDefaults(suiteName: "group.com.yuwee.sdkdemo.new")
        authToken = ud?.object(forKey: "ss_auth_token") as! String
        nickName = ud?.value(forKey: "ss_nick_name") as! String
        userId = ud?.value(forKey: "ss_user_id") as! String
        email = ud?.value(forKey: "ss_email") as! String
        meetingId = ud?.value(forKey: "ss_meeting_id") as! String
        passCode = ud?.value(forKey: "ss_pass_code") as! String
        
        super.init()
        self.initWormhole()
    }
    
    private func initWormhole(){
        wormhole.listenForMessage(withIdentifier: "recording") { (messageObject) -> Void in
            if let message = messageObject as? String{
                if message == "true" {
                    print("recording started")
                    let ud = UserDefaults(suiteName: "group.com.yuwee.sdkdemo.new")
                    self.mongoId = ud?.value(forKey: "ss_mongo_id") as! String
                    
                    self.ywScreenShare.startCallRecording(with: RoleType.presenter, withMId: self.mongoId) { (recordingData, isSuccess) in
                        if isSuccess{
                            let recording = JSON(recordingData)
                            self.callRecordingId = recording["recordingId"].string!
                            print("Start Call Recording Success: \(self.callRecordingId)")
                        }
                    }
                }
            }
        }
        
        wormhole.listenForMessage(withIdentifier: "finishBroadcast") { (messageObject) in
            if let message = messageObject as? String{
                if message == "true" {
                    print("recording stopped")
                    self.ywScreenShare.cleanUp()
                    self.stopRecording()
                }
            }
        }
    }
    
    private func stopRecording(){
        ywScreenShare.stopCallRecording(withRecordingId: callRecordingId, withMId: mongoId) { (message, isSuccess) in
            
            let userInfo = [NSLocalizedFailureReasonErrorKey: "Screen Sharing is Finished"]
            let error = NSError(domain: "ScreenShare", code: -1, userInfo: userInfo)
            
            self.finishBroadcastWithError(error)
        }
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        
        if self.meetingId == "" {
            let userInfo = [NSLocalizedFailureReasonErrorKey: "No Active Meeting Found"]
            let error = NSError(domain: "ScreenShare", code: -1, userInfo: userInfo)

            finishBroadcastWithError(error)
            return
        }

        
        ywScreenShare.initScreenSharing(withAuthToken: authToken, withNickName: nickName, withUserId: userId, withEmail: email, withMeetingId: meetingId, withPasscode: passCode) { (message, isSuccess) in
            print(message)
            if isSuccess{
                print("init success")
                //self.startSceenRecoeding()
            }
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
