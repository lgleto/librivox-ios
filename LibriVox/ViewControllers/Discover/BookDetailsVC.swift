//
//  BookDetailsVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 30/03/2023.
//

import UIKit
import SwaggerClient
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct BookUser {
    let id: String
    let timeStopped: String
    let isReading: Bool

    init?(data: [String: Any]) {
        guard let id = data["id"] as? String,
              let timeStopped = data["timeStopped"] as? String,
              let isReading = data["isReading"] as? Bool else {
            return nil
        }
        self.id = id
        self.timeStopped = timeStopped
        self.isReading = isReading
    }
    
    var dictionary: [String: Any] {
            return [
                "id": id,
                "timeStopped": timeStopped,
                "isReading": isReading
            ]
        }
}



class BookDetailsVC: UIViewController {
    
    @IBOutlet weak var languageBook: UILabel!
    @IBOutlet weak var durationBook: UILabel!
    @IBOutlet weak var genreBook: UILabel!
    @IBOutlet weak var authorBook: UILabel!
    @IBOutlet weak var numSectionsBook: UILabel!
    @IBOutlet weak var descrBook: UILabel!
    @IBOutlet weak var sectionsTV: UITableView!
    @IBOutlet weak var bookImg: RoundedBookImageView!
    @IBOutlet weak var backgroundImage: BlurredImageView!
    
    
    @IBOutlet weak var playBtn: UIButton!
    
    var book: Audiobook?
    var bookUser: BookUser?
    var sections: [SwaggerClient.Section] = []
    let isAtLibrary = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let  selectedImage  = UIImage(named: "pause.svg")
        let normalImage = UIImage(named: "play.svg")
        
        playBtn.setImage(normalImage, for: .normal)
        playBtn.setImage(selectedImage, for: .selected)
        
        sectionsTV.dataSource = self
        sectionsTV.delegate = self
        
        if let book = book {
            descrBook.text = removeHtmlTagsFromText(text: book._description ?? "")
            numSectionsBook.text = book.numSections
            genreBook.text = displayGenres(strings: book.genres ?? [])
            authorBook.text = (book.authors?[0].firstName ?? "") + " " + (book.authors?[0].lastName ?? "")
            
            durationBook.text = book.totaltime
            languageBook.text = book.language!
            
            
            isInCollection(id: book._id!) { (result) in
                self.playBtn.isSelected = result
            }
            
            
            self.title = book.title!
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @IBAction func didClick(_ sender: UIButton) {
        playBtn.isSelected = !playBtn.isSelected
        if playBtn.isSelected {
            
            let bookData: [String: Any] = [
                "id": book?._id,
                 "timeStopped": "",
                 "isReading": true
            ]

            if let bookUser = BookUser(data: bookData) {
                  addToCollection(bookUser)
                print("add com o id \(book?._id)")
            }
          
        }
        
        if playBtn.isSelected {print("I am selected.")}
        else {print("I am not selected.")}
    }
}


func isInCollection(id: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    let newDocRef = userRef.collection("bookCollection").whereField("id", isEqualTo: id)
    
    newDocRef.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error getting documents: \(error.localizedDescription)")
            return
        }
        
        if let documents = querySnapshot?.documents, !documents.isEmpty {
            print("Ta aqui")
            completion(true)
        } else {
            print("Nao ta aqui")
            completion(false)
        }
    }
}


func addToCollection(_ book: BookUser) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection("bookCollection")
    let bookId = book.id
    
    bookCollectionRef.whereField("id", isEqualTo: bookId).getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error querying book collection: \(error.localizedDescription)")
            return
        }
        
        guard querySnapshot!.documents.isEmpty else {
            print("Book already exists in collection")
            return
        }
        
        // If the book does not already exist, add it to the collection
        let newDocRef = bookCollectionRef.document()
        newDocRef.setData(book.dictionary) { error in
            if let error = error {
                print("Error adding book to collection: \(error.localizedDescription)")
            } else {
                print("Book added to collection with ID: \(newDocRef.documentID)")
            }
        }
    }
}

extension BookDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sectionsTV.dequeueReusableCell(withIdentifier: "SectionsCell", for: indexPath) as! SectionsCell
        let section = book?.sections?[indexPath.row]
        
        let seconds = Int(section?.playtime ?? "Not found") ?? 0
        
        cell.titleSection.text = section?.title
        cell.durationSection.text! = "Duration: \(secondsToMinutes(seconds: seconds))min "
        return cell
    }
}

