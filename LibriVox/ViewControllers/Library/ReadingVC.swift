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
    
    var finalList: [Audiobook] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBooksFromUser(isReading: true) { audiobooks in
            self.finalList = audiobooks
            self.tableView.reloadData()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingCellTVC", for: indexPath) as! ReadingCellTVC
        
        let book = finalList[indexPath.row]
        
        cell.titleBook.text = book.title
        cell.authorsBook.text = "Author: \(displayAuthors(authors: book.authors ?? []))"
        cell.imgBook.image = nil
        getCoverFromBook(url: book.urlLibrivox!){img in
            cell.imgBook.kf.setImage(with: img)
            cell.imgBook.contentMode = .scaleToFill
        }
        if let duration = book.totaltime{
            cell.durationBook.text = "Duration: \(duration)"
        }
        
        return cell
    }
}
