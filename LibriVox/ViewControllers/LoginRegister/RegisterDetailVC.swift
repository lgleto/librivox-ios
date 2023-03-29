//
//  RegisterDetailVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 27/03/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class RegisterDetailVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var descText: UITextView!
    
    @IBOutlet weak var buttonPicture: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var localImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    

    @IBAction func completeButton(_ sender: UIButton) {
        let storyBoard :UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "HomepageTBC") as! UITabBarController
        home.modalTransitionStyle = .crossDissolve
        home.modalPresentationStyle = .fullScreen
        
        let storageRef = storage.reference()

        // Upload the file to the path "images/rivers.jpg"
        var data = NSData()
        data = localImage.jpegData(compressionQuality: 0.8)! as NSData
        // set upload path
        let filePath = "images/\(Auth.auth().currentUser!.uid)/\("userPhoto")"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).putData(data as Data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
            //store downloadURL
                //let downloadURL = metaData!.name
            //store downloadURL at database
                self.db.collection("users").document(Auth.auth().currentUser!   .uid).updateData([
                    "description": self.descText.text ?? ""
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
            
            }

            }
            

                
    }
    
    
    @IBAction func setPicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            buttonPicture.isHidden = true
            
            imageView.image = image
            localImage = image
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
