//
//  FinishedCVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/04/2023.
//

import UIKit
import SwaggerClient
import FirebaseFirestore
import FirebaseAuth

class FinishedCVC: UICollectionViewController {

    var books: [BookUser] = []
    var audioBooks: [Audiobook] = []
    var finalList: [Audiobook] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBooks()
        // Do any additional setup after loading the view.
    }



    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        cell.titleBook.text = finalList[indexPath.row].title
       // cell.onFavToggle()
        
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
                    
                    if book.isReading ?? false{
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
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    

}
