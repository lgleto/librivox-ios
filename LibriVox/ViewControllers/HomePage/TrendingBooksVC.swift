//
//  TrendingBooksVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 17/04/2023.
//

import UIKit
import SwaggerClient
import FirebaseCore
import FirebaseFirestore

class TrendingBooksVC: AdaptedVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var trendingBooksTable: UITableView!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "homeToBookDetail", sender: localBooks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellBook
        cell.selectionStyle = .none
        var authorsString = "Authors: "
        var genreString = "Genre: "
        cell.title.text = self.localBooks[indexPath.row].title
        if (self.localBooks.count > 1) {
            cell.author.text = "Author: \(self.localBooks[indexPath.row].authors![0].firstName!) \(self.localBooks[indexPath.row].authors![0].lastName!)"
        } else {
            for author_ in self.localBooks[indexPath.row].authors! {
                if (authorsString == "Authors: ") {
                    authorsString += "\(author_.firstName!) \(author_.lastName!)"
                } else {
                    authorsString += ", \(author_.firstName!) \(author_.lastName!) "
                }
                
            }
            cell.author.text = authorsString
        }

        
        cell.duration.text = "Duration: \(self.localBooks[indexPath.row].totaltime!)"
        
        for genre_ in self.localBooks[indexPath.row].genres! {
            genreString += "\(genre_.name!), "
        }
        
        cell.genre.text = "Genre: \(self.localBooks[indexPath.row].genres![0].name!)"
        
        cell.bookCover.image = nil
        getCoverBook(id: localBooks[indexPath.row]._id!, url: localBooks[indexPath.row].urlLibrivox!){img in
            guard let img = img else{//TODO: generete a cover
                return
            }
            cell.bookCover.loadImage(from: img)
           
        }
        
        cell.trendingNumber.text = "\(indexPath.row+1)."
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        trendingBooksTable.delegate = self
        trendingBooksTable.dataSource = self
        // Do any additional setup after loading the view.
        //activityIndicator.hidesWhenStopped = true
        //activityIndicator.startAnimating()
        
        loadTrending {
            self.trendingBooksTable.reloadData()
           // self.activityIndicator.stopAnimating()
        }
        
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var localBooks = [Audiobook]()
    func loadTrending(callback: @escaping ()->() ){
        let db = Firestore.firestore()
        let booksRef = db.collection("books")
        let trendingLvl = booksRef.order(by: "trending", descending: false)

        trendingLvl.getDocuments{ querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
                let alert = UIAlertController(title: "Error getting Trending", message: "Error getting the trending books, probably due to slow internet connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                    switch action.style{
                    case .default: break
                        //self.IndicatorView.startAnimating()
                        //self.checkWifi()
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    @unknown default:
                        print("this wasnt suposed to happen")
                    }
                }))
                //self.IndicatorView.stopAnimating()
                self.present(alert, animated: true, completion: nil)
                
            } else {
                for document in querySnapshot!.documents {
                    let s = document.data()
                    let book = Audiobook(dict: s)
                    self.localBooks.append(book)
                    //removeImageNLabelAlert(view: self.trendingBooks)
                }
                callback()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomepageToTrendingBooks") {
            
        } else if (segue.identifier == "homeToBookDetail"){
            let destVC = segue.destination as! BookDetailsVC
            destVC.book = sender as? Audiobook
        }
        
    }
}




