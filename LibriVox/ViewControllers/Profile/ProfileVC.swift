//
//  ProfileVC.swift
//  LibriVox
//
//  Created by Gloria Martins on 27/04/2023.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

class ProfileVC: UIViewController {

    @IBOutlet weak var profilePhoto: CircularImageView!
    @IBOutlet weak var nicknameUser: UILabel!
    @IBOutlet weak var nameUser: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(Auth.auth().currentUser!.uid)/userPhoto.jpg")

        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else {
                if let imageData = data {
                    self.profilePhoto.image =  UIImage(data: imageData)
                } else {
                    print("Error converting downloaded data to UIImage")
                }
            }
        }
        
        
        getNameOrUserName("name") { name in
            if let name = name {
                self.nameUser.text = name
            }
        }
        
        getNameOrUserName("username") { userName in
            if let userName = userName {
                self.nicknameUser.text = userName
            }
        }
    }
    
    @IBAction func switchTheme(_ sender: UISwitch) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let firstWindow = windowScene.windows.first {

            let currentTheme = firstWindow.overrideUserInterfaceStyle
            let newTheme: UIUserInterfaceStyle = currentTheme == .dark ? .light : .dark
            firstWindow.overrideUserInterfaceStyle = newTheme
        }

    }
}
