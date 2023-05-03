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
    var finalList: [Audiobook] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBooksFromUser(isFavorite: true) { audiobooks in
            self.finalList = audiobooks
            self.tableView.reloadData()
        }

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
        cell.imgBook.image = nil
        getCoverBook(url: book.urlLibrivox!){img in
            cell.imgBook.kf.setImage(with: img)
            cell.imgBook.contentMode = .scaleToFill
        }
        cell.genreBook.text = "Genres: \(displayGenres(strings: book.genres ?? []))"
        
        return cell
    }
}
