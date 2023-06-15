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
import CoreData

class FinishedCVC: UICollectionViewController {
    
    var finalList: [Book] = []
    
    let spinner = UIActivityIndicatorView(style: .medium)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        collectionView.backgroundView = spinner
  
        getBooksByParameter("isFinished", value: true){ books in
            self.finalList = books
            self.spinner.stopAnimating()
            
            var book = books[0]
            
            addBookCD(book: book)
    
            self.collectionView.reloadSections(IndexSet(integer: 0))
            checkAndUpdateEmptyState(list: self.finalList, alertImage: UIImage(named: "completedBook")!,view: self.collectionView, alertText: "No books finished yet")
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        let book = finalList[indexPath.row].book
        cell.titleBook.text = book.title
        cell.imageBook.image = nil
        getCoverBook(id:book._id! ,url: book.urlLibrivox!){img in
            
            if let img = img{
                cell.imageBook.loadImage(from: img)
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = collectionView.indexPathsForSelectedItems?.first,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = finalList[item].book
        }
    }
}



