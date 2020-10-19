//
//  Protocols.swift
//  YuWee
//
//  Created by Arijit Das on 28/07/20.
//  Copyright © 2020 DAT-Asset-158. All rights reserved.
//

import Foundation

protocol HomeControllerDelegate {
    func handleMenuToggle(arrParticipants: [[String : Any]])
    func reloadInputData(arrParticipants: [[String : Any]])
    func updateParicipantData(dictParticipant: [String : Any])
    func setUserAdminStatus(isUserAdmin: Bool)
}

extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
