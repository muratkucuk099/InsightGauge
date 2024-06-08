//
//  CreateViewController.swift
//  InsightGauge
//
//  Created by Mac on 29.08.2023.
//

import UIKit

class CreateViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var firstTextfield: UITextField!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondTextfield: UITextField!
    @IBOutlet weak var secondImageView: UIImageView!
    
    let battlesMV = UploadBattlesMV()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openingScene()
    }
    
    @IBAction func createBattlePressed(_ sender: UIButton) {
        if let firstView = firstImageView.image,
           let secondView = secondImageView.image,
           let firstTitle = firstTextfield.text?.trimmingCharacters(in: .whitespaces),
           let secondTitle = secondTextfield.text?.trimmingCharacters(in: .whitespaces),
           !firstTitle.isEmpty, !secondTitle.isEmpty,
           firstView != UIImage(named: "Placeholder-removebg-preview"),
           secondView != UIImage(named: "Placeholder-removebg-preview"),
           firstView != secondView {
                            battlesMV.mediaStorage(image: firstView) { firstResult in
                                self.battlesMV.mediaStorage(image: secondView) { secondResult in
                                    self.battlesMV.createBattle(firsImage: firstResult, firstTitle: firstTitle, secondeImage: secondResult, secondTitle: secondTitle)                                    
                                    DispatchQueue.main.async {
                                        self.resetFields()
                        }
                    }
                }
            }
        }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        resetFields()
    }
    
    func resetFields() {
        self.firstImageView.image = UIImage(named: "Placeholder-removebg-preview")
        self.secondImageView.image = UIImage(named: "Placeholder-removebg-preview")
        self.firstTextfield.text = ""
        self.secondTextfield.text = ""
    }
    
    func openingScene() {
        let views = [firstImageView, secondImageView]
        for view in views {
            view?.layer.borderWidth = 2
            view?.layer.cornerRadius = 15
            view!.isUserInteractionEnabled = true
            let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            view!.addGestureRecognizer(imageGestureRecognizer)
        }
    }
}

//MARK: - ImagePickerMethods
extension CreateViewController: UIImagePickerControllerDelegate {
    
    @objc func selectImage(_ sender: UITapGestureRecognizer){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        if let imageView = sender.view as? UIImageView {
            if imageView == firstImageView {
                imagePicker.title = "first"
            } else if imageView == secondImageView {
                imagePicker.title = "second"
            }
        }
        present(imagePicker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            if picker.title == "first" {
                firstImageView.image = selectedImage
            } else if picker.title == "second" {
                secondImageView.image = selectedImage
            }
        }
        self.dismiss(animated: true)
    }
}
