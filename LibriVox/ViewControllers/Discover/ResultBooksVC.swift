//
//  DiscoverVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 29/03/2023.
//

import UIKit
import SwaggerClient

class ResultBooksVC: UIViewController, DiscoverRealDelegate {
    
    var filteredBooks: [SwaggerClient.Audiobook] = []
    var books: [SwaggerClient.Audiobook] = []
    var isLoaded = false
    
    @IBOutlet weak var booksCV: UICollectionView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        booksCV.dataSource = self
        booksCV.delegate = self
        
        
        //TODO: Show an alert when an error occur
        DefaultAPI.audiobooksGet(format: "json",extended: 1) { data, error in
            if let error = error {
                print("Error getting root data:", error)
                return
            }
            
            if let data = data {
                self.books = data.books ?? []
                
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.isLoaded = true
                }
            }
        }
    }
    
    
    //FIXME: Working but the data need to be loaded first
    public func didChangeSearchText(_ text: String) {
        if isLoaded{
            if !text.isEmpty {
                filteredBooks = books.filter { $0.title?.range(of: text, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
            } else {
                print("Any book has been found")
            }
            booksCV.reloadData()
        }
        else{return}
        
    }
}
extension ResultBooksVC: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = booksCV.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        cell.titleBook.text = filteredBooks[indexPath.row].title
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsPage", let indexPath = booksCV.indexPathsForSelectedItems?.first,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = filteredBooks[item]
        }
    }
}



