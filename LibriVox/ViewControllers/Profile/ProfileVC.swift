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
    
    @IBOutlet weak var switchMode: UISwitch!
    @IBOutlet weak var logoutBtn: UILabel!
    
    var currentTheme = UITraitCollection.current.userInterfaceStyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePhoto.contentMode = .scaleToFill
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        logoutBtn.addGestureRecognizer(tap)
        
        getUserInfo(User.NAME) { name in
            if let name = name {
                self.nameUser.text = name
                downloadProfileImage(name, self.profilePhoto)
            }else{
                guard let name = Auth.auth().currentUser?.displayName else { return }
                self.nameUser.text = name
                
                guard let url = Auth.auth().currentUser?.photoURL else{
                    self.profilePhoto.loadImage(from: imageWith(name: name)!)
                    return
                }
                
                self.profilePhoto.loadImage(from:url)
            }
        }
        
        switchMode.isOn =  currentTheme == .dark ? true: false
        nicknameUser.text = Auth.auth().currentUser?.email
    }
    
    @IBAction func tapFunction(sender: UITapGestureRecognizer) {
        logoutUser()
    }
    
    @IBAction func switchTheme(_ sender: UISwitch) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let firstWindow = windowScene.windows.first {
            
            let newTheme: UIUserInterfaceStyle = currentTheme == .dark ? .light : .dark
            firstWindow.overrideUserInterfaceStyle = newTheme
            currentTheme = newTheme
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
