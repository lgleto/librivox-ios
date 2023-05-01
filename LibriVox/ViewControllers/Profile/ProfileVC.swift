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
        
        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                    imageView.image = defaultImage
            } else {
                if let imageData = data {
                    imageView.image = UIImage(data: imageData)
                } else {
                    imageView.image = defaultImage
                }
            }
        }
    }

    
    func imageWith(name: String?) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = UIColor(named: "Green Tone")
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 64)
        
        var initials = ""
        if let initialsArray = name?.components(separatedBy: " ") {
            if let firstWord = initialsArray.first {
                if let firstLetter = firstWord.first {
                    initials += String(firstLetter).capitalized }
            }
            if initialsArray.count > 1, let lastWord = initialsArray.last {
                if let lastLetter = lastWord.first { initials += String(lastLetter).capitalized
                }
            }
        } else {
            return nil
        }
        
        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
    
    func logoutUser() {
        do { try Auth.auth().signOut() }
        catch { print("Already logged out") }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "LoginId") as! LoginVC
        self.present(vc, animated: true, completion: nil)
                
    }
    
}
