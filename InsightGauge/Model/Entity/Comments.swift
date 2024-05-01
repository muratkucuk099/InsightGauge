//
//  Comments.swift
//  InsightGauge
//
//  Created by Mac on 11.09.2023.
//

import Foundation

struct Comments {
    
    let userEmail: String
    let userUid: String
    let comment: String
    let battleUid: String
    
    init(userEmail: String, userUid: String, comment: String, battleUid: String) {
        self.userEmail = userEmail
        self.userUid = userUid
        self.comment = comment
        self.battleUid = battleUid
    }
}
