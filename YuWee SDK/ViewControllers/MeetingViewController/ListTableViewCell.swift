//
//  ListTableViewCell.swift
//  YuWee SDK
//
//  Created by Arijit Das on 08/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet var lblMeeting: UILabel!
    @IBOutlet var lblDateTime: UILabel!
    @IBOutlet var btnJoin: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
