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

class RegisterVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var emailText: UITextField!
    
    
    
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
