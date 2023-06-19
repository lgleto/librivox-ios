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
    //var finalList: [Book] = []
    var finalList = [Books_Info]()
    let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        finalList = fetchBooksByParameterCD(parameter: "isFav", value: true)
        spinner.stopAnimating()
        
        self.tableView.reloadSections([0], with: UITableView.RowAnimation.fade)
        checkAndUpdateEmptyState(list: self.finalList, alertImage: UIImage(named: "favoritesBook")!,view: self.tableView, alertText: "No books to display")

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCellTVC", for: indexPath) as! FavoritesCellTVC
        
        let book = finalList[indexPath.row].audioBook_Data
        
        cell.favBtn.isSelected = true
        
        cell.titleBook.text = book?.title
        cell.authorBook.text = "Author: \(book?.authors)"
        cell.genreBook.text = "Genre: "
        cell.imgBook.image = nil
        
        if let imgData = book?.image, let img = UIImage(data: imgData) {
                cell.imgBook.loadImage(from: img)
        }
        cell.durationBook.text = "Duration: \(book?.totalTime)"
        
        /*cell.titleBook.text = book.title
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
        cell.genreBook.text = "Genres: \(displayGenres(strings: book.genres ?? []))"*/
        
        cell.favBtn.tag = indexPath.row
        cell.favBtn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func click(_ sender: UIButton) {
        let rowIndex = sender.tag
        let book = finalList[rowIndex].audioBook_Data
        
        
        updateBookParameter("isFav", value: false, documentID: (book?.id!)!)
        updateBookInfoParameter(bookInfo: finalList[rowIndex], parameter: "isFav", value: false)
        finalList.remove(at: rowIndex)
        
        tableView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .fade)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = tableView.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            
            detailVC.book = convertToAudiobook(audioBookData: finalList[indexPath.row].audioBook_Data!)
            if let imgData = finalList[indexPath.row].audioBook_Data?.image, let img = UIImage(data: imgData) {
                detailVC.img = img
            }
           // detailVC.book = finalList[indexPath.row].book
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
