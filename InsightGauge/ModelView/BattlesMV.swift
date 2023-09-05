//
//  BattlesMV.swift
//  InsightGauge
//
//  Created by Mac on 31.08.2023.
//

import Foundation
import Firebase
import FirebaseStorage

struct BattlesMV{
    
    func getUserCollection()-> CollectionReference{
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("Users").document(user!.uid).collection(user!.email!)
        return userCollection
    }
    
    func createBattle(firsImage: String, firstTitle: String, secondeImage: String, secondTitle: String, comments: [String]?, firstVotesUers: [String]?, secondVotesUsers: [String]?) {
        let battle = Battles(firstImage: firsImage, firstTitle: firstTitle, secondImage: secondeImage, secondTitle: secondTitle, comments: comments, firstVotesUsers: firstVotesUers, secondVotesUsers: secondVotesUsers)
        
        let documentId = UUID().uuidString
        getUserCollection().document(documentId).setData(["FirstImage": battle.firstImage, "FirstTitle": battle.firstTitle, "SecondImage": battle.secondImage, "SecondTitle": battle.secondTitle, "Comments": [""], "FirstVotes": [""], "SecondVotes": [""]]) { error in
            if let error = error {
                print("There is an error during create battle! \(error.localizedDescription)")
            } else {
                print("The Battle created succesfully!") // Yüklenme tamamlandığında bu kısım çalışıyor
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
    
    func resetFunction(firstImage: UIImageView, firstTitle: UITextField, secondImage: UIImageView, secondTitle: UITextField) {
        
                
    }
}
