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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoTapped(_:)))
        userPhoto.addGestureRecognizer(tapGestureRecognizer)
        
        getUserInfo(User.NAME) { name in
            if let name = name ?? Auth.auth().currentUser?.displayName {
                self.userName.text = name
                self.originalName = name
                downloadProfileImage(name, self.userPhoto)
            }
        }
        
        getUserInfo(User.USERNAME) { userName in
            if let userName = userName {
                self.userName.text = userName
                self.originalUserName = userName
            }
        }
        
        if let email = Auth.auth().currentUser?.email{
            self.email.text = email
            self.originalEmail = email
        }
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
            userPhoto.alpha = 0.5
            setLabelChangePhoto()
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
        }
    }
    
    func setLabelChangePhoto(){
        label.text = "Change Photo"
        label.font = UIFont(name:"Nunito", size: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        
        userPhoto.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: userPhoto.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: userPhoto.centerYAnchor).isActive = true
    }
    
    func updateProfileImage(_ img: UIImage) {
        guard let imageData = img.jpegData(compressionQuality: 0.8) else { return }
        let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, "jpg" as CFString, nil)?.takeRetainedValue() as String?
        let filePath = "images/\(Auth.auth().currentUser!.uid)/\("userPhoto")"
        let storageRef = Storage.storage().reference()
        
        let metaData = StorageMetadata()
        metaData.contentType = contentType
        storageRef.child(filePath).putData(imageData, metadata: metaData) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
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
                    
                    LibriVox.updateEmail(credential, email, view: self)
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
