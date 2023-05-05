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

class EditProfileVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func updateProfile(_ sender: Any) {
        
        guard let name = name.text, !name.isEmpty,
              let email = email.text, !email.isEmpty,
              let username = userName.text, !username.isEmpty else {
            showAlert(self, "All fields are required")
            return
        }
        updateUserInfo(name: name, username: username, email: email)
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        guard let email = email.text, !email.isEmpty else{
            showAlert(self, "A valid email is required")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                print("Email sent succesfully")
            }
        }
    }
    
    @IBOutlet weak var email: BlueShadowUITextField!
    @IBOutlet weak var userName: BlueShadowUITextField!
    @IBOutlet weak var name: BlueShadowUITextField!
    @IBOutlet weak var userPhoto: CircularImageView!
    
    let label = UILabel()
    var imagePicker = UIImagePickerController()
    var photoDarkened = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoTapped(_:)))
        userPhoto.addGestureRecognizer(tapGestureRecognizer)
        
        getUserInfo(UserData.name) { name in
            if let name = name {
                self.name.text = name
                downloadProfileImage(name, self.userPhoto)
            }
        }
        
        getUserInfo(UserData.username) { userName in
            if let userName = userName {
                self.userName.text = userName
            }
        }
        
        getUserInfo(UserData.email) { email in
            if let email = email {
                self.email.text = email
            }
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
    
}
