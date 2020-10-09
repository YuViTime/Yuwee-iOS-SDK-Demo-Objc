//
//  ContainerViewController.swift
//  YuWee SDK
//
//  Created by Tanay on 01/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, ConferenceCallViewDelegate {
    
    var menuController: SideMenuTableViewController!
    var homeController: ConferenceCallViewController!
    var centerController: UIViewController!
    var isExpanded = false
    var arrParticipants: [[String : Any]] = []
    var strMeetingName = ""
    var meetingTokenId = ""
    var isCallTypeVideo = false
    var isCallTypeAudio = false
    var isAdmin = false
    var isTraining = false
    var isPresenter = false
    var isSubPresenter = false
    var mediaInfo: [String : Any] = [:]
    var callTokenInfo: [String : Any] = [:]
    var dictRecievedCallStatusData: [String : Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(isExpanded, forKey: "isExpanded")
        configureHomeController()
    }
    
    func configureHomeController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        homeController = storyboard.instantiateViewController(withIdentifier: "ConferenceCallViewController") as? ConferenceCallViewController
        homeController.delegate = self
        homeController.callTokenInfo = self.callTokenInfo
        homeController.dictRecievedCallStatusData = self.dictRecievedCallStatusData
        homeController.strMeetingName = self.strMeetingName
        homeController.meetingTokenId = self.meetingTokenId
        homeController.isCallTypeVideo = self.isCallTypeVideo
        homeController.isCallTypeAudio = self.isCallTypeAudio
        homeController.isPresenter = self.isPresenter
        homeController.isSubPresenter = self.isSubPresenter
        homeController.mediaInfo = self.mediaInfo
        centerController = UINavigationController(rootViewController: homeController)
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }

    func configureMenuController() {
        if (menuController == nil) {
            
            menuController = SideMenuTableViewController(nibName: "SideMenuTableViewController", bundle: nil)
            menuController.delegateRemove = self
            menuController.isOptionClicked = false
            menuController.isTraining = self.isTraining
            menuController.arrMembers = self.arrParticipants
            menuController.dictRecievedCallStatusData = self.dictRecievedCallStatusData
            view.insertSubview(menuController.view, at: 0)
            addChild(menuController)
            
            menuController.didMove(toParent: self)
        } else {
            menuController.reloadTabelWithData(arr: self.arrParticipants)
        }
    }
    
    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        menuController.willMove(toParent: nil)
        menuController.view.removeFromSuperview()
        menuController.removeFromParent()
    }
    
    func removePresenter(details: [String : Any]) {
        homeController.removeStreamFromArrayWhenDropParticipant(dictDetails: details)
    }
    
    func updateMainViewData(roleType: RoleType) {
        if (roleType == RoleType.viewer) {
            homeController.isLocalStreamPublished = false
        } else {
            homeController.publishLocalStreamWithRoleType(roleType: roleType)
        }
    }
    
    func updateMenuController(arr: [[String : Any]]) {
        if (menuController != nil) {
            
            menuController.reloadTabelWithData(arr: arr)
        }
    }
    
    func updateMenuControllerForParticularMember(dict: [String : Any]) {
        if (menuController != nil) {
            
            menuController.reloadTabelWithParticipantOnly(dict: dict)
        }
    }
    
    func showMenuController(shouldExpand: Bool) {
        
        if shouldExpand {
            //show menu
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centerController.view.frame.origin.x = 300
            }, completion: nil)
        } else {
            // hide menu
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centerController.view.frame.origin.x = 0
            }, completion: nil)
        }
    }

}

    
extension ContainerViewController: HomeControllerDelegate {
        
  func handleMenuToggle(arrParticipants: [[String : Any]]) {
      
      self.arrParticipants = arrParticipants
      
      if !isExpanded {
          configureMenuController()
      } else {
          remove()
      }
      
      isExpanded = !isExpanded
      UserDefaults.standard.set(isExpanded, forKey: "isExpanded")
      showMenuController(shouldExpand: isExpanded)
  }
  
  func reloadInputData(arrParticipants: [[String : Any]]) {
      self.arrParticipants = arrParticipants
      
      isExpanded = UserDefaults.standard.bool(forKey: "isExpanded")
      
      if isExpanded {
          updateMenuController(arr: arrParticipants)
      }
  }
  
  func updateParicipantData(dictParticipant: [String : Any]) {
      
      isExpanded = UserDefaults.standard.bool(forKey: "isExpanded")
      
      if isExpanded {
          updateMenuControllerForParticularMember(dict: dictParticipant)
      }
  }
    
  func setUserAdminStatus(isUserAdmin: Bool) {
      isAdmin = isUserAdmin
      
      if (menuController == nil) {
          
          menuController = SideMenuTableViewController(nibName: "SideMenuTableViewController", bundle: nil)
          menuController.delegateRemove = self
          menuController.isOptionClicked = false
          menuController.isTraining = true
          menuController.arrMembers = self.arrParticipants
          menuController.dictRecievedCallStatusData = self.dictRecievedCallStatusData
          view.insertSubview(menuController.view, at: 0)
          addChild(menuController)
          
          menuController.setUserAdmin(isUserAdmin: isAdmin)
      } else {
          menuController.setUserAdmin(isUserAdmin: isAdmin)
      }
  }

}
