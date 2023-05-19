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
    var key : String?


    // Usage
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
    

        
        sectionsTV.dataSource = self
        sectionsTV.delegate = self
        
        if let book = book {
            self.title = book.title!
            self.bookUser?.id = book._id!
            
            setData(book: book)
            
            isInCollection(id: book._id!) { result in
                if !result.isEmpty {
                    self.key = result
                    self.isFav(key: self.key!) { isFavorite in
                        DispatchQueue.main.async {
                            self.favBtn.isSelected = isFavorite
                        }
                    }
                    
                }
            }
        }
    }
    
    func setData(book : Audiobook){
        self.getCoverBook(id: book._id!,url: book.urlLibrivox!){
            img in
            if let img = img{
                self.bookImg.loadImage(from: img)
                self.backgroundImage.loadImage(from: img)
            }
        }
        
        let authors = displayAuthors(authors: book.authors ?? [])
        let genres = displayGenres(strings: book.genres ?? [])
        
        durationBook.attributedText = stringFormatted(textBold: "Duration: ", textRegular: book.totaltime ?? "00:00:00", size: 15.0)
        genreBook.attributedText = stringFormatted(textBold: "Genre(s): ", textRegular: genres, size: 15.0)
        authorBook.attributedText = stringFormatted(textBold: "Author(s): ", textRegular: authors, size: 15.0)
        numSectionsBook.attributedText = stringFormatted(textBold: "Nº Sections: ", textRegular: book.numSections ?? "0", size: 15.0)
        languageBook.attributedText = stringFormatted(textBold: "Language: ", textRegular: book.language ?? "Not specified", size: 15.0)
        
        descrBook.text = removeHtmlTagsFromText(text: book._description ?? "No sinopse available")
    }
    
    //Check if already exists
    @IBAction func didClick(_ sender: UIButton) {
        guard let key = key else {
            let bookData: [String: Any] = [
                BookUser.ID: book?._id,
                BookUser.IS_READING: true
            ]
            
            if let bookUser = BookUser(dict: bookData) {
                addToCollection(bookUser)
            }
            return
        }
    }
    
    @IBAction func clickFav(_ sender: Any) {
        let newIsFavValue = !favBtn.isSelected
        
        if let key = key {
            updateIsFavValue(key: key, isFav: newIsFavValue)
        } else {
            addBookToFavorites()
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
    
    
    
    
    
    func isFav(key: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        let bookCollectionRef = userRef.collection("bookCollection").document(key)
        
        bookCollectionRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let document = document, let isFav = document.data()?["isFav"] as? Bool {
                completion(isFav)
            } else {
                completion(false)
            }
        }
    }
    
    func addToCollection(_ book: BookUser) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        let bookCollectionRef = userRef.collection("bookCollection")
        
        let newDocRef = bookCollectionRef.document()
        let documentID = newDocRef.documentID
        
        newDocRef.setData(book.dictionary) { error in
            if let error = error {
                print("Error adding book to collection: \(error.localizedDescription)")
            } else {
                self.key = documentID
                print("Book added to collection with ID: \(newDocRef.documentID)")
            }
        }
    }
    
    func updateIsFavValue(key: String, isFav: Bool) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        let bookCollectionRef = userRef.collection("bookCollection").document(key)
        
        bookCollectionRef.updateData(["isFav": isFav]) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.favBtn.isSelected = isFav
                }
            }
        }
    }
    
    func addBookToFavorites() {
        let bookData: [String: Any] = [
            BookUser.ID: book?._id,
            BookUser.IS_FAV: true
        ]
        
        if let bookUser = BookUser(dict: bookData) {
            addToCollection(bookUser)
            DispatchQueue.main.async {
                self.favBtn.isSelected = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailsToPlayer") {
            let destVC = segue.destination as! PlayerVC
            destVC.book = sender as! Audiobook
        } else if (segue.identifier == "homeToBookDetail"){
            
        }
        
    }
    
    @IBAction func playBookBtn(_ sender: Any) {
        
        performSegue(withIdentifier: "detailsToPlayer", sender: book)
    }
    
    private func getCoverBook(id: String, url: String, _ callback: @escaping (UIImage?) -> Void) {
        if let image = loadImageFromDocumentDirectory(id: id){
            callback(image)
        }else{
            getBookCoverFromURL(url: url){image in
                guard let image = image else{return}
                self.saveImageToDocumentDirectory(id: id, image: image)
                callback(image)
            }
        }
    }
    
    private func saveImageToDocumentDirectory(id: String, image: UIImage) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imgBooksDirectory = documentsDirectory.appendingPathComponent("ImgBooks")

        if !fileManager.fileExists(atPath: imgBooksDirectory.path) {
            do {
                try fileManager.createDirectory(at: imgBooksDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating ImgBooks directory:", error)
                return
            }
        }

        let fileURL = imgBooksDirectory.appendingPathComponent(id)

        if !fileManager.fileExists(atPath: fileURL.path) {
            if let data = image.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fileURL)
                    //print("File saved:", fileURL.path)
                } catch {
                    //print("Error saving file:", error)
                }
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
