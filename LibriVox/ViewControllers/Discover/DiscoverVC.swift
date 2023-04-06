//
//  DiscoverVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 29/03/2023.
//

import UIKit
import SwaggerClient

class DiscoverVC: UIViewController, DiscoverRealDelegate {
    
    var filteredBooks: [SwaggerClient.Audiobook] = []
    
    var books: [SwaggerClient.Audiobook] = []
    
    
    @IBOutlet weak var booksCV: UICollectionView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        booksCV.dataSource = self
        booksCV.delegate = self
        
        if let discoverRealVC = navigationController?.viewControllers.first(where: { $0 is DiscoverRealVC }) as? DiscoverRealVC {
            discoverRealVC.delegate = self
        }
        
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
                }
            }
        }
    }
    
    func didChangeSearchText(_ text: String) {
        print("entrou aqui")
        if !text.isEmpty {
            filteredBooks = books.filter { $0.title?.range(of: text, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
        } else {
            filteredBooks = books
        }
        booksCV.reloadData()
    }
}
extension DiscoverVC: UICollectionViewDataSource, UICollectionViewDelegate{
    
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



