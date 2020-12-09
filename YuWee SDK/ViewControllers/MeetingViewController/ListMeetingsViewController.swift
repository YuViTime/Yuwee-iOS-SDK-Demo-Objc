//
//  ListMeetingsViewController.swift
//  YuWee SDK
//
//  Created by Arijit Das on 08/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

import UIKit

class ListMeetingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userEmail = UserDefaults.standard.object(forKey: kEmail) as! String
    var arrMeetings: [[String : Any]] = []
    
    @IBOutlet var tableMeetings: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Yuwee.sharedInstance().getCallManager().setVideoEnabled(false)
        tableMeetings.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        Yuwee.sharedInstance().getMeetingManager().fetchActiveMeetings { (dictResponse, isSuccess) in
            
            if (isSuccess) {
                print("\(dictResponse)")
                let result = dictResponse["result"] as! [[String : Any]]
                self.arrMeetings = result.filter({$0["isDeleted"] as! Int == 0})
                self.tableMeetings.reloadData()
                
                /*let dictMeeting = self.arrMeetings[3]
                let callId = dictMeeting["callId"] as! [String : Any]
                
                let editBody = EditMeetingBody()
                
                editBody.callMode = Int32(callId["callMode"] as! Int)
                editBody.meetingName = dictMeeting["meetingName"] as! String
                editBody.meetingTokenId = dictMeeting["meetingTokenId"] as! String
                editBody.isCallAllowedWithoutInitiator = dictMeeting["isCallAllowedWithoutInitiator"] as! Bool
                editBody.maxAllowedParticipant = 15
                editBody.meetingExpirationTime = Int32((callId["meetingExpirationTime"] as! NSNumber).int32Value)
                editBody.meetingStartTime = Int32((callId["meetingStartTime"] as! NSNumber).int32Value)
                editBody.addCallAdmin = NSMutableArray()
                editBody.removeCallAdmin = NSMutableArray()
                editBody.addPresenter = NSMutableArray()
                editBody.removePresenter = NSMutableArray()
                
                Yuwee.sharedInstance().getMeetingManager().editMeeting(editBody, withlistener: { (dictResponse, isSuccess) in
                    
                    if (isSuccess) {
                        print("\(dictResponse)")
                    }
                }) */
            } else {
                print("error")
                
                let message = dictResponse["message"] as! String
                
                AppDelegate.sharedInstance()?.showToast(message)
            }
        }
        
//        Yuwee.sharedInstance().getMeetingManager().deleteMeeting("meetingTokenId") { (dictResponse, isSuccess) in
//            if (isSuccess) {
//                print("\(dictResponse)")
//            }
//        }
    }
    
    @IBAction func btnHost(_ sender: UIButton) {
        let meetingbody = HostMeetingBody()
        
       // print("\(Int(Date().millisecondsSince1970 + (60*1000)))")
        
        meetingbody.meetingName = "demo 2"
        meetingbody.maxAllowedParticipant = 20
        meetingbody.meetingStartTime = Int(Date().millisecondsSince1970 + (60*1000))
        meetingbody.meetingExpireDuration = 120
        meetingbody.callMode = 1
        meetingbody.callAdmins = ["a1@a.com"]
        meetingbody.presenters = ["a1@a.com", "a2@a.com"]
        
        Yuwee.sharedInstance().getMeetingManager().hostMeeting(meetingbody) { (dictResponse, isSuccess) in
            
            if (isSuccess) {
                print("\(dictResponse)")
                Yuwee.sharedInstance().getMeetingManager().fetchActiveMeetings { (dictResponse, isSuccess) in
                    
                    if (isSuccess) {
                        print("\(dictResponse)")
                        let result = dictResponse["result"] as! [[String : Any]]
                        self.arrMeetings = result.filter({$0["isDeleted"] as! Int == 0})
                        self.tableMeetings.reloadData()
                    } else {
                        print("error")
                        
                        let message = dictResponse["message"] as! String
                        
                        AppDelegate.sharedInstance()?.showToast(message)
                    }
                }
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
    
    
    //MARK:- UITableView Delegate & DataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMeetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let strIdentifier = "cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: strIdentifier, for: indexPath) as! ListTableViewCell
        
        let data = arrMeetings[indexPath.row]
        
//        cell.lblMeeting.font = UIFont(name: "AmpleSoft", size: 17)
//        cell.lblDateTime.font = UIFont(name: "AmpleSoft", size: 14)
        
        let meetingTokenId: String? = data["meetingTokenId"] as? String
        let meetingStartTime: String? = data["meetingStartTime"] as? String
        
        cell.lblMeeting.text = meetingTokenId
        cell.lblDateTime.text = meetingStartTime
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableMeetings.deselectRow(at: indexPath, animated: true)
        let data = arrMeetings[indexPath.row]
        let callId = data["callId"] as? [String : Any]
        let vc: MeetingViewController = (self.storyboard?.instantiateViewController(withIdentifier: "MeetingViewController"))! as! MeetingViewController
        vc.meetingTokenId = (data["meetingTokenId"] as? String)!
        if (((callId!["callMode"] as? Int) == 1) && (((callId!["presenters"] as? [String])?.contains(userEmail)) != nil)) {
            vc.passcode = (data["presenterPasscode"] as? String)!
        } else {
            vc.passcode = (data["passcode"] as? String)!
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
