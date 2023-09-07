//
//  BattlesMV.swift
//  InsightGauge
//
//  Created by Mac on 31.08.2023.
//

import Foundation
import Firebase
import FirebaseStorage

struct UploadBattlesMV{
    
    func getUserCollectionPosts()-> CollectionReference{
        let db = Firestore.firestore()
        let userCollection = db.collection("Posts")
        return userCollection
    }
    
    func createBattle(firsImage: String, firstTitle: String, secondeImage: String, secondTitle: String, comments: [String]?, firstVotesUers: [String]?, secondVotesUsers: [String]?) {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let battle = Battles(firstImage: firsImage, firstTitle: firstTitle, secondImage: secondeImage, secondTitle: secondTitle, userEmail: (user?.email)!, userUID: user!.uid, comments: [""], firstVotesUsers: [""], secondVotesUsers: [""])
        
        let documentId = UUID().uuidString
        getUserCollectionPosts().document(documentId).setData(["FirstImage": battle.firstImage, "FirstTitle": battle.firstTitle, "SecondImage": battle.secondImage, "SecondTitle": battle.secondTitle, "UserEmail": battle.userEmail, "UserUID": battle.userUID, "Comments": [""], "FirstVotes": [""], "SecondVotes": [""]]) { error in
            if let error = error {
                print("There is an error during create battle! \(error.localizedDescription)")
            } else {
                db.collection("Users").document(user!.uid).collection(user!.email!).document("UserInfo").updateData(["Battles": FieldValue.arrayUnion([documentId])]) { error in
                    if let error = error {
                        print("There is an error during upload battle to userInfo \(error.localizedDescription)")
                    } else {
                        print("The Battle created succesfully!")
                    }
                }
            }
        }
    }
    
    func mediaStorage(image: UIImage, completion: @escaping (String) -> Void) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        
        if let data = image.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data) { metadata, error in
                if let error = error {
                    //                    self.errorMessage(message: error?.localizedDescription ?? "Try Again") Error message
                    print("Error during put data \(error.localizedDescription)")
                } else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            if let imageUrl = imageUrl {
                                completion(imageUrl)
                            }
                        }
                    }
                }
            }
        }
    }
}
