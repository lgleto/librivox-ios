//
//  FavoritesVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/04/2023.
//

import UIKit
import SwaggerClient
import FirebaseFirestore
import FirebaseAuth

class FavoritesVC: UITableViewController {

    var books: [BookUser] = []
    var audioBooks: [Audiobook] = []
    var finalList: [Audiobook] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBooks()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCellTVC", for: indexPath) as! FavoritesCellTVC
        
        let book = finalList[indexPath.row]
        
        cell.titleBook.text = book.title
        cell.authorBook.text = "Author: \(displayAuthors(authors: book.authors ?? []))"
        
        if let duration = book.totaltime{
            cell.durationBook.text = "Duration: \(duration)"
        }
        
        cell.genreBook.text = "Genres: \(displayGenres(strings: book.genres ?? []))"
        
        return cell
    }
    
    func getBooks() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        let bookCollectionRef = userRef.collection("bookCollection")
        
        bookCollectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            for document in documents {
                if let book = BookUser(data: document.data()) {
                    
                    if book.isFav ?? false{
                        self.books.append(book)
                        DefaultAPI.audiobooksIdBookIdGet(bookId: Int64(book.id)!, format: "json", extended: 1) { data, error in
                            if let error = error {
                                print("Error getting root data:", error)
                                return
                            }
                            if let data = data {
                                self.finalList.append(contentsOf: data.books!)
                                print(data)
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }

}
