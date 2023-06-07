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
    var finalList: [Book] = []
    let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        
        getBooksByParameter("isFav", value: true){ books in
            self.finalList = books
            self.spinner.stopAnimating()
            
            self.tableView.reloadSections([0], with: UITableView.RowAnimation.left)
            checkAndUpdateEmptyState(list: self.finalList, alertImage: UIImage(named: "favoritesBook")!,view: self.tableView, alertText: "No books to display")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCellTVC", for: indexPath) as! FavoritesCellTVC
        
        let book = finalList[indexPath.row].book
        
        cell.favBtn.isSelected = true
        
        cell.titleBook.text = book.title
        cell.authorBook.text = "Author: \(displayAuthors(authors: book.authors ?? []))"
        
        
        if let duration = book.totaltime{
            cell.durationBook.text = "Duration: \(duration)"
        }
        cell.imgBook.image = nil
        /*if let imgUrl = finalList[indexPath.row].imageUrl,let url = URL(string:imgUrl){
            DispatchQueue.main.async
            {
                cell.imgBook.loadImageURL(from: url)
            }
           
        }*/
        if let urlImg = book.urlLibrivox{
            getCoverBook(id: book._id!, url: urlImg){img in
                if let img = img{
                    cell.imgBook.loadImage(from: img)
                }
            }}
        cell.genreBook.text = "Genres: \(displayGenres(strings: book.genres ?? []))"
        
        cell.favBtn.tag = indexPath.row
        cell.favBtn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func click(_ sender: UIButton) {
        let rowIndex = sender.tag
        let book = finalList[rowIndex].book
        
        updateBookParameter("isFav", value: false, documentID: book._id!){sucess in
            if sucess{DispatchQueue.main.async { sender.isSelected = !sender.isSelected}}
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = tableView.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = finalList[indexPath.row].book
        }
    }
}



class FavoritesCellTVC: UITableViewCell {
    
    @IBOutlet weak var genreBook: UILabel!
    @IBOutlet weak var durationBook: UILabel!
    @IBOutlet weak var authorBook: UILabel!
    @IBOutlet weak var imgBook: RoundedBookImageView!
    @IBOutlet weak var favBtn: ToggleBtn!
    @IBOutlet weak var titleBook: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favBtn.isSelected = true
    }
}
