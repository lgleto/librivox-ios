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
    
    
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var showMoreBtn: UIButton!
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
    
    private var rowsToBeShow:Int?
    
    private func syncPlayPauseButton() {
        guard let id = book?._id else {
            return
        }
        
        /*if let currentAudiobookID = MiniPlayerManager.shared.currentAudiobookID,currentAudiobookID == id {
         playBtn.isSelected = MiniPlayerManager.shared.isPlaying
         }*/
    }
    
    @objc func miniPlayerDidUpdatePlayState(_ notification: Notification) {
        
        
        
        
        guard let userInfo = notification.userInfo,
              let isPlaying = userInfo["state"] as? Bool else {return}
        playBtn.isSelected = isPlaying
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = book?._id, let currentAudiobookID = MiniPlayerManager.shared.currentAudiobookID,currentAudiobookID == id {
            NotificationCenter.default.addObserver(self, selector: #selector(miniPlayerDidUpdatePlayState(_:)), name: Notification.Name("miniPlayerState"), object: nil)
        }
        
        sectionsTV.dataSource = self
        sectionsTV.delegate = self
        
        showMoreBtn.setTitle("Show all", for: .normal)
        showMoreBtn.setTitle("Hide all", for: .selected)
        
        sectionsTV.alwaysBounceVertical = false
        
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
    
    @IBAction func clickShowMore(_ sender: Any) {
        showMoreBtn.isSelected = !showMoreBtn.isSelected
        
        sectionsTV.reloadData()
    }
    
    func setData(book : Audiobook){
        getCoverBook(id: book._id!,url: book.urlLibrivox!){
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
        playBtn.isSelected = !playBtn.isSelected
        performSegue(withIdentifier: "detailsToPlayer", sender: book)
    }
    
}

extension BookDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionsNum = book?.sections?.count else{return 0}
        
        let showAllRows = showMoreBtn.isSelected
        switch sectionsNum{
        case ..<20:
            rowsToBeShow =  showAllRows ?  sectionsNum : sectionsNum / 2
        case 20..<50:
            rowsToBeShow = showAllRows ?  sectionsNum : sectionsNum / 3
        default:
            rowsToBeShow = showAllRows ? sectionsNum : 30
        }
        
        heightConstant.constant = CGFloat(Double(rowsToBeShow!) * 80)
        return rowsToBeShow!
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
