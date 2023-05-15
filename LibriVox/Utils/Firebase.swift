//
//  Firebase.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 05/05/2023.
//

import Foundation
import SwaggerClient
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

let USER_COLLECTION = "users"
let TRENDING_COLLECTION = "books"
let GENRES_COLLECTION = "genres"
let USERBOOK_COLLECTION = "bookCollection"

let firestore = Firestore.firestore()
let storage = Storage.storage().reference()


func getUserInfo(_ field: String,_ callback: @escaping (String?) -> Void) {
    let userRef = firestore.collection(USER_COLLECTION).document(Auth.auth().currentUser!.uid)
    
    userRef.getDocument { (document, error) in
        if let error = error {
            print("Error getting user document: \(error.localizedDescription)")
            callback(nil)
        } else if let document = document, document.exists {
            let data = document.data()
            let name = data?["\(field)"] as? String
            callback(name)
        } else {
            print("User document does not exist")
            callback(nil)
        }
    }
}

func updateUserInfo(name: String, username: String, view: UIViewController) {
    var dataToUpdate = [String: Any]()
    
    dataToUpdate = [
        User.NAME: name,
        User.USERNAME: username
    ]
    
    firestore.collection(USER_COLLECTION).document(Auth.auth().currentUser!.uid).updateData(dataToUpdate) { err in
        if let err = err {
            print("Error writing document: \(err.localizedDescription)")
        } else {
            showConfirmationAlert(view, "Profile updated succesfully!")
        }
    }
}

func getGenresFromDb(callback: @escaping ([GenreWithColor]) -> Void){
    let genresRef = firestore.collection(GENRES_COLLECTION)
    
    genresRef.getDocuments{(querySnapshot, err) in
        if let error = err{
            print("Error: \(err?.localizedDescription)")
            return
        }
        else
        {
            let genres = querySnapshot!.documents.compactMap { document -> GenreWithColor? in
                guard let id = document.data()[GenreWithColor.ID] as? String,
                      let name = document.data()[GenreWithColor.NAME] as? String,let mainColor = document.data()[GenreWithColor.MAIN_COLOR] as? String,let secondaryColor = document.data()[GenreWithColor.SECONDARY_COLOR] as? String,let descr = document.data()[GenreWithColor.DESCR] as? String?
                else {
                    print("Invalid data format for document \(document.documentID)")
                    return nil
                }
                return GenreWithColor(_id: id, name: name, mainColor: mainColor, secondaryColor: secondaryColor, descr: descr)
                
            }
            
            callback(genres)
        }
        
    }
}

func getBooksFromUser(field: String, value: Bool, completion: @escaping ([Audiobook]) -> Void) {
    let userRef = firestore.collection(USER_COLLECTION).document(Auth.auth().currentUser!.uid)
    let bookCollectionRef =  userRef.collection(USERBOOK_COLLECTION).whereField(field, isEqualTo: value)
    
    bookCollectionRef.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error getting documents: \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard let documents = querySnapshot?.documents, !documents.isEmpty else {
            print("No documents found")
            completion([])
            return
        }
       
        var finalList: [Audiobook] = []
        for document in documents {
            if let book = BookUser(dict: document.data()) {
                
                DefaultAPI.audiobooksIdBookIdGet(bookId: Int64(book.id!)!, format: "json", extended: 1) { data, error in
                    if let error = error {
                        print("Error:", error.localizedDescription)
                        return
                    }
                    if let data = data {
                        finalList.append(contentsOf: data.books!)
                        completion(finalList)
                    }
                }
            }
        }
    }
}
/*func getBooksFromUser(field: String, value: Bool, completion: @escaping ([Audiobook]) -> Void) {
    let userRef = firestore.collection(USER_COLLECTION).document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection(USERBOOK_COLLECTION).whereField(field, isEqualTo: value)
    
    // Add a listener to observe changes in the book collection
    bookCollectionRef.addSnapshotListener { (querySnapshot, error) in
        if let error = error {
            print("Error getting documents: \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard let documents = querySnapshot?.documents, !documents.isEmpty else {
            print("No documents found")
            completion([])
            return
        }
        
        var finalList: [Audiobook] = []
        var remainingTasks = documents.count
        
        for document in documents {
            if let book = BookUser(dict: document.data()) {
                DefaultAPI.audiobooksIdBookIdGet(bookId: Int64(book.id!)!, format: "json", extended: 1) { data, error in
                    if let error = error {
                        print("Error:", error.localizedDescription)
                        remainingTasks -= 1
                        checkCompletion()
                        return
                    }
                    if let data = data {
                        finalList.append(contentsOf: data.books!)
                    }
                    remainingTasks -= 1
                    checkCompletion()
                }
            }
        }
        
        func checkCompletion() {
            if remainingTasks == 0 {
                completion(finalList)
            }
        }
    }
}
*/

func downloadProfileImage(_ name: String, _ imageView: UIImageView) {
    let imageRef = storage.child("images/\(Auth.auth().currentUser!.uid)/userPhoto")
    
    let defaultImage = imageWith(name: name)
    imageView.image = defaultImage
    imageView.backgroundColor = UIColor(named: "Green Tone")
    
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
        } else {
            if let imageData = data {
                imageView.image = UIImage(data: imageData)
            }
        }
    }
}


func updateEmail(_ credential: AuthCredential, _ email: String, view : UIViewController){
    if let user = Auth.auth().currentUser{
        user.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                print("Error reauthenticating user: \(error.localizedDescription)")
                showConfirmationAlert(view, "Wrong password. Try again.")
                return
            }
            user.updateEmail(to: email) { (error) in
                if let error = error {
                    print("Error updating email: \(error.localizedDescription)")
                    return
                }
                else{
                    showConfirmationAlert(view, "Email updated sucessfully")
                }
            }
        }
    }
    
}

func loadCurrentUser( callback: @escaping (User?)->() ) {
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    db.collection("users")
      .document(currentUser!.uid)
      .addSnapshotListener({ snapshot, error in
        if let s = snapshot,
          let d = s.data(),
          let user = User.init(dict: d ) {
          callback(user )
        }else {
          callback(nil)
        }
      })
  }

