//
//  ViewController.swift
//  InsightGauge
//
//  Created by Mac on 13.08.2023.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    
    let userAuthMV = UserAuthMV()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        
        errorLabel.text = ""
        if emailTextfield.text != "" , passwordTextfield.text != "" {
            userAuthMV.loginUser(email: emailTextfield.text!, password: passwordTextfield.text!) { error in
                if let error = error {
                    self.errorLabel.text = error.localizedDescription
                } else {
                    self.performSegue(withIdentifier: K.loginSegue, sender: nil)
                }
            }
        } else {
            errorLabel.text = "No field can be left blank!"
        }
    }
}
