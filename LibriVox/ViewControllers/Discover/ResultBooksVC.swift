//
//  DiscoverVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 29/03/2023.
//

import UIKit
import SwaggerClient
import Kingfisher

class ResultBooksVC: UIViewController, DiscoverRealDelegate {
    
    var filteredBooks: [Audiobook] = []
    
    var searchText : String?
    
    @IBOutlet weak var booksCV: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        booksCV.dataSource = self
        booksCV.delegate = self
    }
    
    //TODO: FIX (`-´)
    func applySearchFilter() {
        filteredBooks.removeAll()
        if let text = searchText, !text.isEmpty {
            if let spinner = self.spinner {
                spinner.startAnimating()
            }
            
            DefaultAPI.audiobooksTitletitleGet(title: text, format: "json", extended: 1){data, error in
                if let error = error {
                    print("Error getting root data:", error)
                    self.filteredBooks.removeAll()
                }
                
                if let data = data {
                    self.filteredBooks = data.books ?? []
                }
                
                DispatchQueue.main.async {
                    self.booksCV.reloadData()
                    self.spinner.stopAnimating()
                }
                
            }
        }
    }
    
    public func didChangeSearchText(_ text: String) {
        searchText = text
        applySearchFilter()
    }
}

extension ResultBooksVC: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = booksCV.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        cell.titleBook.text = filteredBooks[indexPath.row].title
        cell.imageBook.image = nil
        getCoverFromBook(url: filteredBooks[indexPath.row].urlLibrivox!){img in
            cell.imageBook.kf.setImage(with: img)
            cell.imageBook.contentMode = .scaleToFill
        }
        
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



