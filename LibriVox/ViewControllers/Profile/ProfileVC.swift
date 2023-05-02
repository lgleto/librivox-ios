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
    
    @IBOutlet weak var logoutBtn: UILabel!
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        logoutBtn.addGestureRecognizer(tap)
        
        getNameOrUserName("name") { name in
            if let name = name {
                self.nameUser.text = name
                self.name = name
            }
            
            self.downloadImage(self.name, self.profilePhoto)
        }
        
        getNameOrUserName("username") { userName in
            if let userName = userName {
                self.nicknameUser.text = userName
            }
        }
        
    }
    
    @IBAction func tapFunction(sender: UITapGestureRecognizer) {
        logoutUser()
    }
    
    @IBAction func switchTheme(_ sender: UISwitch) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let firstWindow = windowScene.windows.first {
            
            let currentTheme = firstWindow.overrideUserInterfaceStyle
            let newTheme: UIUserInterfaceStyle = currentTheme == .dark ? .light : .dark
            firstWindow.overrideUserInterfaceStyle = newTheme
        }
        
    }
    
    func downloadImage(_ name: String, _ imageView: UIImageView) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(Auth.auth().currentUser!.uid)/userPhoto")
        
        let defaultImage = imageWith(name: name)
        imageView.image = defaultImage
        imageView.backgroundColor = UIColor(named: "Green Tone")
        
        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else {
                if let imageData = data {
                    imageView.image = UIImage(data: imageData)
                }
            }
        }
    }

    
     
    func logoutUser() {
        do { try Auth.auth().signOut() }
        catch { print("Already logged out") }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "LoginId") as! LoginVC
        self.present(vc, animated: true, completion: nil)
                
    }
    
}
