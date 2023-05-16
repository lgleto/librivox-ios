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
    
    var finalList: [Audiobook] = []
    
    let spinner = UIActivityIndicatorView(style: .medium)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        collectionView.backgroundView = spinner
        
        getBooksFromUser(field: BookUser.IS_READING, value: false) { audiobooks in
            self.finalList = audiobooks
            self.spinner.stopAnimating()
            
            self.collectionView.reloadSections(IndexSet(integer: 0))
            checkAndUpdateEmptyState(list: self.finalList, alertImage: UIImage(named: "completedBook")!,view: self.collectionView, alertText: "No books finished yet")
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        cell.titleBook.text = finalList[indexPath.row].title
        cell.imageBook.image = nil
        getCoverBook(url: finalList[indexPath.row].urlLibrivox!){img in
            
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
            detailVC.book = finalList[item]
        }
    }
}
