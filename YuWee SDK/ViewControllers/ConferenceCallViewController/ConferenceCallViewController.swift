//
//  ConferenceCallViewController.swift
//  YuWee SDK
//
//  Created by Tanay on 01/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

import UIKit
import Foundation
import WebRTC

protocol ConferenceCallViewDelegate {
    func removePresenter(details: [String : Any])
    func updateMainViewData(roleType: RoleType)
}

@objcMembers

class ConferenceCallViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, YuweeControlNewDelegate, YuWeeRemoteStreamSubscriptionDelegate, OnHostedMeetingDelegate, UITableViewDelegate, UITableViewDataSource {
    
    static let kLocalVideoTag = 1
    static let kRemoteVideoTag = 2
    
    let kUserId_V2 = "userId"
    let kNotificationExtenstionIdentifier = "group.com.yuwee.iosapp.sdkNotification"
    let kUserDetailsFromPreferance = "userDetails"
    
    //Screen sizes
    var SCREENWIDTH: CGFloat = 0.0
    var SCREENHEIGHT: CGFloat = 0.0

    static let kSwipeCamera = "SwipeCamera"
    static let kHideVideo = "HideVideo"
    static let kMuteAudio = "MuteAudio"
    static let kSwitchSpeaker = "SwitchSpeaker"
    
    var isAudioEnabled = true
    var isVideoEnabled = true
    var isHost = false
    var isCallReconnect = false
    var isCallAborted = false
    var isCallDeRegisterCalled = false
    var isCallRegisteredSuccessfully = false
    var isCallProcessedToRegister = false
    var subscribedMix = false
    var isViewOpen = false
    var totalCallDuration = 0
    var totalInvitationSent = 0
    var totalUnansweredCalls = 0
    var currentResizedViewTag = 0
    var counterOfTotalVideoViews = 0
    var widthOfSmallScreens = 0
    var countOfOngoingCallChats = 0
    var muteAudioCount = 0
    var muteVideoCount = 0
    var streamCount = 0
    var isCallGoingToChat = false
    var isScreenStreamProcess = false
    var isRemoteStreamProcess = false
    var getStatsTimer: Timer?
    var callDurationTimer: Timer?
    var callHeartBeatTimer: Timer?
    var alertDoneAction: UIAlertAction?
    var strConferenceId: String?
    var meetingTokenId: String?
    var strCallId: String?
    var viewTopDisplay: UIView?
    var isReconnectingOngoingCall = false
    var isPopupDisplayed = false
    var isJoinCalled = false
    var isToggleViewClicked = false
    var isHarwareAccessEnabled = false
    var isGroup = false
    var lblTitle: UILabel?
    var localView: UIView?
    var lblCallTimer: UILabel?
    var isCallTypeAudio = false
    var isCallTypeVideo = false
    var isCallAcceptingTypeVideo = false
    var isVideoCallEnabled = false
    var isCallAcceptButtonClicked = false
    var isAdmin = false
    var isZoom = false
    var isPresenter = false
    var isSubPresenter = false
    var mediaInfo: [String : Any] = [:]
    var offset = CGPoint.zero
    //let viewInvite: YuviTimeAddMemberPopUpView? = nil
    var callTokenInfo: [String : Any] = [:]
    var dictOfVideoViews: [String : Any]?
    var dictOfVideoViewOriginalFrames: [String : Any]?
    var dictRecievedCallStatusData: [String : Any]?
    var dictCallControllersSettings_MCU: [String : Any]?
    var arrParticipants: [[String : Any]] = []
    var popUpInvite: KLCPopup?
    var strLoginUserId: String?
    var strMeetingName: String?
    var session: AVAudioSession?
    var selectedDevice: AVCaptureDevice?
    var timerCallTimeOut: Timer?
    var isCaller = false
    var isForntCamera = false
    var isLocalStreamPublished = false
    var dictOfVideoTracks: [String : Any]?
    var arrStreams: [OWTRemoteStream] = []
    var navBar: UINavigationBar!
    var btnSwipeCamera: UIButton!
    var roleTypeTraining: RoleType!
    var meetingParam = MeetingParams()
    var streamList: [TrainingStream] = []
    
    var delegate: HomeControllerDelegate?
    
    var tableMoreOption: UITableView!

    @IBOutlet var videoView: YuweeVideoView!
    @IBOutlet var screenView: YuweeVideoView!
    
    @IBOutlet var innerView: UIView!
    
    @IBOutlet var controlView: UIView!
    @IBOutlet var viewOfControls: YuweeControlNew!
    
    @IBOutlet var presentersView: UIView!
    @IBOutlet var presentersCollectionView: UICollectionView!
    
    
    // MARK:- General Methods
    
    func configureTopBar() {
        print("\(#function)")
        viewTopDisplay = UIView(frame: CGRect(x: (UIScreen.main.bounds.size.width - 100)/2, y: 0, width: 100, height: 40))
        viewTopDisplay!.autoresizesSubviews = true
        viewTopDisplay?.backgroundColor = .clear

        lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 15)) //(0, 0, CGRectGetWidth(viewTopDisplay.frame), 20)
        lblTitle!.font = UIFont(name: kAmpleSoftFontName, size: 17)
        lblTitle!.adjustsFontSizeToFitWidth = true
        lblTitle!.textAlignment = .center
        lblTitle!.textColor = .white
        lblTitle?.text = strMeetingName

        lblCallTimer = UILabel(frame: CGRect(x: 0, y: 15, width: 100, height: 15)) //(0, 20, CGRectGetWidth(viewTopDisplay.frame), 20)
        lblCallTimer!.text = "connecting..."
        lblCallTimer!.adjustsFontSizeToFitWidth = true
        lblCallTimer!.font = UIFont(name: kAmpleSoftFontName, size: 14)
        lblCallTimer!.textAlignment = .center
        lblCallTimer!.textColor = .white
        
        viewTopDisplay!.addSubview(lblTitle!)
        viewTopDisplay!.addSubview(lblCallTimer!)
        
        self.navigationItem.titleView = viewTopDisplay
        
        let imgMenu = UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal)
        
        let btnMenu = UIBarButtonItem(image: imgMenu,
                                      style: .plain,
                                      target: self,
                                      action: #selector(btnMenuPressed(_:)))

        self.navigationItem.leftBarButtonItem = btnMenu

        let imgOptions = UIImage(named: "CallOptions")?.withRenderingMode(.alwaysOriginal)

        let btnOptions = UIBarButtonItem(image: imgOptions,
                                      style: .plain,
                                      target: self,
                                      action: #selector(btnOptionPressed(_:)))

        self.navigationItem.rightBarButtonItem = btnOptions
        
        self.navigationController?.navigationBar.barTintColor = .black
        
    }
    
    @IBAction func btnMenuPressed(_ sender: UIBarButtonItem) {
        
        delegate?.handleMenuToggle(arrParticipants: self.arrParticipants)
    }
    
    @IBAction func btnOptionPressed(_ sender: UIBarButtonItem) {
        //open popup
       if tableMoreOption == nil {
            let width: CGFloat = 140.0
            let height: CGFloat = 88.0
            tableMoreOption = UITableView(frame: CGRect(x: (SCREENWIDTH - 10) - width, y: 64, width: width, height: height), style: .plain)
            tableMoreOption.delegate = self
            tableMoreOption.dataSource = self
            tableMoreOption.isHidden = true
            tableMoreOption.layer.borderColor = UIColor.lightGray.cgColor
            tableMoreOption.layer.borderWidth = 1.0
            tableMoreOption.layer.cornerRadius = 5.0
            AppDelegate.sharedInstance().window.addSubview(tableMoreOption)
            
            tableMoreOption.register(UITableViewCell.self, forCellReuseIdentifier: "Cell_More")
        }
        
        if tableMoreOption != nil {
            if tableMoreOption!.isHidden {
                tableMoreOption!.isHidden = false
            } else {
                tableMoreOption!.isHidden = true
            }
        }
    }
    
    func removeStreamFromArrayWhenDropParticipant(dictDetails: [String : Any]) {
        
      if (self.streamList.count>0) {
          for item in self.streamList {
              let stream = item.remoteStream
              let dictAttribute = stream!.attributes()
              debugPrint("\(String(describing: dictAttribute))")
              if ((dictDetails["_id"] as? String) == (dictAttribute[kUserId_V2])){
                  if (stream == self.streamList[0]) {
                     stream!.mediaStream.videoTracks[0].remove(self.videoView.remoteVideoView)
                  }
                  self.streamList.remove(object: item)
              }
          }
          self.presentersCollectionView.reloadData()
      }
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    override public var shouldAutorotate: Bool {
        return true
    }
    
    
    // MARK:- Ongoing Call Methods
    func showToast(_ message: String?) {
        DispatchQueue.main.async(execute: {
            if self.topViewController != nil {
                let hud = MBProgressHUD.showAdded(to: self.topViewController?.view, animated: true)
                hud?.isUserInteractionEnabled = false
                // Configure for text only and offset down
                hud?.mode = MBProgressHUDModeText
                hud?.detailsLabelText = message
                hud?.margin = 10.0
                hud?.yOffset = 70.0
                hud?.removeFromSuperViewOnHide = true
                hud?.hide(true, afterDelay: 7)
            }
        })
    }
    
    func showToast(_ message: String?, withDelay delay: TimeInterval?) {
        DispatchQueue.main.async(execute: {
            if self.topViewController != nil {
                let hud = MBProgressHUD.showAdded(to: self.topViewController?.view, animated: true)
                hud?.isUserInteractionEnabled = false
                // Configure for text only and offset down
                hud?.mode = MBProgressHUDModeText
                hud?.detailsLabelText = message
                hud?.margin = 10.0
                hud?.yOffset = 70.0
                hud?.removeFromSuperViewOnHide = true
                hud?.hide(true, afterDelay: delay!)
            }
        })
    }

    var topViewController: UIViewController? {
        return topViewController(UIApplication.shared.keyWindow?.rootViewController)
    }
    
    func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        if rootViewController?.presentedViewController == nil {
            return rootViewController
        }

        if rootViewController?.presentedViewController is UINavigationController {
            let navigationController = rootViewController?.presentedViewController as? UINavigationController
            let lastViewController = navigationController?.viewControllers.last
            return topViewController(lastViewController)
        }

        let presentedViewController = rootViewController?.presentedViewController
        return topViewController(presentedViewController)
    }
    
    func showMsg(_ msg: String?) {
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)

        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true)
        })
    }
    
    func btnSwipeCameraPressed() {
        
        print("\(#function)")
        
        Yuwee.sharedInstance().getMeetingManager().switchCamera(self.roleTypeTraining) { (dictResponse, isSuccess) in
            
            if (isSuccess) {
                print("\(dictResponse)")
                DispatchQueue.main.async {
                    if (self.meetingParam.meetingType == MeetingType.CONFERENCE) {
                        self.view.bringSubviewToFront(self.videoView)
                    } else {
                        self.view.bringSubviewToFront(self.innerView)
                    }
                }
            } else {
                print("error")
                
                let message = dictResponse["message"] as! String
                
                self.showToast(message)
            }
        }
    }
    
    // MARK:- View Controller Delegates

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //appDelegate = AppDelegate.sharedInstance()
        
        isViewOpen = false
        
        configureTopBar()
        
        SCREENWIDTH = UIScreen.main.bounds.size.width
        SCREENHEIGHT = UIScreen.main.bounds.size.height

        //Check for audio video access for calling and manipulate further setup
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
            if (granted) {
                print("Granted access to \(AVMediaType.audio)")
                if (self.isVideoCallEnabled) {
                    AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
                        if (granted) {
                            print("Granted access to \(AVMediaType.video)")
                            DispatchQueue.main.async(execute: {
                                self.totalUnansweredCalls = 0
                                self.currentResizedViewTag = 0
                                self.counterOfTotalVideoViews = 0
                                self.widthOfSmallScreens = 60

                                self.dictCallControllersSettings_MCU = [String : Any]()
                                if let object = (UserDefaults(suiteName: self.kNotificationExtenstionIdentifier)?.object(forKey: self.kUserDetailsFromPreferance) as? [String : Any])?[kUser] {
                                    print("User Id = \(object)")
                                }
                                self.strLoginUserId = ((UserDefaults(suiteName: self.kNotificationExtenstionIdentifier)?.object(forKey: self.kUserDetailsFromPreferance) as? [String : Any])?[kUser] as? [String : Any])?[k_Id] as? String

                                DispatchQueue.main.async(execute: {
                                    UIApplication.shared.isIdleTimerDisabled = true
                                })

                                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideCallControlCenter))
                                tapGestureRecognizer.numberOfTapsRequired = 2
                                self.view.addGestureRecognizer(tapGestureRecognizer)
                                
                                DispatchQueue.main.async {
                                    self.isForntCamera = true
                                    //self.screenView.isHidden = true
                                    self.view.bringSubviewToFront(self.videoView)
                                    self.setViewOfControlsOrigin(self.videoView)

                                    self.isViewOpen = true
                                    
                                    self.videoView.translatesAutoresizingMaskIntoConstraints = false

                                    let leadingConstraint = NSLayoutConstraint(item: self.videoView, attribute: .leading, relatedBy: .equal,
                                                                               toItem: self.videoView.superview, attribute: .leading, multiplier: 1.0, constant: 0)

                                    let trailingConstraint = NSLayoutConstraint(item: self.videoView, attribute: .trailing, relatedBy: .equal,
                                                                              toItem: self.videoView.superview, attribute: .trailing, multiplier: 1.0, constant: 0)

                                    let topConstraint = NSLayoutConstraint(item: self.videoView, attribute: .top, relatedBy: .equal, toItem: self.videoView.superview, attribute: .top, multiplier: 1, constant: 0)

                                    let bottomConstraint = NSLayoutConstraint(item: self.videoView, attribute: .bottom, relatedBy: .equal, toItem: self.videoView.superview, attribute: .bottom, multiplier: 1, constant: 0)

                                    NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
                                }
                                
//                                if (self.isCallTypeVideo) {
//                                    //Video call
//                                    self.btnSwipeCamera.isEnabled = false;
//                                }else{
//                                    //Audio call
//                                    self.btnSwipeCamera.isEnabled = true;
//                                }
                            })
                        } else {
                            print("Not granted access to \(AVMediaType.video)")

                            let alertController = UIAlertController(title: "Camera Access Denied", message: "Please give us access of your camera to continue video call.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                                //self.callEnd()
                            }))
                            // Present alert.
                            self.present(alertController, animated: true)
                        }
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                                                    self.totalUnansweredCalls = 0
                                                    self.currentResizedViewTag = 0
                                                    self.counterOfTotalVideoViews = 0
                                                    self.widthOfSmallScreens = 60

                                                    self.dictCallControllersSettings_MCU = [String : Any]()
                        if let object = (UserDefaults(suiteName: self.kNotificationExtenstionIdentifier)?.object(forKey: self.kUserDetailsFromPreferance) as? [String : Any])?[kUser] {
                                                        print("User Id = \(object)")
                                                    }
                        self.strLoginUserId = ((UserDefaults(suiteName: self.kNotificationExtenstionIdentifier)?.object(forKey: self.kUserDetailsFromPreferance) as? [String : Any])?[kUser] as? [String : Any])?[k_Id] as? String

                                                    DispatchQueue.main.async(execute: {
                                                        UIApplication.shared.isIdleTimerDisabled = true
                                                    })

                                                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideCallControlCenter))
                                                    tapGestureRecognizer.numberOfTapsRequired = 2
                                                    self.view.addGestureRecognizer(tapGestureRecognizer)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.isForntCamera = true
                                                        //self.screenView.isHidden = true
                                                        self.view.bringSubviewToFront(self.videoView)
                                                        self.setViewOfControlsOrigin(self.videoView)

                                                        self.isViewOpen = true
                                                        
                                                        self.videoView.translatesAutoresizingMaskIntoConstraints = false

                                                        let leadingConstraint = NSLayoutConstraint(item: self.videoView, attribute: .leading, relatedBy: .equal,
                                                                                                   toItem: self.videoView.superview, attribute: .leading, multiplier: 1.0, constant: 0)

                                                        let trailingConstraint = NSLayoutConstraint(item: self.videoView, attribute: .trailing, relatedBy: .equal,
                                                                                                  toItem: self.videoView.superview, attribute: .trailing, multiplier: 1.0, constant: 0)

                                                        let topConstraint = NSLayoutConstraint(item: self.videoView, attribute: .top, relatedBy: .equal, toItem: self.videoView.superview, attribute: .top, multiplier: 1, constant: 0)

                                                        let bottomConstraint = NSLayoutConstraint(item: self.videoView, attribute: .bottom, relatedBy: .equal, toItem: self.videoView.superview, attribute: .bottom, multiplier: 1, constant: 0)

                                                        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
                                                    }
                                                    
//                                                    if (self.isCallTypeVideo) {
//                                                        //Video call
//                                                        self.btnSwipeCamera.isEnabled = false;
//                                                    }else{
//                                                        //Audio call
//                                                        self.btnSwipeCamera.isEnabled = true;
//                                                    }
                                                })
                }
            } else {
                print("Not granted access to \(AVMediaType.audio)")
                let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please give us access of your microphone to continue call.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    //self.callEnd()
                }))
                
                // Present alert.
                self.present(alertController, animated: true)
            }
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(updateStreamsNotification(_:)),
        name: NSNotification.Name(rawValue: "updateStreams"),
        object: nil)
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(updateDataNotification(_:)),
        name: NSNotification.Name(rawValue: "updateData"),
        object: nil)
        
        let strLoginid: String = (UserDefaults.standard.object(forKey: kUser) as? [String : Any])![kEmail] as! String
        
        let arrAdmins: [String] = (dictRecievedCallStatusData!["callAdmins"] as? [String])!
        if (arrAdmins.contains(strLoginid)) {
            isAdmin = true
        }
        
        presentersCollectionView.delegate = self
        presentersCollectionView.dataSource = self
        presentersCollectionView.register(UINib(nibName: "PresenterCollectionCell", bundle: nil), forCellWithReuseIdentifier: "remoteCell")
        countOfOngoingCallChats = 0
        
        moveAppOrientationMode(withMode: UIDeviceOrientation.landscapeLeft.rawValue)

        meetingParam.roomId = dictRecievedCallStatusData!["roomId"] as! String
        meetingParam.callId = dictRecievedCallStatusData!["callId"] as! String
        meetingParam.icsCallResourceId = callTokenInfo["ICSCallResourceId"] as! String
        meetingParam.meetingTokenId = meetingTokenId!
        meetingParam.token = callTokenInfo["token"] as! String
        
        if ((dictRecievedCallStatusData!["callMode"] as! Int) == 0) {
            meetingParam.meetingType = MeetingType.CONFERENCE
            self.presentersView.isHidden = true
        } else {
            meetingParam.meetingType = MeetingType.TRAINING
            self.presentersView.isHidden = false
        }
        
        Yuwee.sharedInstance().getMeetingManager().joinMeeting(meetingParam) { (dictResponse, isSuccess) in
            
            if (isSuccess) {
                print("\(dictResponse)")
                self.arrStreams = Yuwee.sharedInstance().getMeetingManager().getAllRemoteStream() as! [OWTRemoteStream]
                if (self.meetingParam.meetingType == MeetingType.CONFERENCE) {
                    for item in self.arrStreams {
                        if (item.source.video == OWTVideoSourceInfo.mixed) {
                            Yuwee.sharedInstance().getMeetingManager().subscribeRemoteStream(item, withlistener: self)
                        }
                    }
                } else {
                    Yuwee.sharedInstance().getMeetingManager().setMeetingDelegate(self)
                    for element in self.arrStreams {
                        let streamNew = TrainingStream()
                        
                        streamNew.remoteStream = element
                        
                        self.streamList.append(streamNew)
                        
                        Yuwee.sharedInstance().getMeetingManager().subscribeRemoteStream(element, withlistener: self)
                    }
                    self.presentersCollectionView.reloadData()
                }
                if (self.isPresenter || self.isSubPresenter) {
                    if self.isPresenter {
                        self.roleTypeTraining = RoleType.presenter
                    } else {
                        self.roleTypeTraining = RoleType.subPresenter
                    }
                    self.publishLocalStreamWithRoleType(roleType: self.roleTypeTraining)
                }
                Yuwee.sharedInstance().getMeetingManager().fetchActiveParticipantsList { (dictResponse, isSuccess) in
                    
                    if (isSuccess) {
                        print("\(dictResponse)")
                        if ((dictResponse[kStatus] as? String) == kStatusIdentifier_Success) {
                            self.arrParticipants = dictResponse[kResult] as! [[String : Any]]
                            var arr = self.arrParticipants
                            for item in arr {
                                if (item.allKeys().contains("isBlocked")) {
                                    if ((item["isBlocked"] as! Int) == 1) {
                                        if let i = arr.firstIndex(where: {($0["_id"] as! String) == (item["_id"] as! String)}) {
                                            arr.remove(at: i)
                                        }
                                    }
                                }
                            }
                            self.arrParticipants = arr
                            self.delegate?.setUserAdminStatus(isUserAdmin: self.isAdmin)
                        } else {
                            print("error")
                            
                            let message = dictResponse["message"] as! String
                            
                            self.showToast(message, withDelay: 2.0)
                        }
                    }
                }
            } else {
                print("error")
                
                let message = dictResponse["message"] as! String
                
                AppDelegate.sharedInstance()?.showToast(message)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("\(#function)")
        super.viewDidAppear(animated)

        moveAppOrientationMode(withMode: UIDeviceOrientation.landscapeLeft.rawValue)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        moveAppOrientationMode(withMode: UIDeviceOrientation.portrait.rawValue)
    }
    
    func moveAppOrientationMode(withMode orientationMode: Int) {
        let value = orientationMode
        UIDevice.current.setValue(value, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    @objc func hideCallControlCenter() {
        print("\(#function)")
        self.viewOfControls!.isHidden = !(self.viewOfControls!.isHidden)
    }
    
    @objc func updateStreamsNotification(_ event: Notification?) {
        
        let object = event?.object as? [[String : Any]]
        
        let element = object![0]
        
        if (self.meetingParam.meetingType == MeetingType.CONFERENCE) {
            
            if let i = self.arrStreams.firstIndex(where: {$0.attributes()["userId"]! == element["_id"] as! String}) {
                let stream: OWTRemoteStream = self.arrStreams[i]
                let index = self.streamList.index(where: {$0.remoteStream == stream})!
                self.streamList.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                self.presentersCollectionView.deleteItems(at: [indexPath])
            }
        }
    }
    
    @objc func updateDataNotification(_ event: Notification?) {
        
        let object = event?.object as? [[String : Any]]
        
        //let element = object![0]
        
        print("\(#function) \(String(describing: object))")
        
        self.arrParticipants = object!
    }
    
    func setViewOfControlsOrigin(_ videoView: YuweeVideoView!) {

        self.controlView.viewWithTag(115)?.removeFromSuperview()
        
        self.viewOfControls = YuweeControlNew.fromNib()
        
        self.viewOfControls!.frame = CGRect(x: 0, y: 0, width: 560, height: 50)
        self.viewOfControls!.delegate = self
        self.viewOfControls!.tag = 115
        self.viewOfControls!.initialize()

        self.controlView.addSubview(self.viewOfControls!)
        
        self.viewOfControls!.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self.viewOfControls!, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 560)

        let heightConstraint = NSLayoutConstraint(item: self.viewOfControls!, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)

        let xConstraint = NSLayoutConstraint(item: self.viewOfControls!, attribute: .centerX, relatedBy: .equal, toItem: self.viewOfControls!.superview, attribute: .centerX, multiplier: 1, constant: 0)

        let bottomConstraint = NSLayoutConstraint(item: self.viewOfControls!, attribute: .bottom, relatedBy: .equal, toItem: self.viewOfControls!.superview, attribute: .bottom, multiplier: 1, constant: 0)

        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, bottomConstraint])
    }
    
    
    func publishLocalStreamWithRoleType(roleType: RoleType) {
        Yuwee.sharedInstance().getMeetingManager().publishCameraStream(roleType) { (dictResponse, isSuccess) in
            
            if (isSuccess) {
                self.isLocalStreamPublished = true
                print("\(dictResponse)")
                DispatchQueue.main.async {
                    if (self.meetingParam.meetingType == MeetingType.CONFERENCE) {
                        self.view.bringSubviewToFront(self.videoView)
                    } else {
                        self.view.bringSubviewToFront(self.innerView)
                    }
                }
            } else {
                print("error")
                
                let message = dictResponse["message"] as! String
                
                AppDelegate.sharedInstance()?.showToast(message)
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view == self.presentersView) {
            return false
        }
        return true
    }
    
    // MARK: - YuWeeRemoteStreamSubscriptionDelegate
    
    func onSubscribeRemoteStreamResult(_ subsription: OWTConferenceSubscription!, with remoteStream: OWTRemoteStream!, withMessage message: String!, withStatus success: Bool) {
        print("success")
        if (self.meetingParam.meetingType == MeetingType.CONFERENCE) {
            if (remoteStream.source.video == OWTVideoSourceInfo.mixed) {
                Yuwee.sharedInstance().getMeetingManager().attach(remoteStream, with: self.videoView) { (dictResponse, isSuccess) in
                    if (isSuccess) {
                       DispatchQueue.main.async {
                           self.view.bringSubviewToFront(self.videoView)
                       }
                    }
                }
            }
        } else {
            if (success) {
                for (index,element) in self.streamList.enumerated() {
                    if (element.remoteStream.streamId == remoteStream.streamId) {
                        element.subscription = subsription
                        let indexPath = IndexPath(item: index, section: 0)
                        self.presentersCollectionView.reloadItems(at: [indexPath])
                        break
                    }
                }
            }
        }
    }
    
    
    // MARK: - OnHostedMeetingDelegate
    
    func onStreamAdded(_ remoteStream: OWTRemoteStream) {
        
        if (self.meetingParam.meetingType == MeetingType.TRAINING) {
            let streamNew = TrainingStream()
            
            streamNew.remoteStream = remoteStream
            
            self.streamList.append(streamNew)
            let indexPath = IndexPath(row: (self.streamList.count - 1), section: 0)
            self.presentersCollectionView.insertItems(at: [indexPath])
            
            Yuwee.sharedInstance().getMeetingManager().subscribeRemoteStream(remoteStream, withlistener: self)
        }
    }
    
    func onStreamRemoved(_ remoteStream: OWTRemoteStream) {
        
        if (self.meetingParam.meetingType == MeetingType.TRAINING) {
            
            let index = self.streamList.index(where: {$0.remoteStream == remoteStream})!
            self.streamList.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.presentersCollectionView.deleteItems(at: [indexPath])
        }
    }
    
    func onCallPresentersUpdated(_ dict: [AnyHashable : Any]!) {
        
        if let i = self.arrParticipants.firstIndex(where: {$0["_id"] as! String == dict["userId"] as! String}) {
            var obj = self.arrParticipants[i]
            debugPrint("\(obj)")
            
            if (dict.allKeys().contains("newRole")) {
                
                let strRole = dict["newRole"] as! String
                
                if (strRole == "presenter") {
                    self.roleTypeTraining = RoleType.presenter
                    obj["isPresenter"] = 1
                    obj["isSubPresenter"] = 0
                    if (isLocalStreamPublished) {
                        Yuwee.sharedInstance().getMeetingManager().unpublishCameraStream()
                    }
                    publishLocalStreamWithRoleType(roleType: self.roleTypeTraining)
                } else if (strRole == "subPresenter") {
                    self.roleTypeTraining = RoleType.subPresenter
                    obj["isPresenter"] = 0
                    obj["isSubPresenter"] = 1
                    if (isLocalStreamPublished) {
                        Yuwee.sharedInstance().getMeetingManager().unpublishCameraStream()
                    }
                    publishLocalStreamWithRoleType(roleType: self.roleTypeTraining)
                } else if (strRole == "viewer") {
                    obj["isPresenter"] = 0
                    obj["isSubPresenter"] = 0
                    self.roleTypeTraining = RoleType.viewer
                    if (isLocalStreamPublished) {
                        Yuwee.sharedInstance().getMeetingManager().unpublishCameraStream()
                        isLocalStreamPublished = false
                    }
                }
               delegate?.updateParicipantData(dictParticipant: obj)
            }
        }
    }
    
    func onCallAdminsUpdated(_ dict: [AnyHashable : Any]!) {
        
        if let i = self.arrParticipants.firstIndex(where: {$0["_id"] as! String == dict["userId"] as! String}) {
            var obj = self.arrParticipants[i]
            debugPrint("\(obj)")
            
            let val = dict["isCallAdmin"] as! Int
            obj["isCallAdmin"] = val
            
            delegate?.updateParicipantData(dictParticipant: obj)
        }
    }
    
    func onCallParticipantMuted(_ dict: [AnyHashable : Any]!) {
        
        print("\(String(describing: dict))")
    }
    
    func onCallParticipantDropped(_ dict: [AnyHashable : Any]!) {
        
        print("\(String(describing: dict))")
        
        Yuwee.sharedInstance().getMeetingManager().leaveMeeting { (dictResponse, isSuccess) in
            if (isSuccess) {
                print("\(dictResponse)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.moveAppOrientationMode(withMode: UIDeviceOrientation.portrait.rawValue)
                }
            }
        }
    }
    
    func onCallParticipantJoined(_ dict: [AnyHashable : Any]!) {
        
        var info = dict["info"] as? [String : Any]
        
        if (dict.allKeys().contains("isPresenter")) {
            let val = dict["isPresenter"] as! Int
            info!["isPresenter"] = val
        } else if (dict.allKeys().contains("isSubPresenter")) {
            let val2 = dict["isSubPresenter"] as! Int
            info!["isSubPresenter"] = val2
        }
        
        self.arrParticipants.append(info!)
        
        delegate?.reloadInputData(arrParticipants: self.arrParticipants)
    }
    
    func onCallParticipantLeft(_ dict: [AnyHashable : Any]!) {
        
        if (dict.allKeys().contains("info")) {
            let info = dict["info"] as? [String : Any]
            
            if (self.arrParticipants.count>0) {
              let index = self.arrParticipants.index(where: {$0["name"] as! String == info!["name"] as! String})
              
              self.arrParticipants.remove(at: index!)
              
              self.presentersCollectionView.reloadData()
              
              delegate?.reloadInputData(arrParticipants: self.arrParticipants)
            }
        } else {
            if (self.arrParticipants.count>0) {
                let index = self.arrParticipants.index(where: {$0["_id"] as! String == dict["userId"] as! String})
                
                self.arrParticipants.remove(at: index!)
                
                self.presentersCollectionView.reloadData()
                
                delegate?.reloadInputData(arrParticipants: self.arrParticipants)
            }
        }
    }
    
    func onCallParticipantStatusUpdated(_ dict: [AnyHashable : Any]!) {
        
        let info = dict["info"] as? [String : Any]
        
        if let i = self.arrParticipants.firstIndex(where: {$0["_id"] as! String == dict["userId"] as! String}) {
            
            var obj = self.arrParticipants[i]
            
            debugPrint("\(obj)")
            
            if let val = info!["isAudioOn"] {
                obj["isAudioOn"] = (val as! String).boolValue ? 1 : 0
            }
            if let val2 = info!["isVideoOn"] {
                obj["isVideoOn"] = (val2 as! String).boolValue ? 1 : 0
            }
            
            delegate?.updateParicipantData(dictParticipant: obj)
        }
    }
    
    func onCallHandRaised(_ dict: [AnyHashable : Any]!) {
        
        print("\(#function) \(String(describing: dict))")
        
        var handraiseName: String = ""
        
        for item in arrParticipants {
            if ((item["_id"] as! String) == (dict[kSenderId] as! String)) {
                handraiseName = item[kName] as! String
            }
        }
        
        for item in arrParticipants {
            let isCallAdmin = (item["isCallAdmin"] as! NSNumber).boolValue
            if (((item[kEmail] as! String) == UserDefaults.standard.object(forKey: k_Id) as! String) && isCallAdmin) {
                let alertController = UIAlertController(title: "Hand raised", message: "Hand raised by \(handraiseName)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "DOWN", style: .default, handler: { action in
                    
                    let objHandRaise = HandRaiseBody()
                    
                    objHandRaise.raiseHand = false
                    objHandRaise.userId = dict["userId"] as! String
                    
                    Yuwee.sharedInstance().getMeetingManager().toggleHandRaise(objHandRaise) { (dictResponse, isSuccess) in
                       if (isSuccess) {
                          print("hand raise down")
                          
                          
                       }
                    }
                }))
                alertController.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { action in
                    alertController.dismiss(animated: true, completion: nil)
                }))
                // Present alert.
                AppDelegate.sharedInstance()?.topViewController().present(alertController, animated: true)
            }
        }
    }
    
    func onMeetingEnded(_ dict: [AnyHashable : Any]!) {
        
        Yuwee.sharedInstance().getMeetingManager().leaveMeeting { (dictResponse, isSuccess) in
            if (isSuccess) {
                print("\(dictResponse)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.moveAppOrientationMode(withMode: UIDeviceOrientation.portrait.rawValue)
                }
            }
        }
    }
    
    func onCallActiveSpeaker(_ dict: [AnyHashable : Any]!) {
        
        print("\(String(describing: dict))")
    }
    
    func onError(_ error: String!) {
        
        print("\(String(describing: error))")
    }
    
    
    // MARK:- Call Controls Action Events
    
    func openChatPressed(_ isSelected: Bool) {
        print("\(#function)")
        
        self.showToast("Chat option is not available in SDK Demo.", withDelay: 2.0)
    }
    
    func hideAudioPressed(_ isSelected: Bool) {
        
        isAudioEnabled = !isSelected
        
        Yuwee.sharedInstance().getMeetingManager().setMediaEnabled(isAudioEnabled, withVideoEnabled: isVideoEnabled) { (dictResponse, isSuccess) in
            if (isSuccess) {
                print("hideAudioPressed: %d", self.isAudioEnabled)
            }
        }
    }
    
    func hideVideoPressed(_ isSelected: Bool) {
        
        isVideoEnabled = !isSelected
        
        Yuwee.sharedInstance().getMeetingManager().setMediaEnabled(isAudioEnabled, withVideoEnabled: isVideoEnabled) { (dictResponse, isSuccess) in
            if (isSuccess) {
                print("hideVideoPressed: %d", self.isVideoEnabled)
            }
        }
    }
    
    func switchSpeakerPressed(_ isSelected: Bool) {
        Yuwee.sharedInstance().getMeetingManager().setSpeakerEnabled(isSelected)
    }
    
    func recordPressed(_ isSelected: Bool) {
        print("\(#function)")
        
        self.showToast("Recording option is not available in iOS.", withDelay: 2.0)
    }

    func screenSharePressed(_ isSelected: Bool) {
        print("\(#function)")
        
        self.showToast("Screen sharing option is not available in iOS.", withDelay: 2.0)
    }
    
    func handRaisePressed(_ isSelected: Bool) {
        print("\(#function)")
        
        let objHandRaise = HandRaiseBody()
        
        objHandRaise.raiseHand = isSelected
        objHandRaise.userId = UserDefaults.standard.object(forKey: k_Id) as! String
        
        Yuwee.sharedInstance().getMeetingManager().toggleHandRaise(objHandRaise) { (dictResponse, isSuccess) in
           if (isSuccess) {
              print("handraised: %d", isSelected)
           }
        }
    }
    
    func endCallPressed(_ sender: Any?) {
        print("\(#function)")
        
        //Clean up
        let btnHangup = sender as? UIButton
        btnHangup?.isEnabled = false
        
        Yuwee.sharedInstance().getMeetingManager().leaveMeeting { (dictResponse, isSuccess) in
            if (isSuccess) {
                print("\(dictResponse)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.moveAppOrientationMode(withMode: UIDeviceOrientation.portrait.rawValue)
                }
            }
        }
    }
    
    func endAction() {
        Yuwee.sharedInstance().getMeetingManager().endMeeting({ (dictResponse, isSuccess) in
            if (isSuccess) {
                print("\(dictResponse)")
                Yuwee.sharedInstance().getMeetingManager().leaveMeeting { (dictResponse, isSuccess) in
                    if (isSuccess) {
                        print("\(dictResponse)")
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                            self.moveAppOrientationMode(withMode: UIDeviceOrientation.portrait.rawValue)
                        }
                    }
                }
            }
        })
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.streamList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell1: PresenterCollectionCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "remoteCell", for: indexPath) as? PresenterCollectionCell)!
        
        let obj = self.streamList[indexPath.item]
        
        let stream = obj.remoteStream
        
        if (obj.subscription != nil) {
            
            Yuwee.sharedInstance().getMeetingManager().attach(stream!, with: cell1.videoView) { (dictResponse, isSuccess) in
              if (isSuccess) {
                 DispatchQueue.main.async {
                    
                     self.view.bringSubviewToFront(self.innerView)
                 }
              }
            }
        }
        
        let objBig = self.streamList[0]
        
        let streamBig = objBig.remoteStream
        
        if (objBig.subscription != nil) {
            
            Yuwee.sharedInstance().getMeetingManager().attach(streamBig!, with: self.videoView) { (dictResponse, isSuccess) in
              if (isSuccess) {
                 DispatchQueue.main.async {
                    
                     self.view.bringSubviewToFront(self.innerView)
                 }
              }
            }
        }
        
        return cell1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let objBig = self.streamList[indexPath.row]
        
        let streamBig = objBig.remoteStream
        
        if (objBig.subscription != nil) {
            
            Yuwee.sharedInstance().getMeetingManager().attach(streamBig!, with: self.videoView) { (dictResponse, isSuccess) in
              if (isSuccess) {
                 DispatchQueue.main.async {
                    
                     self.view.bringSubviewToFront(self.innerView)
                 }
              }
           }
        }
    }
    
    
    //MARK:- UITableView Delegate & DataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isAdmin {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let strIdentifier = "Cell_More"
        
        let cell = tableMoreOption.dequeueReusableCell(withIdentifier: strIdentifier, for: indexPath)
        
        cell.contentView.backgroundColor = UIColor.white
        cell.textLabel!.font = UIFont(name: "AmpleSoft", size: 16)
        cell.textLabel!.textColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        
        let imgBG: UIImageView = UIImageView()
        imgBG.image = UIImage(named: "CellBG")
        
        cell.contentView.addSubview(imgBG)
        
        let lbltitle: UILabel = UILabel(frame: CGRect(x: 15, y: 5, width: (cell.contentView.frame.size.width - 25), height: 40))
        
        lbltitle.font = UIFont(name: "AmpleSoft", size: 17)
        lbltitle.backgroundColor = UIColor.clear
        lbltitle.numberOfLines = 1
        
        cell.contentView.addSubview(lbltitle)
        
        if isAdmin {
            switch (indexPath.row) {
            case 0:
                lbltitle.text = "End";
                break;
            case 1:
                lbltitle.text = "Switch Camera";
                break;
            default:
                break;
            }
        } else {
            lbltitle.text = "Switch Camera";
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableMoreOption.isHidden = true
        tableMoreOption.deselectRow(at: indexPath, animated: true)
        if isAdmin {
            switch indexPath.row {
                case 0:
                    self.endAction()
                    tableMoreOption.isHidden = true
                case 1:
                    self.btnSwipeCameraPressed()
                    tableMoreOption.isHidden = true
                default:
                    break
            }
        } else {
            self.btnSwipeCameraPressed()
            tableMoreOption.isHidden = true
        }
    }
}

extension YuweeControlNew {
    class func fromNib(named: String? = nil) -> Self {
        let name = named ?? "\(Self.self)"
        guard
            let nib = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
            else { fatalError("missing expected nib named: \(name)") }
        guard
            /// we're using `first` here because compact map chokes compiler on
            /// optimized release, so you can't use two views in one nib if you wanted to
            /// and are now looking at this
            let view = nib.first as? Self
            else { fatalError("view of type \(Self.self) not found in \(nib)") }
        return view
    }
}

extension Array where Element: Equatable {

    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

class TrainingStream: NSObject {
    
    var remoteStream: OWTRemoteStream!
    var subscription: OWTConferenceSubscription!
}

extension ConferenceCallViewController {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            removeCells()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        removeCells()
        
        for cell in presentersCollectionView.visibleCells {
            let indexPath = presentersCollectionView.indexPath(for: cell)
            print(indexPath!)
            
            let dict = self.streamList[indexPath!.row]
            
            //let stream = dict["remoteStream"] as! OWTRemoteStream
            
            let subscription = dict.subscription
            
            subscription!.unmute(.video, onSuccess: {
                print("success")
            }) { (error) in
                print(error)
            }
        }
    }
    
    func removeCells() {

        // 1. Find the visible cells
        let visibleCells = presentersCollectionView.visibleCells
        //NSLog("We have %i visible cells", visibleCells.count)


        // 2. Find the visible rect of the collection view on screen now
        let visibleRect = presentersCollectionView.bounds.offsetBy(dx: presentersCollectionView.contentOffset.x, dy: presentersCollectionView.contentOffset.y)
        //NSLog("Rect %@", NSStringFromCGRect(visibleRect))


        // 3. Find the subviews that shouldn't be there and remove them
        //NSLog("We have %i subviews", subviews.count)
        for aView in presentersCollectionView.subviews {
            if let aCollectionViewCell = aView as? PresenterCollectionCell {

                let origin = aView.frame.origin
                if (visibleRect.contains(origin)) {
                    if (!visibleCells.contains(aCollectionViewCell)) {
                        aView.removeFromSuperview()
                        
                        let indexPath = presentersCollectionView.indexPath(for: aCollectionViewCell)
                        
                        let dict = self.streamList[indexPath!.row]
                        
                        //let stream = dict["remoteStream"] as! OWTRemoteStream
                        
                        let subscription = dict.subscription
                        
                        subscription!.mute(.video, onSuccess: {
                            print("success")
                        }) { (error) in
                            print(error)
                        }
                    }
                }

            }
        }

        // 4. Refresh the collection view display
        presentersCollectionView.setNeedsDisplay()
    }
}
