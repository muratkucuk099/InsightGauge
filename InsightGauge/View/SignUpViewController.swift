//
//  SignUpViewController.swift
//  InsightGauge
//
//  Created by Mac on 24.08.2023.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    
    let userAuthVM = UserAuthMV()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        
        errorLabel.text = ""
        if nameTextfield.text != "" && usernameTextfield.text != "" && emailTextfield.text != "" && passwordTextfield.text != "" {
            DispatchQueue.main.async { [self] in
                userAuthVM.createUser(name: nameTextfield.text!, userName: usernameTextfield.text!, email: emailTextfield.text!, password: passwordTextfield.text!) { error in
                    if let error = error {
                        self.errorLabel.text = error.localizedDescription
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            errorLabel.text = "No field can be left blank!"
        }
    }
}
