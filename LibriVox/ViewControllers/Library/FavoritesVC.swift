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
    var finalList = [Books_Info](){
        didSet {
            self.tableView.reloadSections([0], with: UITableView.RowAnimation.left)
            
            checkAndUpdateEmptyState(list: finalList, alertImage: UIImage(named: "favoritesBook")!,view: self.tableView, alertText: "No books to display")
        }
    }
    let spinner = UIActivityIndicatorView(style: .medium)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func contextDidChange(_ notification: Notification) {
        finalList = fetchBooksByParameterCD(parameter: "isFav", value: true)
        print("size of \(finalList.count)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = spinner
        finalList = fetchBooksByParameterCD(parameter: "isFav", value: true)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let persistentContainer = appDelegate.persistentContainer
            NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: persistentContainer.viewContext)
        }

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
    
        cell.favBtn.tag = indexPath.row
        cell.favBtn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func click(_ sender: UIButton) {
        let rowIndex = sender.tag
        let book = finalList[rowIndex].audioBook_Data
        
        updateBookParameter("isFav", value: false, documentID: (book?.id!)!)
        updateBookInfoParameter(bookInfo: finalList[rowIndex], parameter: "isFav", value: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = tableView.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            
            detailVC.book = convertToAudiobook(audioBookData: finalList[indexPath.row].audioBook_Data!)
            if let imgData = finalList[indexPath.row].audioBook_Data?.image, let img = UIImage(data: imgData) {
                detailVC.img = img
            }
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
