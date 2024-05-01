//
//  User.swift
//  InsightGauge
//
//  Created by Mac on 24.08.2023.
//

import Foundation

struct UserAuth {
    
    let name : String
    let userName : String
    let email : String
    let password : String
    let battles: [String]
    
    init(name: String, userName: String, email: String, password: String, battles: [String]) {
        self.name = name
        self.userName = userName
        self.email = email
        self.password = password
        self.battles = battles
    }
}
