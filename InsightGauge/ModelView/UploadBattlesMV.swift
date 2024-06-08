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
    
    func deleteBattle (choosenBattle: Battles) {
//        let documentID = informationArray[indexPath.row].documentId
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        let userCollection = db.collection("Posts").document(choosenBattle.id)
        let userCollection2 = db.collection("Users").document(user!.uid).collection((user?.email)!).document("UserInfo")
        deleteFields(userCollection: userCollection2, removableObject: "Battles", removeObjectId: [choosenBattle.id])
        for comment in choosenBattle.comment {
            deleteFields(userCollection: userCollection2, removableObject: "Comments", removeObjectId: [comment])
        }
        userCollection.delete() { error in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else {
                print("Belge silindi.")
            }
        }
    }
    
    func deleteFields(userCollection: DocumentReference, removableObject: String, removeObjectId: [String]) {
        userCollection.updateData([
            removableObject: FieldValue.arrayRemove(removeObjectId)
        ]) { error in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else {
                print("Öğe başarıyla silindi.")
            }
        }
    }
    
    func createBattle(firsImage: String, firstTitle: String, secondeImage: String, secondTitle: String) {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let documentId = UUID().uuidString
        let currentDate = Timestamp(date: Date())
        print("Current Dateeee \(currentDate)")
        let battle = Battles(id: documentId, firstImage: firsImage, firstTitle: firstTitle, secondImage: secondeImage, secondTitle: secondTitle, userEmail: (user?.email)!, userUID: user!.uid, comment: [], votes: [])
        getUserCollectionPosts().document(documentId).setData(["ID": battle.id, "FirstImage": battle.firstImage, "FirstTitle": battle.firstTitle, "SecondImage": battle.secondImage, "SecondTitle": battle.secondTitle, "UserEmail": battle.userEmail, "UserUID": battle.userUID, "Comments": battle.comment, "Votes": battle.votes, "createdAt": currentDate]) { error in
            if let error = error {
                print("There is an error during create battle! \(error.localizedDescription)")
            } else {
                db.collection("Users").document(user!.uid).collection(user!.email!).document("UserInfo").updateData(["Battles": FieldValue.arrayUnion([documentId])]) { error in
                    if let error = error {
                        print("There is an error during upload battle to userInfo \(error.localizedDescription)")
                    } else {
                        print("The Battle created succesfully!")
                        db.collection("Comments").addDocument(data: [:]) { error in
                            if let error = error {
                                print("Koleksiyon oluşturma hatası: \(error.localizedDescription)")
                            } else {
                                print("Koleksiyon başarıyla oluşturuldu: Comments")
                            }
                        }
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
