//
//  CommentMV.swift
//  InsightGauge
//
//  Created by Mac on 12.09.2023.
//

import Foundation
import Firebase

struct CommentMV {
    
    let battle = GetBattlesMV()
    let db = Firestore.firestore()
    
    func createComment(battleId: String, comment: String) -> Comments{
        let user = Auth.auth().currentUser
        let comment = Comments(userEmail: (user?.email)!, userUid: user!.uid, comment: comment, battleUid: battleId)
        let documentId = UUID().uuidString
        let currentDate = Timestamp(date: Date())
        db.collection("Comments").document(documentId).setData(["UserEmail": comment.userEmail, "UserUid": comment.userUid, "Comment": comment.comment, "BattleUid": comment.battleUid, "createdAt": currentDate]) { error in
            if let error = error {
                print("There is an error during create comment! \(error.localizedDescription)")
            } else {
                db.collection("Users").document(user!.uid).collection(user!.email!).document("UserInfo").updateData(["Comments": FieldValue.arrayUnion([documentId])]) { error in
                    if let error = error {
                        print("There is an error during upload comment to userInfo \(error.localizedDescription)")
                    } else {
                        db.collection("Posts").document(comment.battleUid).updateData(["Comments": FieldValue.arrayUnion([documentId])]) { error in
                            if let error = error {
                                print("There is an error during upload comment to posts ")
                            } else {
                                print("The comments created succesfully!")
                            }
                        }
                    }
                }
            }
        }
        return comment
    }
    
    func checkIfCollectionExists(collectionName: String, completion: @escaping (Bool) -> Void) {
        db.collection(collectionName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error during collection check: \(error.localizedDescription)")
                completion(false)
            } else {
                if let snapshot = querySnapshot, !snapshot.isEmpty {
                    // Koleksiyon mevcut
                    completion(true)
                } else {
                    // Koleksiyon mevcut değil
                    completion(false)
                }
            }
        }
    }    
    
    func getComment(choosenBattle: Battles, completion: @escaping ([Comments]) -> Void) {
        checkIfCollectionExists(collectionName: "Comments") { result in
            if result {
                let userCollection = db.collection("Comments")
                var array = [Comments]()
                let dispatchGroup = DispatchGroup()
                for comment in choosenBattle.comment {
                    print(comment)
                    dispatchGroup.enter()
                    userCollection.document(comment).getDocument { (document, error) in
                        if let error = error {
                            print("Error during get comments: \(error.localizedDescription)")
                        } else {
                            if let document = document,
                               let data = document.data() {
                                if let comment = data["Comment"] as? String,
                                   let userEmail = data["UserEmail"] as? String,
                                   let userUid = data["UserUid"] as? String,
                                   let battleId = data["BattleUid"] as? String {
                                    let newComment = Comments(userEmail: userEmail, userUid: userUid, comment: comment, battleUid: battleId)
                                    array.append(newComment)
                                }
                            }
                        }
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(array)
                }
            }
        }
    }
}
