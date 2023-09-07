//
//  GetBattlesMV.swift
//  InsightGauge
//
//  Created by Mac on 7.09.2023.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

class GetBattlesMV {
    
    var battlesArray = [Battles]()
    
    func getBattles(completion: @escaping ([Battles]) -> Void) {
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Posts").addSnapshotListener { snapShot, error in
            if let error = error {
                //Hata mesajı
                print("Error during get data \(error.localizedDescription)")
            } else {
                if snapShot?.isEmpty == false && snapShot != nil {
                    self.battlesArray.removeAll()
                    
                    for document in snapShot!.documents {
                        if let firstTitle = document.get("FirstTitle") as? String,
                           let firstImageUrl = document.get("FirstImage") as? String,
                           let secondTitle = document.get("SecondTitle") as? String,
                           let secondImageUrl = document.get("SecondImage") as? String,
                           let firstVotes = document.get("FirstVotes") as? [String],
                           let secondVotes = document.get("SecondVotes") as? [String],
                           let comments = document.get("Comments") as? [String],
                           let userEmail = document.get("UserEmail") as? String,
                           let userUID = document.get("UserUID") as? String {
                            
                            let battle = Battles(firstImage: firstImageUrl, firstTitle: firstTitle, secondImage: secondImageUrl, secondTitle: secondTitle, userEmail: userEmail, userUID: userUID, comments: comments, firstVotesUsers: firstVotes, secondVotesUsers: secondVotes)
                            self.battlesArray.append(battle)
                            completion(self.battlesArray)
                        }
                    }
                }
            }
        }
    }
    
    func getUserInfo(userEmail: String, userUID: String) {
        let db = Firestore.firestore()
        let userCollection = db.collection("Users")
        let userEmail = userEmail // Kullanıcının e-posta adresi
        
        userCollection.document(userUID).collection(userEmail).document("UserInfo").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                // Hata durumunu işleyebilirsiniz
            } else {
                // Kullanıcının e-posta adresiyle eşleşen belgeleri aldık
                if let document = querySnapshot {
                    let data = document.data() // Belgenin içeriğini alır
                    print(data)
                    // Diğer alanlara da benzer şekilde erişebilirsiniz
                }
            }
        }
        
    }
}
