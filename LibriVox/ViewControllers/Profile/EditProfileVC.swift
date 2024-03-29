//
//  EditProfileVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 03/05/2023.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import MobileCoreServices

class EditProfileVC: AdaptedVC,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var email: BlueShadowUITextField!
    @IBOutlet weak var userName: BlueShadowUITextField!
    @IBOutlet weak var name: BlueShadowUITextField!
    @IBOutlet weak var userPhoto: CircularImageView!
    
    let label = UILabel()
    var imagePicker = UIImagePickerController()
    var photoDarkened = false
    var originalEmail: String?
    var originalName: String?
    var originalUserName: String?
    
    var userInfo: (displayName: String?, email: String?, userID: String?, userPhoto: UIImage?)?

    @IBAction func updateProfile(_ sender: Any) {
        guard let name = name.text, !name.isEmpty,
              let email = email.text, !email.isEmpty,
              let username = userName.text, !username.isEmpty else {
            showConfirmationAlert(self, "There's missing fields","All fields are required")
            return
        }
        
        if name != originalName || username != originalUserName{
            updateUserInfo(name: name, username: username, view: self)
        }
        
        if email != originalEmail{
            updateEmail(email)
        }
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        guard let email = email.text, !email.isEmpty else{
            showConfirmationAlert(self, "Fail to send email to:  \(originalEmail)", "Try again later.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                showConfirmationAlert(self, "Email sent succesfully")
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPhoto.contentMode = .scaleToFill
        if let img = userInfo?.userPhoto{
            userPhoto.image = img
        }
      
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoTapped(_:)))
        userPhoto.addGestureRecognizer(tapGestureRecognizer)
        
        
        if let displayName = userInfo?.displayName {
            name.text = displayName
            originalName = displayName
        }

        if let email = userInfo?.email {
            self.email.text = email
            originalEmail = email
        }
      
        
        
        
       /* getUserInfo(User.USERNAME) { userName in
            if let userName = userName {
                self.userName.text = userName
                self.originalUserName = userName
            }
        }*/
    }
    
    
    @objc func photoTapped(_ sender: UITapGestureRecognizer) {
        if photoDarkened {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                
                present(imagePicker, animated: true, completion: nil)
            }
            photoDarkened = false
        } else {
            darkenPhoto()
            photoDarkened = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            label.removeFromSuperview()
            userPhoto.alpha = 1
            userPhoto.image = image
            updateProfileImage(image)
           
            for subview in userPhoto.subviews {
                 if subview is UIView {
                     subview.removeFromSuperview()
                 }
             }
        }
    }
    
    func darkenPhoto() {
        let shadowView = UIView(frame: userPhoto.bounds)
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        shadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let shadowLayer = CALayer()
        shadowLayer.frame = shadowView.bounds
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 1.0
        shadowLayer.shadowOffset = CGSize.zero
        shadowLayer.shadowRadius = 10.0
        
        shadowView.layer.addSublayer(shadowLayer)
        userPhoto.addSubview(shadowView)
        setLabelChangePhoto()
    }

    
    func setLabelChangePhoto(){
        label.text = "Change Photo"
        label.font = UIFont(name:"Nunito", size: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        
        userPhoto.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: userPhoto.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: userPhoto.centerYAnchor).isActive = true
    }
    
 
    
    func updateEmail(_ email: String){
        if isValidEmail(email){
            let alertController = UIAlertController(title: "Password required to continue", message: "To update your email, please provide your password for authentication", preferredStyle: .alert)

            alertController.addTextField { (textField) in
                textField.isSecureTextEntry = true
                textField.placeholder = "Password"
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                if let password = alertController.textFields?.first?.text {
                    let credential = EmailAuthProvider.credential(withEmail: self.originalEmail!, password: password)
                    
                    //LibriVox.updateEmail(credential, email, view: self)
                }
            }

            alertController.addAction(cancelAction)
            alertController.addAction(okAction)

            present(alertController, animated: true, completion: nil)
           
        }else{
            showConfirmationAlert(self, "The email address is badly formatted.")
        }
    }
    
}
