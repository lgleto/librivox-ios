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

class ReadingVC: UITableViewController,ShowMiniPlayerDelegate {
    func showMiniPlayer() {
        if let tabBarController = tabBarController as? HomepageTBC {
            tabBarController.addChildView()
        }
    }
    
    var finalList: [Audiobook] = []
    let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        getBooksFromUser(field: BookUser.IS_READING,value: true) { audiobooks in
            self.finalList = audiobooks
            self.spinner.stopAnimating()
            
            self.tableView.reloadSections([0], with: UITableView.RowAnimation.left)
            checkAndUpdateEmptyState(list: self.finalList, alertImage: UIImage(named: "readingBook")!,view: self.tableView, alertText: "No books being read")
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
        getCoverBook(id: book._id!, url: book.urlLibrivox!){img in
            if let img = img{
                cell.imgBook.loadImage(from: img)
                
            }
        }
        
        if let duration = book.totaltime{
            cell.durationBook.text = "Duration: \(duration)"
        }
        
        cell.playBtn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        return cell
    }
    @objc func click(_ sender: UIButton) {
        showMiniPlayer()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = tableView.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = finalList[indexPath.row]
        }
    }
}
