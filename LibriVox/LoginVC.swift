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
        
        DefaultAPI.rootGet(format:"json"){ data,error in
            print(data)
        }
        
        let storyBoard :UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "HomepageTBC") as! UITabBarController
        home.modalTransitionStyle = .crossDissolve
        home.modalPresentationStyle = .fullScreen
        
        _ = Auth.auth().addStateDidChangeListener { auth, user in
            if (user != nil) {
                
            }
        }
        
        DispatchQueue.main.async {
            if Auth.auth().currentUser != nil {
                self.present(home, animated: true, completion: nil)
                print("there is user")
            } else {
              // No user is signed in.
              // ...
            }
        }
        
        
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        let storyBoard :UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "HomepageTBC") as! UITabBarController
        home.modalTransitionStyle = .crossDissolve
        home.modalPresentationStyle = .fullScreen
        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            print(error)
            if (authResult != nil) {
                self.self!.present(home, animated: true, completion: nil)
            } else {
                let autError  = AuthErrorCode.init(_nsError: error! as NSError)
                switch (autError.code){
                case .invalidEmail:
                    // handle error
                    print("Invalid email")
                    break;
                case .wrongPassword:
                    // handle error
                    print("wrong password")
                    break;
                case .userNotFound:
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

    /*
    @IBAction func loginButton(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (authResult, error) in
          if let error = error as? NSError {
              
            
            switch AuthErrorCode(error.code) {
            case .operationNotAllowed:
                print("operation not allowed")
              // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
            case .userDisabled:
                print("User is disable")
              // Error: The user account has been disabled by an administrator.
            case .wrongPassword:
                print("Wrong password")
              // Error: The password is invalid or the user does not have a password.
            case .invalidEmail:
                print("Invalid Email")
              // Error: Indicates the email address is malformed.
            default:
                print("Error: \(error.localizedDescription)")
            }
          } else {
            print("User signs in successfully")
            let userInfo = Auth.auth().currentUser
            let email = userInfo?.email
          }
        }
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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

              // At this point, our user is signed in
                self.self.present(home, animated: true, completion: nil)
            }
                

          // ...
        }
    }
    @IBAction func RegisterButton(_ sender: UIButton) {
        performSegue(withIdentifier: "loginToRegister", sender: nil)
    }
}
