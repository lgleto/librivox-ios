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

class TrendingBooksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        
        cell.bookCover.image = UIImage(named: "28187")
        getCoverBook(url: localBooks[indexPath.row].urlLibrivox!){img in
            cell.bookCover.kf.setImage(with: img)
            DispatchQueue.main.async {
                   cell.bookCover.contentMode = .scaleToFill
               }
        }
        
        cell.trendingNumber.text = "\(indexPath.row+1)."
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        trendingBooksTable.delegate = self
        trendingBooksTable.dataSource = self
        // Do any additional setup after loading the view.
        loadTrending {
            print("sdasda")
            self.trendingBooksTable.reloadData()
            
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    var trending = [Trending]()
    var localBooks = [Audiobook]()
    func addForTrending(  onCompelition : (()->())? = nil ) {
        if let trend = trending.first {
            DefaultAPI.audiobooksIdBookIdGet(bookId: Int64(trend.id)!, format: "json", extended: 1) { data, error in
                print(data!.books![0].title!)
                self.localBooks.append(data!.books![0])
                self.trending.removeFirst()
                self.addForTrending(onCompelition: onCompelition)
            }
        }else {
            print("trending is empty")
            //print(self.localBooks)
            if let c = onCompelition{
                c()
            }
            
        }
    }

    func loadTrending(callback: @escaping ()->() ) {
        let db = Firestore.firestore()
        let booksRef = db.collection("books")
        booksRef.order(by: "trending", descending: true)
        
        booksRef.getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let s = document.data()
                    let book = Trending(dict: s)
                    self.trending.append(book!)
                }
                self.addForTrending() {
                    print("inside loadTrending")
                    callback()
                }
                
                
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




