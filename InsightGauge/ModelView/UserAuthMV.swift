//
//  UserAuthMV.swift
//  InsightGauge
//
//  Created by Mac on 24.08.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserAuthMV {
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    func createUser(name: String, userName: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        let user = UserAuth(name: name, userName: userName, email: email, password: password, battles: [""])
        
        Auth.auth().createUser(withEmail: user.email, password: user.password) { authResult, error in
            if let error = error {
                print("Error signUp")
                print(error.localizedDescription)
                completion(error) // Hata durumunda completion çağrısı ve error dönüşü
                return
            }
            
            let userCollection = db.collection("Users").document(authResult?.user.uid ?? "").collection(user.email)
            userCollection.document("UserInfo").setData([
                "name": user.name,
                "userName": user.userName,
                "email": user.email,
                "password": user.password
            ]) { error in
                if let error = error {
                    print("Error during create document")
                    completion(error) // Hata durumunda completion çağrısı ve error dönüşü
                } else {
                    print("Document created succesfully")
                    completion(nil) // Hata olmadığında completion çağrısı ve hata olmadığına işaret eden nil dönüşü
                }
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func getUserInfo(completion: @escaping (UserAuth) -> Void) {
        let userCollection = db.collection("Users").document(user!.uid).collection(user!.email!).document("UserInfo")
        print("User Collection \(userCollection)")
        userCollection.addSnapshotListener { (document, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
            } else {
                if let document = document, document.exists {
                    // Belge başarıyla alındı ve mevcut
                    if let data = document.data() {
                        if let name = data["name"] as? String,
                           let userName = data["userName"] as? String,
                           let email = data["email"] as? String,
                           let password = data["password"] as? String,
                           let battles = data["Battles"] as? [String] { // battles olmadığında veri gelmiyor
                            let user = UserAuth(name: name, userName: userName, email: email, password: password, battles: battles)
                            completion(user)
                        }
                    }
                } else {
                    print("Belge bulunamadı veya mevcut değil.")
                }
            }
        }
    }
}
