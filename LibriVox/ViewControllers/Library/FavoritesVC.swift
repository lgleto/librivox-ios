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
    
    private func checkAndUpdateEmptyState() {
            if finalList.isEmpty {
                let alertImage = UIImage(named: "favoritesBook")
                let alertText = "No books to display."
                setImageNLabelAlert(view: tableView, img: alertImage!, text: alertText)
            }
        }
    
    var finalList: [Audiobook] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBooksFromUser(field: BookUser.IS_FAV, value: true) { audiobooks in
            if audiobooks.isEmpty{
                let alertImage = UIImage(named: "favoritesBook")
                let alertText = "No book to start reading"
                setImageNLabelAlert(view: self.tableView, img: alertImage!, text: alertText)
            }
            else{
                self.finalList = audiobooks
                self.tableView.reloadData()
            }
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
        getCoverBook(url: book.urlLibrivox!){img in
            
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
                    } else {
                        self.finalList.remove(at: rowIndex)
                        let indexPath = IndexPath(item: rowIndex, section: 0)
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                        self.checkAndUpdateEmptyState()
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
    
    @IBAction func click(_ sender: Any) {
        
    }
    
    
}
