//
//  MeetingViewController.swift
//  YuWee SDK
//
//  Created by Tanay on 31/08/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

import UIKit

class MeetingViewController: UIViewController {
    
    
    var nickName = UserDefaults.init(suiteName: "123")?.object(forKey: kName) as! String
    var guestId = UserDefaults.init(suiteName: "123")?.object(forKey: kEmail) as! String
    var passcode = ""
    var meetingTokenId = ""
    var dictMeeting: [String : Any] = [:]
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtTokenId: UITextField!
    @IBOutlet var txtPasscode: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtName.text = nickName
        txtEmail.text = guestId
        txtTokenId.text = meetingTokenId
        txtPasscode.text = passcode
        
    }
    
    @IBAction func btnRegister(_ sender: UIButton) {
        
        let join = JoinMedia()
        
        join.audio = true
        join.video = true
        
        let meetingbody = RegisterMeetingBody()
        
        meetingbody.nickName = self.txtName.text!
        meetingbody.guestId = self.txtEmail.text!
        meetingbody.joinMedia = join
        meetingbody.meetingTokenId = self.txtTokenId.text!
        meetingbody.passcode = self.txtPasscode.text!
        
        //                    [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[kResult][kUser][k_Id] forKey:@"ss_user_id"];
        //[[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[kResult][kUser][kName] forKey:@"ss_nick_name"];
        
        let ud = UserDefaults(suiteName: "group.com.yuwee.sdkdemo.new")
        ud?.setValue(self.txtTokenId.text!, forKey: "ss_meeting_id")
        ud?.setValue(self.txtPasscode.text!, forKey: "ss_pass_code")
        ud?.synchronize()
        
        Yuwee.sharedInstance().getMeetingManager().register(inMeeting: meetingbody) { (dictResponse, isSuccess) in
            
            if (isSuccess) {
                
                print("\(dictResponse)")
                
                let result = dictResponse["result"] as! [String : Any]
                let callData = (result["callData"] as? [String : Any])!
                let isTraining = (callData["callMode"] as? NSNumber)?.boolValue
                

                let isPresenter = (result["isPresenter"] as? NSNumber)?.boolValue
                
                var isSubPresenter = false
                
                let subPresenter = result["role"] as? String
                isSubPresenter = (subPresenter == "subPresenter") ? true : false
                
                let vc = ContainerViewController()
                vc.modalPresentationStyle = .overCurrentContext
                vc.callTokenInfo = (result["callTokenInfo"] as? [String : Any])!
                vc.dictRecievedCallStatusData = callData
                vc.strMeetingName = (result["meetingName"] as? String)!
                vc.meetingTokenId = self.txtTokenId.text!
                vc.isTraining = isTraining!
                vc.isPresenter = isPresenter!
                vc.isSubPresenter = isSubPresenter
                vc.mediaInfo = (result["mediaInfo"] as? [String : Any])!
                vc.isCallTypeVideo = meetingbody.joinMedia.audio
                vc.isCallTypeAudio = meetingbody.joinMedia.audio
                AppDelegate.sharedInstance()?.topViewController().present(vc, animated: true, completion: nil)
                
            } else {
                print("error")
                
                let message = dictResponse["message"] as! String
                
                AppDelegate.sharedInstance()?.showToast(message)
            }
        }
        
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

}

extension Dictionary {
  func allKeys() -> [String] {
    guard self.keys.first is String else {
      debugPrint("This function will not return other hashable types. (Only strings)")
      return []
    }
    return self.compactMap { (anEntry) -> String? in
                          guard let temp = anEntry.key as? String else { return nil }
                          return temp }
  }
}
