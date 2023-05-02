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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBooksFromUser(isReading: false) { audiobooks in
            self.finalList = audiobooks
            self.collectionView.reloadData()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        cell.titleBook.text = finalList[indexPath.row].title
        cell.imageBook.image = nil
        getCoverFromBook(url: finalList[indexPath.row].urlLibrivox!){img in
            cell.imageBook.kf.setImage(with: img)
            cell.imageBook.contentMode = .scaleToFill
        }
        
        return cell
    }
}
