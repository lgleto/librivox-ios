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
import CoreData
import MobileCoreServices

let USER_COLLECTION = "users"
let TRENDING_COLLECTION = "books"
let GENRES_COLLECTION = "genres"
let USERBOOK_COLLECTION = "library"

let firestore = Firestore.firestore()
let storage = Storage.storage().reference()


func getUserInfo(_ field: String, _ callback: @escaping (String?) -> Void) {
    let userRef = firestore.collection(USER_COLLECTION).document(Auth.auth().currentUser!.uid)
    
    userRef.addSnapshotListener { (documentSnapshot, error) in
        if let error = error {
            print("Error getting user document: \(error.localizedDescription)")
            callback(nil)
        } else if let document = documentSnapshot, document.exists {
            let data = document.data()
            let info = data?[field] as? String
            callback(info)
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
            storeUserInfoToUserDefaults()
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

func downloadProfileImage(_ imageView: LoadingImage) {
    let imageRef = storage.child("images/\(Auth.auth().currentUser!.uid)/userPhoto")
    
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
        } else if let imageData = data {
            imageView.loadImage(from: UIImage(data: imageData)!)
        } else if let url = Auth.auth().currentUser?.photoURL {
            imageView.loadImageURL(from: url)
        } else {
            //imageView.loadImage(from: imageWith(name: name)!)
        }
    }
}

func downloadProfileImage() {
    let imageRef = storage.child("images/\(Auth.auth().currentUser!.uid)/userPhoto")
    
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
        } else if let imageData = data {
            if let image = UIImage(data: imageData) {
                saveProfileImageToPreferences(image)
            }else if let url = Auth.auth().currentUser?.photoURL {
                downloadImage(url: url){img in
                    saveProfileImageToPreferences(img)
                }
            }
        }
    }
}




func updateEmail(_ credential: AuthCredential, _ email: String, view : UIViewController){
    if let user = Auth.auth().currentUser{
        user.reauthenticate(with: credential) { (result, error) in
            if let error = error {
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


import FirebaseStorage

func saveBookImgFBStorage(bookID: String, image: UIImage, completion: @escaping (URL?) -> Void) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        completion(nil)
        return
    }
    let storage = Storage.storage()
    let storageRef = storage.reference()
    
    let bookCoversRef = storageRef.child("BookCover")
    
    let imageRef = bookCoversRef.child("\(bookID).jpg")
    imageRef.downloadURL { (url, error) in
        if let error = error {
            // Image doesn't exist, upload the new image
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let uploadTask = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    completion(nil)
                    return
                }
                
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(nil)
                        return
                    }
                    
                    if let downloadURL = url {
                        completion((downloadURL))
                    } else {
                        completion(nil)
                    }
                }
            }
            
            uploadTask.observe(.failure) { errorSnapshot in
                if let error = errorSnapshot.error {
                    completion(nil)
                }
            }
        } else {
            // Image already exists, return the URL
            if let downloadURL = url {
                completion((downloadURL))
            } else {
                completion(nil)
            }
        }
    }
}


func addToCollection(_ book: Book, _ image:UIImage,  completion: @escaping (String?) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection("library")
    
    let documentRef = bookCollectionRef.document(book.book._id!)
    
    saveBookImgFBStorage(bookID: book.book._id!, image: image){url in
        if let url = url{
            
            var book = book
            book.imageUrl = url.absoluteString
            
            documentRef.setData(book.getBookDictionary()!) { error in
                if let error = error {
                    print("Error adding book to collection: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("foi")
                    completion(documentRef.documentID)
                }
                
            }
        }
    }
}


func addTrendingtoBookSave(idBook: String,completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let bookRef = db.collection(TRENDING_COLLECTION)
    var levelTrending = 0
    //print(bookRef.collectionID)
    //print(bookRef.description)
    
    
    let query = bookRef.whereField("id", isEqualTo: idBook)
    print(query.description)
    
    query.addSnapshotListener { snapshot, err in
        
        if let err = err {
            print("Error fetching books: \(err.localizedDescription)")
            completion(false)
            return
        }
        
        guard let documents = snapshot?.documents else {
            completion(false)
            return
        }
        if let trending = documents.first,
           let trendingStr = trending.get("trending") as? String {
            print(trending.documentID)
            print(trendingStr)
            levelTrending = Int(trendingStr)!
            levelTrending += 5
            
            let newData: [String: String] = [
                "id": idBook,
                "trending": String(levelTrending)
            ]
            
            print(newData)
            
            bookRef.document(trending.documentID).updateData(newData){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    completion(false)
                    return
                } else {
                    completion(true)
                    return
                }
            }
            
        }
        
    }
}


func getAllBooks() {
    
    print("oiii \(UserDefaults.standard.string(forKey: "currentUserID"))")
    guard let authUID = UserDefaults.standard.string(forKey: "currentUserID") else {
        return
        
    }
    let db = Firestore.firestore()
    
    let userRef = db.collection("users").document(authUID)
    let bookCollectionRef = userRef.collection("library")
    
    bookCollectionRef.addSnapshotListener { snapshot, error in
        if let error = error {
            print("Error fetching books: \(error.localizedDescription)")
            return
        }
        
        guard let documents = snapshot?.documents else {
            return
        }
        
        for document in documents {
            do {
                let audiobookData = document.data()["audiobook"] as? [String: Any]
                let audiobookJSONData = try JSONSerialization.data(withJSONObject: audiobookData ?? [:], options: [])
                let audiobook = try JSONDecoder().decode(Audiobook.self, from: audiobookJSONData)
                
                let isReading = document.get("isReading") as? Bool ?? false
                let isFav = document.get("isFav") as? Bool
                let isFinished = document.get("isFinished") as? Bool
                let sectionStopped = document.get("sectionStopped") as? String
                let timeStopped = document.get("timeStopped") as? String
                let imageUrl = document.get("imageUrl") as? String
                
                let bookData = Book(book: audiobook, isReading: isReading, isFav: isFav, isFinished: isFinished, sectionStopped: Int32(sectionStopped ?? "0"), timeStopped: Int32(timeStopped ?? "0"), imageUrl: imageUrl)
                
                addAudiobookCD(book: bookData)
            } catch {
                print("Error decoding audiobook: \(error)")
            }
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var existingBookIDs: [String] = []
        do {
            let existingBooks = try context.fetch(AudioBooks_Data.fetchRequest()) as! [AudioBooks_Data]
            existingBookIDs = existingBooks.map { $0.id ?? "" }
        } catch {
            print("Error fetching existing books from Core Data: \(error)")
        }
        
        for existingBookID in existingBookIDs {
            if !documents.contains(where: { $0.documentID == existingBookID }) {
                deleteAudiobookCD(bookId: existingBookID)
            }
        }
    }
}

func updateProfileImage(_ img: UIImage) {
    saveProfileImageToPreferences(img)
    guard let imageData = img.jpegData(compressionQuality: 0.8) else { return }
    let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, "jpg" as CFString, nil)?.takeRetainedValue() as String?
    let filePath = "images/\(Auth.auth().currentUser!.uid)/\("userPhoto")"
    let storageRef = Storage.storage().reference()
    
    let metaData = StorageMetadata()
    metaData.contentType = contentType
    storageRef.child(filePath).putData(imageData, metadata: metaData) { (_, error) in
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
}

func isBookMarkedAs(_ parameter: String, value: Bool, documentID: String, completion: @escaping (Bool?) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookDocumentRef = userRef.collection("library").document(documentID)
    
    bookDocumentRef.getDocument { snapshot, error in
        if let error = error {
            print("Error observing book document: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let document = snapshot, document.exists else {
            completion(nil)
            return
        }
        
        let isMarked = document.get(parameter) as? Bool ?? nil
        completion(isMarked)
    }
}

func updateBookParameter(_ parameter: String, value: Bool, documentID: String) {
    let db = Firestore.firestore()
    let userRef = db.collection(USER_COLLECTION).document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection(USERBOOK_COLLECTION)
    let documentRef = bookCollectionRef.document(documentID)
    
    let updateData = [parameter: value]
    
    documentRef.updateData(updateData) { error in
        if let error = error {
            print("Error updating book parameter: \(error.localizedDescription)")
        }
    }
}

func updateBookParameter(_ parameter: String, value: String?, documentID: String) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection("library")
    let documentRef = bookCollectionRef.document(documentID)
    
    let updateData = [parameter: value]
    
    documentRef.updateData(updateData) { error in
        if let error = error {
            print("Error updating book parameter: \(error.localizedDescription)")
        }
    }
}

func addTrendingToBook(book:Audiobook, lvlTrending:Int, completion: @escaping (Bool?) -> Void) {
    let db = Firestore.firestore()
    let bookRef = db.collection(TRENDING_COLLECTION)
    let query = bookRef.whereField("id", isEqualTo: book._id!)
    var levelTrending = 0
    query.getDocuments { querySnapshot, error in
        if let error = error {
            print("Error getting documents: \(error)")
            return
        }
        
        if ((querySnapshot?.documents.count)! <= 0) {
            addBookToTrending(book: book) { yes in
                if yes! {
                    print("livro guardado")
                    addTrendingToBook(book: book,lvlTrending: lvlTrending, completion: completion)
                } else {
                    print("erro na gravação")
                }
            }
        }
        
        guard let documents = querySnapshot?.documents else {
            print("No documents found")
            return
        }
        
        if let trending = documents.first,
           let trendingStr = trending.get("trending") as? String {
            print(trending.documentID)
            levelTrending = Int(trendingStr)!
            levelTrending += lvlTrending
            
            let newData: [String: String] = [
                "id": book._id!,
                "trending": String(levelTrending)
            ]
            bookRef.document(trending.documentID).updateData(newData){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    completion(false)
                    return
                } else {
                    completion(true)
                    return
                }
            }
            
        }
        
    }
}

func addBookToTrending(book:Audiobook, completion: @escaping (Bool?) -> Void) {
    let db = Firestore.firestore()
    let bookRef = db.collection(TRENDING_COLLECTION)
    bookRef.addDocument(data: book.getBookDictionaryWithTrending()!) { err in
        if let err = err {
            print("Error adding book to collection: \(err.localizedDescription)")
            completion(false)
        }
        completion(true)
        return
        //addBookCD(book: book)
    }
}

func updateUserParameter(_ parameter: String, value: String) {
    let db = Firestore.firestore()
    var dataToUpdate = [String: Any]()
    
    dataToUpdate = [parameter: value]
    
    firestore.collection(USER_COLLECTION).document(Auth.auth().currentUser!.uid).updateData(dataToUpdate) { err in
        if let err = err {
            print("Error writing document: \(err.localizedDescription)")
        }
    }
}

func getBookCoverFB(id: String, completion: @escaping (UIImage?) -> Void) {
    let imageRef = storage.child("BookCover/\(id)")
    
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
            completion(nil)
        } else if let imageData = data, let image = UIImage(data: imageData) {
            completion(image)
        } else {
            completion(nil) 
        }
    }
}

func storeSectionTime(currentBookId:String) {
    let 🎧 = PlayerHandler.sharedInstance
    
    updateBookParameter("sectionStopped", value: String(🎧.currentSection! + 1), documentID: currentBookId)
    updateBookParameter("timeStopped", value: String(🎧.progress), documentID: currentBookId)
}
///TODO: Function Under Construction... Please do not break it ;(
func getSectionTime(documentID: String, completion: @escaping (BookStatus?) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection("library")
    let documentRef = bookCollectionRef.document(documentID)
    
    
    documentRef.getDocument { snapshot, err in
        if let err = err {
            print("Error observing book document: \(err.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let document = snapshot, document.exists else {
            completion(nil)
            return
        }
        var bookstatus = BookStatus()
        bookstatus.timeStopped = document.get("timeStopped") as? String ?? ""
        bookstatus.sectionStopped = document.get("sectionStopped") as? String ?? ""
        bookstatus.id = documentID
        
        completion(bookstatus)
    }
}

