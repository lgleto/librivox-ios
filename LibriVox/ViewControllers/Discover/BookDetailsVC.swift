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
    @IBOutlet weak var favBtn: UIButton!
    
    var book: Audiobook?
    var bookUser: BookUser?
    var sections: [Section] = []
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
            
            getCoverBook(url: book.urlLibrivox!){
                img in
                self.bookImg.kf.setImage(with: img)
                self.bookImg.contentMode = .scaleToFill
                
                self.backgroundImage.kf.setImage(with: img)
                self.backgroundImage.contentMode = .scaleToFill
            }
            
            isInCollection(id: book._id!) { (result) in
                var state = false
                if !result.isEmpty {state = true
                    self.bookUser?.key = result
                }
                self.playBtn.isSelected = state
            }
            
            self.title = book.title!
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    //Check if already exists
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
            }
        }
    }
    
    @IBAction func clickFav(_ sender: Any) {
        favBtn.isSelected = !favBtn.isSelected
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        let bookCollectionRef = userRef.collection("bookCollection")
        
        if bookUser?.key != nil{
            bookCollectionRef.document(bookUser!.key).updateData(["isFav": favBtn.isSelected]) { (error) in
                if let error = error {
                    print("Error updating document: \(error.localizedDescription)")
                }
            }
        }else
        {
            let bookData: [String: Any] = [
                "isFav": true
            ]
            
            let newDocumentRef = bookCollectionRef.document()
            let documentID = newDocumentRef.documentID
            
            newDocumentRef.setData(bookData) { (error) in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                } else {
                    self.bookUser?.key = documentID
                }
            }
        }
    }
    
    
    func isInCollection(id: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        let newDocRef = userRef.collection("bookCollection").whereField("id", isEqualTo: id)
        
        newDocRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            if let document = querySnapshot?.documents.first {
                completion(document.documentID)
            } else {
                completion("")
            }
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

