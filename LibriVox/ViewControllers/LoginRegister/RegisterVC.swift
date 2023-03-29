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
    
    var user = User(name: "", username: "", description: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    /*

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func registerButton(_ sender: UIButton) {
        
        let storyBoard :UIStoryboard = UIStoryboard(name: "LoginRegister", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "RegisterDetailVC")
        home.modalPresentationStyle = .fullScreen
        
        
        
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
                        //TODO: Store First/ Last name and username in Firestore
                        user.name = firstLastText.text ?? ""
                        user.username = usernameText.text ?? ""
                        // Add a new document in collection "cities"
                        db.collection("users").document(Auth.auth().currentUser!.uid).setData([
                            "name": user.name,
                            "username": user.username,
                            "description": user.description
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                        
                        //TODO: Change to the MAINSCREEN
                        self.self.present(home, animated: true, completion: nil)
                        print("user Register")
                        
                    } else{
                        print("User not register")
                        
                    }
                }
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
