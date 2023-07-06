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

class FinishedCVC: UITableViewController {
    
    var finalList = [AudioBooks_Data](){
        didSet {
            self.tableView.reloadSections([0], with: UITableView.RowAnimation.left)
            
            checkAndUpdateEmptyState(list: finalList, alertImage: UIImage(named: "completedBook")!,view: self.tableView, alertText: "Any books finished yet")
        }
    }
    let spinner = UIActivityIndicatorView(style: .medium)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        finalList = fetchBooksByParameterCD(parameter: "isFinished", value: true)

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCellTVC", for: indexPath) as! FavoritesCellTVC
        
        let book = finalList[indexPath.row]
        
        if let title = book.title{
            cell.titleBook.text = book.title
            cell.authorBook.text = "Author: \(book.authors ?? "")"
            cell.genreBook.text = "Genre: \(book.genres ?? "")"
            
        }
        
        cell.imgBook.image = nil

        if let img = loadImageFromDocumentDirectory(id: book.id!){
            cell.imgBook.loadImage(from: img)
        }
        cell.durationBook.text = "Duration: \(book.totalTime ?? "")"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = tableView.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            
            detailVC.book = convertToAudiobook(audioBookData: finalList[indexPath.row])
            
            if let img = loadImageFromDocumentDirectory(id: finalList[indexPath.row].id!) {
                      detailVC.img = img
            }
        }
    }
}



