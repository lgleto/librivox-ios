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

/*class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "YourDataModelName")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Context
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Book Operations
    
    func bookExists(withId id: String) -> Bool {
        let fetchRequest: NSFetchRequest<BookCD> = BookCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let count = try managedObjectContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking book existence: \(error.localizedDescription)")
            return false
        }
    }
    
    func createBookCD(from book: Book) {
        let bookCD = BookCD(context: managedObjectContext)
        bookCD.id = book.book._id
        bookCD.audiobook = book.book
        
        bookCD.isFav = book.isFav ?? false
        bookCD.isReading = book.isReading ?? false
        bookCD.isFinished = book.isFinished ?? false
        bookCD.sectionStopped = Int64(book.sectionStopped ?? 0)
        bookCD.timeStopped = Int64(book.timeStopped ?? 0)
        
        saveContext()
    }

    // MARK: - Core Data Saving
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error saving Core Data context: \(error.localizedDescription)")
            }
        }
    }
}*/

let USER_COLLECTION = "users"
let TRENDING_COLLECTION = "books"
let GENRES_COLLECTION = "genres"
let USERBOOK_COLLECTION = "bookCollection"

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

func downloadProfileImage(_ name: String,_ imageView: LoadingImage) {
    let imageRef = storage.child("images/\(Auth.auth().currentUser!.uid)/userPhoto")
    
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
        } else if let imageData = data {
            imageView.loadImage(from: UIImage(data: imageData)!)
        } else if let url = Auth.auth().currentUser?.photoURL {
            imageView.loadImageURL(from: url)
        } else {
            imageView.loadImage(from: imageWith(name: name)!)
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

/*func saveBookCover(image: UIImage, id: String, completion: @escaping (URL?) -> Void) {
 guard let imageData = image.jpegData(compressionQuality: 0.8) else {
 completion(nil)
 return
 }
 
 let filename = id + ".jpg"
 let storageRef = Storage.storage().reference().child("books")
 
 let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
 if let error = error {
 print("Error uploading image: \(error.localizedDescription)")
 completion(nil)
 return
 }
 
 storageRef.downloadURL { url, error in
 if let error = error {
 print("Error getting download URL: \(error.localizedDescription)")
 completion(nil)
 return
 }
 completion(url)
 }
 }
 }
 */


func addToCollection(_ book: Book, isFavorite: Bool? = nil, isReading: Bool? = nil, completion: @escaping (String?) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection("library")
    
    var bookToAdd = book
    
    getBookCoverFromURL(url: book.book.urlLibrivox){
        img in
        if let img = img{
            /*saveBookCover(image: img, id: book.book._id!){
             url in bookToAdd.imageUrl = url?.absoluteString*/
            
            let documentRef = bookCollectionRef.document(book.book._id!)
            documentRef.setData(bookToAdd.getBookDictionary()!) { error in
                if let error = error {
                    print("Error adding book to collection: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(documentRef.documentID)
                }
            }
            
            //}
            
            
        }
    }
    
    
}

func getBooksByParameter(_ parameter: String, value: Bool, completion: @escaping ([Book]) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection("library")
    
    let query = bookCollectionRef.whereField(parameter, isEqualTo: value)
    
    query.addSnapshotListener { snapshot, error in
        if let error = error {
            print("Error fetching books: \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard let documents = snapshot?.documents else {
            completion([])
            return
        }
        
        var books: [Book] = []
        for document in documents {
            do {
                let audiobookData = document.data()["audiobook"] as? [String: Any]
                let audiobookJSONData = try JSONSerialization.data(withJSONObject: audiobookData ?? [:], options: [])
                let audiobook = try JSONDecoder().decode(Audiobook.self, from: audiobookJSONData)
                
                let isReading = document.get("isReading") as? Bool ?? false
                let isFav = document.get("isFav") as? Bool
                let isFinished = document.get("isFinished") as? Bool
                let sectionStopped = document.get("sectionStopped") as? Int
                let timeStopped = document.get("timeStopped") as? Int
                
                let bookData = Book(book: audiobook, isReading: isReading, isFav: isFav, isFinished: isFinished, sectionStopped: sectionStopped, timeStopped: timeStopped)
                
                
                // Check if the book already exists in Core Data
              /*  if !CoreDataManager.shared.bookExists(withId: bookData.book._id!) {
                                    // Create a new BookCD instance and save it to Core Data
                                    CoreDataManager.shared.createBookCD(from: bookData)
                                }*/
                
                
                
                books.append(bookData)
                
            } catch {
                print("Error decoding audiobook: \(error)")
            }
        }
        
        completion(books)
    }
}

func isBookMarkedAs(_ parameter: String, value: Bool, documentID: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookDocumentRef = userRef.collection("library").document(documentID)
    
    bookDocumentRef.addSnapshotListener { snapshot, error in
        if let error = error {
            print("Error observing book document: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        guard let document = snapshot, document.exists else {
            completion(false)
            return
        }
        
        let isMarked = document.get(parameter) as? Bool ?? false
        completion(isMarked)
    }
}



func updateBookParameter(_ parameter: String, value: Bool, documentID: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection("library")
    let documentRef = bookCollectionRef.document(documentID)
    
    let updateData = [parameter: value]
    
    documentRef.updateData(updateData) { error in
        if let error = error {
            print("Error updating book parameter: \(error.localizedDescription)")
            completion(false)
        } else {
            completion(true)
        }
    }
    
}
