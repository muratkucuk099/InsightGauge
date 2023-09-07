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
    
    func createUser(name: String, userName: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        let user = UserAuth(name: name, userName: userName, email: email, password: password, battles: [""])
        
        Auth.auth().createUser(withEmail: user.email, password: user.password) { authResult, error in
            if let error = error {
                print("Error signUp")
                print(error.localizedDescription)
                completion(error) // Hata durumunda completion çağrısı ve error dönüşü
                return
            }
            
            let db = Firestore.firestore()
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
}
