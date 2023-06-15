//
//  LoginVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 20/03/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import SwaggerClient

class LoginVC: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        let storyBoard :UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "HomepageTBC") as! UITabBarController
        home.modalTransitionStyle = .crossDissolve
        home.modalPresentationStyle = .fullScreen
        
        if (email.text == "") || (password.text == "") {
            
            let alert = UIAlertController(title: "Empty field", message: "Your field is empty", preferredStyle: .alert)
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
            if (email.text == "") {
                alert.title = "Email is empty"
                self.present(alert, animated: true, completion: nil)
            } else {
                alert.title = "Password is empty"
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                
                
               
                
                print(error)
                if (authResult != nil) {
                    UserDefaults.standard.set(Auth.auth().currentUser, forKey: "currentUserID")
                    self.self!.present(home, animated: true, completion: nil)
                } else {
                    let autError  = AuthErrorCode.init(_nsError: error! as NSError)
                    switch (autError.code){
                    case .invalidEmail:
                        // handle error
                        let alert = UIAlertController(title: "Invalid Email", message: "The email that was provided to us is invalid. Please check your email", preferredStyle: .alert)
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
                        self!.present(alert, animated: true, completion: nil)
                        //TODO: Alert this bitch
                        print("Invalid email")
                        break;
                    case .wrongPassword:
                        // handle error
                        //TODO: Alert this bitch
                        let alert = UIAlertController(title: "Wrong Password", message: "The password that was provided to us is invalid. Please check your password", preferredStyle: .alert)
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
                        self!.present(alert, animated: true, completion: nil)
                        print("wrong password")
                        break;
                    case .userNotFound:
                        let alert = UIAlertController(title: "Invalid Email", message: "The email that was provided to us is invalid. Please check your email", preferredStyle: .alert)
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
                        self!.present(alert, animated: true, completion: nil)
                        //TODO: Alert this bitch
                        print("user not found")
                        break
                    default:
                        //handel general error
                        print(error.debugDescription)
                        break;
                    }
                }
            }
        }
        

    }



    @IBAction func signInGoogle(_ sender: UIButton) {
        
        let storyBoard :UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "HomepageTBC") as! UITabBarController
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
                saveCurrentUser(name: (result?.user.displayName!)!, email: (result?.user.email!)!)
                self.self.present(home, animated: true, completion: nil)
            }
                

          // ...
        }
    }
    @IBAction func RegisterButton(_ sender: UIButton) {
        performSegue(withIdentifier: "loginToRegister", sender: nil)
    }
}
