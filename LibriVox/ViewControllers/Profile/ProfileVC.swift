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
    
    
    @IBOutlet weak var AboutBtn: UILabel!
    @IBOutlet weak var switchMode: UISwitch!
    @IBOutlet weak var logoutBtn: UILabel!
    
    var currentTheme = UITraitCollection.current.userInterfaceStyle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapFunctionAbout))
        AboutBtn.addGestureRecognizer(tap1)
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        logoutBtn.addGestureRecognizer(tap)
        
        
        getUserInfo(User.NAME) { name in
            if let name = name ?? Auth.auth().currentUser?.displayName {
                self.nameUser.text = name
                downloadProfileImage(name, self.profilePhoto)
            }
        }
        
        switchMode.isOn =  currentTheme == .dark ? true: false
        nicknameUser.text = Auth.auth().currentUser?.email
    }
    
    @IBAction func tapFunction(sender: UITapGestureRecognizer) {
        logoutUser()
    }
    
    @IBAction func tapFunctionAbout(sender: UITapGestureRecognizer) {
        aboutPage()
    }
    func aboutPage() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "aboutPage") as! UIViewController
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
        appDelegate.resetCoreDataSchema()
        clearUserDefaults()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "LoginId") as! UIViewController
        self.present(vc, animated: true, completion: nil)
        
    }
    func clearUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

}
