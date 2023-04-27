//
//  ReadingVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 26/04/2023.
//

import UIKit

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwaggerClient

class ReadingVC: UITableViewController {
    var books: [BookUser] = []
    var audioBooks: [Audiobook] = []
    var finalList: [Audiobook] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBooks()
        
        //MARK:
        //Which one is better
        // 1. Search by request the books one by one USING NOW
        // 2. Store all the books in an array then compare with the books in the Fb, create a new array with these info and display it.    CURRENTLY APRROACH (NOT IN USE ANYMORE)
        
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingCellTVC", for: indexPath) as! ReadingCellTVC
        
        let book = finalList[indexPath.row]
        
        cell.titleBook.text = book.title
        cell.authorsBook.text = "Author: \(displayAuthors(authors: book.authors ?? []))"
        
        if let duration = book.totaltime{
            cell.durationBook.text = "Duration: \(duration)"
        }
        
        
        return cell
    }
    
    func getBooks() {
        var isLoaded = false
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
                    self.books.append(book)
                    print(book.id)
                    
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
