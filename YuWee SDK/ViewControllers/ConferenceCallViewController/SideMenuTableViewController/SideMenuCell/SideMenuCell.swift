//
//  SideMenuCell.swift
//  YuWee
//
//  Created by Arijit Das on 29/07/20.
//  Copyright © 2020 DAT-Asset-158. All rights reserved.
//

import UIKit
import Foundation

protocol SideMenuCellDelegate {
   
    func hideAudioPressed(_ isSelected: Bool, onIndex: Int)
    func hideVideoPressed(_ isSelected: Bool, onIndex: Int)
    func optionsPressed(onIndex: Int)
}

class SideMenuCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var imageUser: UIImageView!
    @IBOutlet var audioBtn: UIButton!
    @IBOutlet var videoBtn: UIButton!
    @IBOutlet var optionsBtn: UIButton!
    @IBOutlet var me: UIButton!
    @IBOutlet var adminBtn: UIButton!
    @IBOutlet var presenterBtn: UIButton!
    var index = 0
    var delegate: SideMenuCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.me.layer.cornerRadius = 10.0
        self.adminBtn.layer.cornerRadius = 10.0
        self.presenterBtn.layer.cornerRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func adminBtnClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func presenterBtnClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func audioClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            delegate?.hideAudioPressed(true, onIndex: index)
        } else {
            delegate?.hideAudioPressed(false, onIndex: index)
        }
    }
    
    @IBAction func videoClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            delegate?.hideVideoPressed(true, onIndex: index)
        } else {
            delegate?.hideVideoPressed(false, onIndex: index)
        }
    }
    
    @IBAction func optionsBtnClicked(_ sender: UIButton) {
        delegate?.optionsPressed(onIndex: index)
    }
}
