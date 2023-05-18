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
    let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        getBooksFromUser(field: BookUser.IS_FAV, value: true) { audiobooks in
            self.finalList = audiobooks
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
        
        let book = finalList[indexPath.row]
        
        cell.favBtn.isSelected = true
        
        cell.titleBook.text = book.title
        cell.authorBook.text = "Author: \(displayAuthors(authors: book.authors ?? []))"
        
        
        if let duration = book.totaltime{
            cell.durationBook.text = "Duration: \(duration)"
        }
        cell.imgBook.image = nil
        getCoverBook(id: book._id!, url: book.urlLibrivox!){img in
            
            if let img = img{
                cell.imgBook.loadImage(from: img)
            }
        }
        cell.genreBook.text = "Genres: \(displayGenres(strings: book.genres ?? []))"
        
        cell.favBtn.tag = indexPath.row
        cell.favBtn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func click(_ sender: UIButton) {
        let rowIndex = sender.tag
        let book = finalList[rowIndex]
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        let bookCollectionRef = userRef.collection("bookCollection").whereField("id", isEqualTo: book._id)
        
        bookCollectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error retrieving book collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No matching documents found.")
                return
            }
            
            for document in documents {
                let docRef = userRef.collection("bookCollection").document(document.documentID)
                docRef.updateData([BookUser.IS_FAV: false]) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = tableView.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = finalList[indexPath.row]
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
