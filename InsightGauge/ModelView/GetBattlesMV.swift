//
//  GetBattlesMV.swift
//  InsightGauge
//
//  Created by Mac on 7.09.2023.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class GetBattlesMV {
    
    var battlesArray = [Battles]()
    var privateBattlesArray = [Battles]()
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    func getBattles(completion: @escaping ([Battles]) -> Void) {
        db.collection("Posts").addSnapshotListener { snapShot, error in
            if let error = error {
                print("Error during get data \(error.localizedDescription)")
            } else {
                if snapShot?.isEmpty == false && snapShot != nil {
                    self.battlesArray.removeAll()
                    
                    for document in snapShot!.documents {
                        if let battleId = document.get("ID") as? String,
                           let firstTitle = document.get("FirstTitle") as? String,
                           let firstImageUrl = document.get("FirstImage") as? String,
                           let secondTitle = document.get("SecondTitle") as? String,
                           let secondImageUrl = document.get("SecondImage") as? String,
                           let userEmail = document.get("UserEmail") as? String,
                           let userUID = document.get("UserUID") as? String,
                           let comments = document.get("Comments") as? [String],
                           let votes = document.get("Votes") as? [[String: Int]] {
                            let battle = Battles(id: battleId, firstImage: firstImageUrl, firstTitle: firstTitle, secondImage: secondImageUrl, secondTitle: secondTitle, userEmail: userEmail, userUID: userUID, comment: comments, votes: votes)
                            self.battlesArray.append(battle)
                            completion(self.battlesArray)
                        }
                    }
                }
            }
        }
    }
    
    func getPrivateBattles(privateBattles: [String], completion: @escaping ([Battles]) -> Void) {
        for battle in privateBattles {
            db.collection("Posts").document(battle).addSnapshotListener { snapShot, error in
                if let error = error {
                    print("Error during get data \(error.localizedDescription)")
                } else {
                    if let document = snapShot {
                        if document.exists {
                            if let battleId = document.get("ID") as? String,
                               let firstTitle = document.get("FirstTitle") as? String,
                               let firstImageUrl = document.get("FirstImage") as? String,
                               let secondTitle = document.get("SecondTitle") as? String,
                               let secondImageUrl = document.get("SecondImage") as? String,
                               let userEmail = document.get("UserEmail") as? String,
                               let userUID = document.get("UserUID") as? String,
                               let comments = document.get("Comments") as? [String],
                               let votes = document.get("Votes") as? [[String: Int]] {
                                let battle = Battles(id: battleId, firstImage: firstImageUrl, firstTitle: firstTitle, secondImage: secondImageUrl, secondTitle: secondTitle, userEmail: userEmail, userUID: userUID, comment: comments, votes: votes)
                                if !self.privateBattlesArray.contains(where: { $0.id == battleId }) {
                                                self.privateBattlesArray.append(battle)
                                            }
                                completion(self.privateBattlesArray)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getVotes(choosenBattle: Battles, completion: @escaping ([[String: Int]]) -> Void){
        db.collection("Posts").document(choosenBattle.id).getDocument { snapShot, error in
            if let error = error {
                print("There is an error during get Votes! \(error.localizedDescription)")
            } else {
                if let document = snapShot, let data = document.data() {
                    if let votes = data["Votes"] as? [[String: Int]] {
                        completion(votes)
                    }
                }
            }
        }
    }
    
    func getVotesCount(choosenBattle: Battles, completion: @escaping ([Int]) -> Void){
        var firstVoteValue = 0
        var secondVoteValue = 0
        getVotes(choosenBattle: choosenBattle) { results in
            for result in results {
                let values = result.values
                for key in values {
                    if key == 0 {
                        firstVoteValue += 1
                    } else {
                        secondVoteValue += 1
                    }
                }
                completion([firstVoteValue, secondVoteValue])
            }
        }
    }
    
    func voteFunction(choosenBattle: Battles, completion: @escaping (Int) -> Void) {
        getVotes(choosenBattle: choosenBattle) { results in
            let updatedVotes = results
            for (index, var resultVote) in updatedVotes.enumerated() {
                if let existingUserVote = resultVote[self.user?.email ?? ""] {
                    completion(existingUserVote)
                }
            }
        }
    }
    
    func uploadVotes(choosenBattle: Battles, userVote: Int, completion: @escaping ([Int]) -> Void) {
        getVotes(choosenBattle: choosenBattle) { resultVotes in
            var userVoted = false
            var updatedVotes = resultVotes // Declare it as a variable here
            for (index, var resultVote) in updatedVotes.enumerated() {
                if let existingUserVote = resultVote[self.user?.email ?? ""] {
                    resultVote[self.user?.email ?? ""] = userVote
                    let updatedValues = Array(updatedVotes[index].values)
                    let resultValues = Array(resultVote.values)
                    if updatedValues == resultValues {
                        print("Aynı değeri işaretledi")
                        // Oy silme işlemi gerçekleştirilecek
                        resultVote.removeValue(forKey: self.user?.email ?? "")
                    }
                    updatedVotes[index] = resultVote
                    userVoted = true
                }
            }
            if !userVoted {
                let newVote = [self.user?.email ?? "": userVote]
                updatedVotes.append(newVote)
            } else {
                
            }
            self.db.collection("Posts").document(choosenBattle.id).updateData(["Votes": updatedVotes]) { error in
                if let error = error {
                    print("Oy yükleme işleminde hata oluştu: \(error.localizedDescription)")
                } else {
                    print("Oy başarıyla güncellendi.")
                    self.getVotesCount(choosenBattle: choosenBattle) { results in
                        completion(results)
                    }
                }
            }
        }
    }
    
    func getUserInfo(userEmail: String, userUID: String, completion: @escaping ([String: Any]) -> Void) {
        let userCollection = db.collection("Users")
        let userEmail = userEmail // Kullanıcının e-posta adresi
        
        userCollection.document(userUID).collection(userEmail).document("UserInfo").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                // Hata durumunu işleyebilirsiniz
            } else {
                // Kullanıcının e-posta adresiyle eşleşen belgeleri aldık
                if let document = querySnapshot {
                    if let data = document.data() { // Belgenin içeriğini alır
                        completion(data)
                    }
                }
            }
        }
    }
}
