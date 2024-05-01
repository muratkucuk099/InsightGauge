//
//  Battles.swift
//  InsightGauge
//
//  Created by Mac on 31.08.2023.
//

import Foundation

struct Battles {
    let id: String
    let firstImage: String
    let firstTitle: String
    let secondImage: String
    let secondTitle: String
    let userEmail: String
    let userUID: String
    let comment: [String]
    let votes: [[String: Int]]
    
    init(id: String, firstImage: String, firstTitle: String, secondImage: String, secondTitle: String, userEmail: String, userUID: String, comment: [String], votes: [[String: Int]]) {
        self.id = id
        self.firstImage = firstImage
        self.firstTitle = firstTitle
        self.secondImage = secondImage
        self.secondTitle = secondTitle
        self.userEmail = userEmail
        self.userUID = userUID
        self.comment = comment
        self.votes = votes
    }
}
