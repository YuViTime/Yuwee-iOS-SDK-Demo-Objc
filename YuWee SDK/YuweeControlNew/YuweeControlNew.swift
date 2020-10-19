//
//  YuweeControlNew.swift
//  YuWee
//
//  Created by Arijit Das on 27/07/20.
//  Copyright © 2020 DAT-Asset-158. All rights reserved.
//

import UIKit

@objc protocol YuweeControlNewDelegate: NSObjectProtocol {
    @objc optional func hideVideoPressed(_ isSelected: Bool)

    @objc optional func hideAudioPressed(_ isSelected: Bool)

    @objc optional func openChatPressed(_ isSelected: Bool)
    
    @objc optional func screenSharePressed(_ isSelected: Bool)
    
    @objc optional func recordPressed(_ isSelected: Bool)

    @objc optional func switchSpeakerPressed(_ isSelected: Bool)
    
    @objc optional func handRaisePressed(_ isSelected: Bool)

    @objc optional func endCallPressed(_ sender: Any?)
}

class YuweeControlNew: UIView {

    @IBOutlet var viewBg: UIView!
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var btnMuteVideo: UIButton!
    @IBOutlet var btnMuteAudio: UIButton!
    @IBOutlet var screenShareButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var hangupButton: UIButton!
    @IBOutlet var btnSwitchSpeaker: UIButton!
    @IBOutlet var btnHandRaise: UIButton!
    @IBOutlet var btnParticipants: UIButton!
    @IBOutlet var lblChatBadgeCount: UILabel!
    weak var delegate: YuweeControlNewDelegate?

    class func initWithNib() -> Self {

        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.first as! Self
    }

    func initialize() {
        // Drawing code
        viewBg.frame = frame
        viewBg.backgroundColor = UIColor.black
        viewBg.alpha = 0.5
        viewBg.layer.cornerRadius = viewBg.frame.size.height / 2
    }

    @IBAction func btnHideVideoPressed(_ sender: UIButton) {
        btnMuteVideo.isSelected = !btnMuteVideo.isSelected

        if btnMuteVideo.isSelected {
            delegate?.hideVideoPressed!(true)
        } else {
            delegate?.hideVideoPressed!(false)
        }
    }
    
    @IBAction func btnMute_Unmute_AudioPressed(_ sender: UIButton) {
        btnMuteAudio.isSelected = !btnMuteAudio.isSelected

        if btnMuteAudio.isSelected {
            delegate?.hideAudioPressed!(true)
        } else {
            delegate?.hideAudioPressed!(false)
        }
    }

    @IBAction func hangupButtonPressed(_ sender: UIButton) {

        delegate?.endCallPressed!(sender)
    }
    
    @IBAction func screenShareButtonPressed(_ sender: UIButton) {

        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            delegate?.screenSharePressed!(true)
        } else {
            delegate?.screenSharePressed!(false)
        }
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            delegate?.recordPressed!(true)
        } else {
            delegate?.recordPressed!(false)
        }
    }
    
    @IBAction func handRaisePressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            delegate?.handRaisePressed!(true)
        } else {
            delegate?.handRaisePressed!(false)
        }
    }

    @IBAction func btnSwitchSpeakerMode(_ sender: UIButton) {

        btnSwitchSpeaker.isSelected = !btnSwitchSpeaker.isSelected

        if btnSwitchSpeaker.isSelected {
            delegate?.switchSpeakerPressed!(true)
        } else {
            delegate?.switchSpeakerPressed!(false)
        }
    }

    @IBAction func btnMoveToChat(fromCall sender: UIButton) {

        delegate?.openChatPressed!(true)
    }

}
