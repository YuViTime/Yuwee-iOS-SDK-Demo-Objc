//
//  RightMenuNavigationController.swift
//  YuWee
//
//  Created by Arijit Das on 27/07/20.
//  Copyright © 2020 DAT-Asset-158. All rights reserved.
//

import UIKit
import Foundation

class SideMenuTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SideMenuCellDelegate {
    
    static let identifier = "cell"
    
    var index = 0
    var isOptionClicked = false
    var isTraining = false
    var strCallId: String?
    var adminEmailArr: [String] = []
    var isAdmin = false
    var optionsArr: [String] = []
    var typeArr: [String] = ["subPresenter", "presenter", "viewer"]
    var dictRecievedCallStatusData: [String : Any]?
    var arrMembers: [[String : Any]] = []
    var dictMember: [String : Any] = [:]
    var tableMoreOption: UITableView!
    
    var delegateRemove: ConferenceCallViewDelegate?
    
    @IBOutlet var tblSideMenu: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        strCallId = dictRecievedCallStatusData![kCallId] as? String
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tblSideMenu.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tblSideMenu.tableFooterView = UIView(frame: .zero)
        self.tblSideMenu.delegate = self
        self.tblSideMenu.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moveAppOrientationMode(withMode: UIDeviceOrientation.landscapeLeft.rawValue)
        self.view.frame = CGRect(x: self.view.bounds.origin.x,
        y: self.view.bounds.origin.y,
        width: self.view.bounds.width,
        height: UIScreen.main.bounds.size.height)
        debugPrint("\(self.view.frame.size.height)")
    }
    
    func moveAppOrientationMode(withMode orientationMode: Int) {
        let value = orientationMode
        UIDevice.current.setValue(value, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    public func setUserAdmin(isUserAdmin: Bool) {
        isAdmin = isUserAdmin
    }
    
    public func reloadTabelWithData(arr: [[String : Any]]) {
        if (arr.count>0) {
            isOptionClicked = false
            self.arrMembers = arr
            self.tblSideMenu.reloadData()
        }
    }
    
    public func reloadTabelWithParticipantOnly(dict: [String : Any]) {
        if let i = self.arrMembers.firstIndex(where: {$0["email"] as! String == dict["email"] as! String}) {
            let obj = self.arrMembers[i]
            debugPrint("\(obj)")
            isOptionClicked = false
            self.arrMembers[i] = dict
        }
        self.tblSideMenu.reloadData()
    }
    
    func hideAudioPressed(_ isSelected: Bool, onIndex: Int) {
        
        print("hide Audio")
    }
    
    func hideVideoPressed(_ isSelected: Bool, onIndex: Int) {
        
        print("hide Video")
    }
    
    func optionsPressed(onIndex: Int) {
        
        index = onIndex
        
        //open popup
        if tableMoreOption == nil {
            let width: CGFloat = 220.0
            let height: CGFloat = 132.0
            tableMoreOption = UITableView(frame: CGRect(x: (300 - width)/2,
                                                        y: (UIScreen.main.bounds.size.height - height)/2,
                                                        width: width,
                                                        height: height),
                                                        style: .plain)
            tableMoreOption.delegate = self
            tableMoreOption.dataSource = self
            tableMoreOption.isHidden = true
            tableMoreOption.layer.borderColor = UIColor.lightGray.cgColor
            tableMoreOption.layer.borderWidth = 1.0
            tableMoreOption.layer.cornerRadius = 5.0
            self.view.addSubview(tableMoreOption)
            
            tableMoreOption.register(UITableViewCell.self, forCellReuseIdentifier: "Cell_More")
        }
        
        if tableMoreOption != nil {
            if tableMoreOption!.isHidden {
                tableMoreOption!.isHidden = false
                isOptionClicked = true
                tableMoreOption.reloadData()
            } else {
                tableMoreOption!.isHidden = true
                isOptionClicked = false
            }
        }
    }
    
    func dropParticipantPressed(onIndex: Int) {
        
        let memberData = self.arrMembers[onIndex]
        
        let userId = memberData["_id"] as? String
        
        dropParticipant(callId: strCallId!, userId: userId!, onIndex: onIndex)
    }
    
    func makeAdminPressed(onIndex: Int, isAdmin: Bool) {
        
        let memberData = self.arrMembers[onIndex]
        
        //let admin = (memberData["isCallAdmin"] as! NSNumber).boolValue
        
//        if (admin && (isAdmin == true)) {
//            //Open UIAlertController
//            let alertController = UIAlertController(title: "Error", message: "User is already admin", preferredStyle: .alert)
//
//            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//
//            // Present action sheet.
//            AppDelegate.sharedInstance()?.topViewController().present(alertController, animated: true)
//        } else {
            let userId = memberData["_id"] as? String
            
            makeAdmin(callId: strCallId!, isCallAdmin: isAdmin, userId: userId!, onIndex: onIndex)
        //}
    }
    
    func makePresenterPressed(onIndex: Int, role: String, isTempPresenter: Bool, isPresenter: Bool) {
        
        let memberData = self.arrMembers[onIndex]
        
        //let presenter = (memberData["isPresenter"] as! NSNumber).boolValue
        
        let userId = memberData["_id"] as? String
        
        //subPresenter, presenter, viewer
        
        makePresenter(callId: strCallId!, isPresenter: isPresenter, userId: userId!, newRole: role, isTempPresenter: isTempPresenter, onIndex: onIndex)
        
//        if (presenter && (isPresenter == true)) {
//            //Open UIAlertController
//            let alertController = UIAlertController(title: "Error", message: "User is already presenter", preferredStyle: .alert)
//
//            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//
//            // Present action sheet.
//            AppDelegate.sharedInstance()?.topViewController().present(alertController, animated: true)
//        } else {
//
//        }
    }
    
    
    // MARK: - API Methods
    
    func muteAudio(callId: String, audioStatus: Bool, userId: String, onIndex: Int) {
        
        let muteBody = MuteUnmuteBody()
         
        muteBody.audioStatus = audioStatus
        muteBody.userId = userId
        
        Yuwee.sharedInstance().getMeetingManager().toggleParticipantAudio(muteBody) { (dictResponse, isSuccess) in
        
            if (isSuccess) {
                
                print("\(dictResponse)")
                
                if (dictResponse.allKeys().contains("result")) {
                    
                    let result = (dictResponse["result"] as? [String : Any])!
                    
                    debugPrint("\(result)")
                    
                    self.dictMember = self.arrMembers[onIndex]
                    
                    if (((self.dictMember["isAudioOn"] as? String)?.boolValue) != nil) {
                        self.dictMember["isAudioOn"] = false
                    } else {
                        self.dictMember["isAudioOn"] = true
                    }
                    
                    self.arrMembers[onIndex] = self.dictMember
                    
                    self.tblSideMenu.reloadData()
                    
                } else {
                    //Open UIAlertController
                    let alertController = UIAlertController(title: "Error", message: "Meeting not yet started", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    // Present action sheet.
                    AppDelegate.sharedInstance()?.topViewController().present(alertController, animated: true)
                }
            } else {
                
                let strMsg = dictResponse[kMessage] as! String
                
                //Open UIAlertController
                let alertController = UIAlertController(title: "Error", message: strMsg, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                // Present action sheet.
                AppDelegate.sharedInstance()?.topViewController().present(alertController, animated: true)
            }
        }
    }
    
    
    func dropParticipant(callId: String, userId: String, onIndex: Int) {
        
        print("\(#function)")
    
        Yuwee.sharedInstance().getMeetingManager().dropParticipant(userId) { (dictResponse, isSuccess) in
        
            if (isSuccess) {
                
                let result = (dictResponse["result"] as? [String : Any])!
                
                debugPrint("\(result)")
                
                if (self.isTraining) {
                    self.delegateRemove?.removePresenter(details: self.arrMembers[onIndex])
                }
                
                self.arrMembers.remove(at: onIndex)
                
                self.tblSideMenu.reloadData()
            }
        }
    }
    
    
    func makeAdmin(callId: String, isCallAdmin: Bool, userId: String, onIndex: Int) {
        
        print("\(#function)")
        
        let callAdmin = CallAdminBody()
        
        callAdmin.isCallAdmin = isCallAdmin
        callAdmin.userId = userId
        
        Yuwee.sharedInstance().getMeetingManager().makeOrRevokeAdmin(callAdmin) { (dictResponse, isSuccess) in
        
            if (isSuccess) {
                let result = (dictResponse["result"] as? [String : Any])!
                
                debugPrint("\(result)")
                
                var memberData = self.arrMembers[onIndex]
                
                if isCallAdmin {
                    memberData["isCallAdmin"] = 0
                } else {
                    memberData["isCallAdmin"] = 1
                }
                
                self.arrMembers[onIndex] = memberData
                
                self.tblSideMenu.reloadData()
            }
        }
    }
    
    
    func makePresenter(callId: String, isPresenter: Bool, userId: String, newRole: String, isTempPresenter: Bool, onIndex: Int) {
        
        var roletype = RoleType.presenter
        
        let callPresenter = CallPresenterBody()
        
        callPresenter.isTempPresenter = isTempPresenter
        callPresenter.userId = userId
        
        if (newRole == "presenter") {
            roletype = RoleType.presenter
        } else if (newRole == "subPresenter") {
            roletype = RoleType.presenter
        } else if (newRole == "viewer") {
            roletype = RoleType.viewer
        }
        
        Yuwee.sharedInstance().getMeetingManager().updatePresenterStatus(callPresenter, roleType: roletype) { (dictResponse, isSuccess) in
        
            if (isSuccess) {
                
                let result = (dictResponse["result"] as? [String : Any])!
                
                debugPrint("\(result)")
                
                if (self.isTraining) {
                    
                    var memberData = self.arrMembers[onIndex]
                    
                    if isPresenter {
                        memberData["isPresenter"] = 1
                        if (newRole == "subPresenter") {
                            memberData["isSubPresenter"] = 1
                            memberData["isPresenter"] = 0
                            if (userId == (UserDefaults.standard.object(forKey: kUser) as? [String : Any])?[k_Id] as? String) {
                                Yuwee.sharedInstance().getMeetingManager().unpublishCameraStream()
                                self.delegateRemove?.updateMainViewData(roleType: RoleType.subPresenter)
                            }
                        } else {
                            if (userId == (UserDefaults.standard.object(forKey: kUser) as? [String : Any])?[k_Id] as? String) {
                                Yuwee.sharedInstance().getMeetingManager().unpublishCameraStream()
                                self.delegateRemove?.updateMainViewData(roleType: RoleType.presenter)
                            }
                        }
                    } else {
                        memberData["isPresenter"] = 0
                        if (newRole == "viewer") {
                            memberData["isSubPresenter"] = 0
                            if (userId == (UserDefaults.standard.object(forKey: kUser) as? [String : Any])?[k_Id] as? String) {
                                Yuwee.sharedInstance().getMeetingManager().unpublishCameraStream()
                                self.delegateRemove?.updateMainViewData(roleType: RoleType.viewer)
                            }
                        }
                    }
                    
                    self.arrMembers[onIndex] = memberData
                    
                    NotificationCenter.default.post(name: NSNotification.Name("updateData"), object: self.arrMembers)
                }
                
                self.tblSideMenu.reloadData()
            }
        }
    }
    
    func filterMemberDataWithOptions(member: [String : Any]) {
        
        optionsArr = []
        
        let isAudioOn = (member["isAudioOn"] as! NSNumber).boolValue
        
        let isCallAdmin = (member["isCallAdmin"] as! NSNumber).boolValue
        
        let isPresenter = (member["isPresenter"] as! NSNumber).boolValue
        
        var isSubPresenter = false
        
        if (member.allKeys().contains("isSubPresenter")) {
            isSubPresenter = (member["isSubPresenter"] as! NSNumber).boolValue
        }
        
        if ((member["email"] as? String) != (UserDefaults.standard.object(forKey: kUser) as? [String : Any])?[kEmail] as? String) {
            
            if isCallAdmin {
                optionsArr.append("Remove Admin")
            } else {
                optionsArr.append("Make Admin")
            }
        }
        
        if (isTraining) {
            if (isPresenter || isSubPresenter) {
                if (isPresenter) {
                    if (member.allKeys().contains("isPresenterTemporary")) {
                        if ((member["isPresenterTemporary"] as! NSNumber).boolValue) {
                            optionsArr.append("Make Presenter Permanent")
                        } else {
                            optionsArr.append("Make Presenter Temporary")
                        }
                    } else {
                        optionsArr.append("Make Presenter Temporary")
                    }
                    optionsArr.append("Make Sub Presenter")
                    optionsArr.append("Remove Presenter Right")
                } else {
                    optionsArr.append("Make Presenter Permanent")
                    optionsArr.append("Make Presenter Temporary")
                    optionsArr.append("Remove Presenter Right")
                }
            } else {
                optionsArr.append("Make Presenter Permanent")
                optionsArr.append("Make Presenter Temporary")
                optionsArr.append("Make Sub Presenter")
                // make presenter, make sub presenter
            }
        }
        if (isAudioOn) {
            optionsArr.append("Mute")
        } else {
            optionsArr.append("Unmute")
        }
        optionsArr.append("Drop")
    }
    
    func optionMenuActions(optionStr: String, indexOptions: Int) {
        
        let memberData = self.arrMembers[indexOptions]
        let userId = memberData["_id"] as? String
        
        if (optionStr == "Drop") {
            dropParticipantPressed(onIndex: indexOptions)
        } else if (optionStr == "Make Admin") {
            makeAdminPressed(onIndex: indexOptions, isAdmin: false)
        } else if (optionStr == "Remove Admin") {
            makeAdminPressed(onIndex: indexOptions, isAdmin: true)
        } else if (optionStr == "Make Presenter Permanent") {
            makePresenterPressed(onIndex: indexOptions, role: "presenter", isTempPresenter: false, isPresenter: true)
        } else if (optionStr == "Make Presenter Temporary") {
            makePresenterPressed(onIndex: indexOptions, role: "presenter", isTempPresenter: true, isPresenter: true)
        } else if (optionStr == "Make Sub Presenter") {
            makePresenterPressed(onIndex: indexOptions, role: "subPresenter", isTempPresenter: false, isPresenter: true)
        } else if (optionStr == "Remove Presenter Right") {
            makePresenterPressed(onIndex: indexOptions, role: "viewer", isTempPresenter: false, isPresenter: false)
        } else if (optionStr == "Mute") {
            muteAudio(callId: strCallId!, audioStatus: false, userId: userId!, onIndex: indexOptions)
        } else if (optionStr == "Unmute") {
            muteAudio(callId: strCallId!, audioStatus: true, userId: userId!, onIndex: indexOptions)
        }
        
        isOptionClicked = false
        tableMoreOption.isHidden = true
    }
    
    
    //MARK:- UITableView Delegate & DataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isOptionClicked {
            return 44
        } else {
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOptionClicked {
            return optionsArr.count
        } else {
            if (self.arrMembers.count>0) {
                return self.arrMembers.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isOptionClicked {
            
            let strIdentifier = "Cell_More"
            
            let cell = tableMoreOption.dequeueReusableCell(withIdentifier: strIdentifier, for: indexPath)
            
            cell.contentView.backgroundColor = UIColor.white
            cell.textLabel!.font = UIFont(name: "AmpleSoft", size: 16)
            cell.textLabel!.textColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            
            let imgBG: UIImageView = UIImageView()
            imgBG.image = UIImage(named: "CellBG")
            
            cell.contentView.addSubview(imgBG)
            
            for view in cell.contentView.subviews {
                if (view.isKind(of: UIView.self)) {
                    view.removeFromSuperview()
                }
            }
            
            let lbltitle: UILabel = UILabel(frame: CGRect(x: 15, y: 5, width: (cell.contentView.frame.size.width - 25), height: 40))
            
            lbltitle.font = UIFont(name: "AmpleSoft", size: 17)
            lbltitle.backgroundColor = UIColor.clear
            lbltitle.numberOfLines = 1
            
            cell.contentView.addSubview(lbltitle)
            
            //let member = arrMembers[index]
            
            lbltitle.text = optionsArr[indexPath.row]
            
            return cell
            
        } else {
            
            let cell: SideMenuCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SideMenuCell
            
            if (arrMembers.count>0) {
                let member = self.arrMembers[indexPath.row]
                
                cell.delegate = self
                cell.index = indexPath.row
                
                let isCallAdmin = (member["isCallAdmin"] as! NSNumber).boolValue
                
                let isPresenter = (member["isPresenter"] as! NSNumber).boolValue
                
                var isSubPresenter = false
                
                if (member.allKeys().contains("isSubPresenter")) {
                    isSubPresenter = (member["isSubPresenter"] as! NSNumber).boolValue
                }
                
                if (isCallAdmin) {
                   let strAdminEmail = member["email"] as? String
                   adminEmailArr.append(strAdminEmail!)
                   cell.imageUser?.image = UIImage(named: "defult_people_icon")
                   if (member.allKeys().contains("image")) {
                    if (member["image"] as? String != "") {
                        cell.imageUser?.image = UIImage(named: "defult_people_icon")
                        ImageLoader.sharedInstance.imageForUrl(urlString: (member["image"] as? String)!, completionHandler: { (image, url) in
                            if image != nil {
                                cell.imageUser?.image = image
                            }
                        })
                    }
                   }
                   cell.audioBtn.isUserInteractionEnabled = false
                   if ((member["isAudioOn"] as? String) != "") {
                       if (((member["isAudioOn"] as? String)?.boolValue) != nil) {
                        let isAudioOn = (member["isAudioOn"] as? String)?.boolValue
                        if isAudioOn! {
                            cell.audioBtn.isSelected = false
                        } else {
                            cell.audioBtn.isSelected = true
                        }
                       } else if ((member["isAudioOn"] as? Int) == 1){
                           cell.audioBtn.isSelected = false
                       } else if ((member["isAudioOn"] as? Int) == 0){
                           cell.audioBtn.isSelected = true
                       }
                    }
                   if ((member["isVideoOn"] as? String) != "") {
                      if (((member["isVideoOn"] as? String)?.boolValue) != nil) {
                        let isVideoOn = (member["isVideoOn"] as? String)?.boolValue
                        if isVideoOn! {
                            cell.videoBtn.isSelected = false
                        } else {
                            cell.videoBtn.isSelected = true
                        }
                      } else if ((member["isVideoOn"] as? Int) == 1){
                        cell.videoBtn.isSelected = false
                      } else if ((member["isVideoOn"] as? Int) == 0){
                        cell.videoBtn.isSelected = true
                      }
                   }
                   cell.title?.text = member["name"] as? String
                   if (cell.adminBtn != nil) {
                       cell.adminBtn.isHidden = false
                   }
                   if (cell.presenterBtn != nil) {
                       cell.presenterBtn.isHidden = true
                   }
                   
               } else {
                   cell.imageUser?.image = UIImage(named: "defult_people_icon")
                   if (member.allKeys().contains("image")) {
                    if (member["image"] as? String != "") {
                        cell.imageUser?.image = UIImage(named: "defult_people_icon")
                        ImageLoader.sharedInstance.imageForUrl(urlString: (member["image"] as? String)!, completionHandler: { (image, url) in
                            if image != nil {
                                cell.imageUser?.image = image
                            }
                        })
                    }
                   }
                   cell.audioBtn.isUserInteractionEnabled = true
                   if ((member["email"] as? String) == (UserDefaults.standard.object(forKey: kUser) as? [String : Any])?[kEmail] as? String) {
                      cell.audioBtn.isUserInteractionEnabled = false
                   }
                   cell.title?.text = member["name"] as? String
                    if ((member["isAudioOn"] as? String) != "") {
                        if (((member["isAudioOn"] as? String)?.boolValue) != nil) {
                         let isAudioOn = (member["isAudioOn"] as? String)?.boolValue
                         if isAudioOn! {
                             cell.audioBtn.isSelected = false
                         } else {
                             cell.audioBtn.isSelected = true
                         }
                        } else if ((member["isAudioOn"] as? Int) == 1){
                            cell.audioBtn.isSelected = false
                        } else if ((member["isAudioOn"] as? Int) == 0){
                            cell.audioBtn.isSelected = true
                        }
                    }
                    
                   if ((member["isVideoOn"] as? String) != "") {
                      if (((member["isVideoOn"] as? String)?.boolValue) != nil) {
                        let isVideoOn = (member["isVideoOn"] as? String)?.boolValue
                        if isVideoOn! {
                            cell.videoBtn.isSelected = false
                        } else {
                            cell.videoBtn.isSelected = true
                        }
                      } else if ((member["isVideoOn"] as? Int) == 1){
                        cell.videoBtn.isSelected = false
                      } else if ((member["isVideoOn"] as? Int) == 0){
                        cell.videoBtn.isSelected = true
                      }
                   }
                   if (cell.adminBtn != nil) {
                       cell.adminBtn.isHidden = true
                   }
                   if (cell.presenterBtn != nil) {
                       cell.presenterBtn.isHidden = true
                   }
                   
               }
                
               // print("\(String(describing: (UserDefaults.standard.object(forKey: kUser) as? [String : Any])))")
                
               let userEmail = (UserDefaults.standard.object(forKey: kUser) as? [String : Any])?[kEmail] as? String
                
               if ((member["email"] as? String) == userEmail) {
                   cell.me.isHidden = false
                   if isAdmin {
                      cell.optionsBtn.isHidden = false
                   } else {
                      cell.optionsBtn.isHidden = true
                   }
               } else {
                   cell.me.isHidden = true
                   cell.optionsBtn.isHidden = true
                   if isAdmin {
                      cell.optionsBtn.isHidden = false
                   }
               }
                 
                if (isPresenter && isTraining) {
                     if (cell.presenterBtn != nil) {
                        cell.presenterBtn.isHidden = false
                        cell.presenterBtn.setTitle("Presenter", for: .normal)
                     }
                }else if (isSubPresenter && isTraining) {
                    if (cell.presenterBtn != nil) {
                       cell.presenterBtn.isHidden = false
                       cell.presenterBtn.setTitle("Sub presenter", for: .normal)
                    }
                }
                
                self.filterMemberDataWithOptions(member: member)
            }
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isOptionClicked {
            
            tableMoreOption.isHidden = true
            tableMoreOption.deselectRow(at: indexPath, animated: true)
            
            self.optionMenuActions(optionStr: optionsArr[indexPath.row], indexOptions: index)
        }
    }
}



/*if (!memberList[layoutPosition].userId.equals(userId, ignoreCase = true)) {
    menu.menu.add(if (memberList[layoutPosition].isAdmin) REMOVE_ADMIN else MAKE_ADMIN)
}
if (callMode == CallMode.TRAINING) {
    if (memberList[layoutPosition].isPresenter || memberList[layoutPosition].isSubPresenter) {
        
        if (memberList[layoutPosition].isPresenter) {
            if (memberList[layoutPosition].isPresenterTemporary) {
                menu.menu.add(MAKE_PRESENTER_PERMANENT)
            } else {
                menu.menu.add(MAKE_PRESENTER_TEMPORARY)
            }
            menu.menu.add(MAKE_SUB_PRESENTER)
            menu.menu.add(REMOVE_PRESENTER_RIGHT)
        } else { // memberList[layoutPosition].isSubPresenter
            menu.menu.add(MAKE_PRESENTER_PERMANENT)
            menu.menu.add(MAKE_PRESENTER_TEMPORARY)
            menu.menu.add(REMOVE_PRESENTER_RIGHT)
        }
    } else {
        menu.menu.add(MAKE_PRESENTER_PERMANENT)
        menu.menu.add(MAKE_PRESENTER_TEMPORARY)
        menu.menu.add(MAKE_SUB_PRESENTER)
        // make presenter, make sub presenter
    }
}
menu.menu.add(if (memberList[layoutPosition].isAudioOn) MUTE else UNMUTE)
menu.menu.add(DROP) */
