//
//  RegisterVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 23/03/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class RegisterVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var firstLastText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    
    
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func registerButton(_ sender: UIButton) {
        if (emailText.text == "") || (confirmPasswordText.text == "") || (firstLastText.text == "") || (passwordText.text == "") || (usernameText.text == "") {
            let alert = UIAlertController(title: "Empty field", message: "All fields are mandatory", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                    case .default:
                    print("default")
                    
                    case .cancel:
                    print("cancel")
                    
                    case .destructive:
                    print("destructive")
                    
                @unknown default:
                    print("this wasnt suposed to happen")
                }
            }))
        
            
            if (firstLastText.text == "") {
                alert.title = "Name is empty"
                self.present(alert, animated: true, completion: nil)
            } else if (usernameText.text == ""){
                alert.title = "Username is empty"
                self.present(alert, animated: true, completion: nil)
            } else if (emailText.text == ""){
                alert.title = "Email is empty"
                self.present(alert, animated: true, completion: nil)
            } else if (passwordText.text == ""){
                alert.title = "Password is empty"
                self.present(alert, animated: true, completion: nil)
            } else if (confirmPasswordText.text == ""){
                alert.title = "Please confirm your password"
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            if (confirmPasswordText.text != passwordText.text) {
                let alert = UIAlertController(title: "Passwords dont match", message: "Password and confirm password do not match", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                        case .default:
                        print("default")
                        
                        case .cancel:
                        print("cancel")
                        
                        case .destructive:
                        print("destructive")
                        
                    @unknown default:
                        print("this wasnt suposed to happen")
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { [self] authResult, error in
                    if (authResult != nil) {
                        db.collection("users").document(Auth.auth().currentUser!.uid).setData([
                            "name": firstLastText.text,
                            "username": usernameText.text
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                authenticateUser()
                            }
                        }
                        
                        print("user Register")
                        
                    } else{
                        print("User not register")
                        
                    }
                }
            }
            
        }
        
     
        
    }
    
    func authenticateUser() {
        let storyBoard :UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "HomepageTBC") as! UITabBarController
   
        
        guard let email = emailText.text, let password = passwordText.text else {
            print("Invalid email or password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user, error == nil {
                print("User authenticated successfully: \(user.uid)")
                UserDefaults.standard.set(authResult!.user.uid, forKey: "currentUserID")
                   UserDefaults.standard.synchronize()
                // Handle successful authentication, e.g., present the home screen
                 self.present(home, animated: true, completion: nil)
                
            } else {
                print("Failed to authenticate user: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    
    @IBAction func signInGoogle(_ sender: UIButton) {
        let storyBoard :UIStoryboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "RegisterDetailVC")
        home.modalTransitionStyle = .crossDissolve
        home.modalPresentationStyle = .fullScreen
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                
                UserDefaults.standard.set(Auth.auth().currentUser, forKey: "currentUserID")
              // At this point, our user is signed in
                self.self.self.present(home, animated: true, completion: nil)
            }
                

          // ...
        }
    }
    
    
    @IBAction func testing(_ sender: Any) {
        let storyBoard :UIStoryboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "RegisterDetailVC")
        home.modalTransitionStyle = .crossDissolve
        home.modalPresentationStyle = .fullScreen
        self.present(home, animated: true, completion: nil)
    }
    
}
