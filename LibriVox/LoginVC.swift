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

class LoginVC: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

                
        

        // Do any additional setup after loading the view.
    }
    

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
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
