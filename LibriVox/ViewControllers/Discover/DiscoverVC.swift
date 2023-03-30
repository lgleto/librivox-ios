//
//  DiscoverVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 29/03/2023.
//

import UIKit
import SwaggerClient

class DiscoverVC: UIViewController {
    
    var books: [SwaggerClient.Audiobook] = []
    
    @IBOutlet weak var booksCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        booksCV.dataSource = self
        booksCV.delegate = self
        
        //TODO: Show an alert when an error occur
        DefaultAPI.rootGet(format: "json") { data, error in
            if let error = error {
                print("Error getting root data:", error)
                return
            }
            
            if let data = data {
                self.books = data.books ?? []
                print(self.books)
                
                DispatchQueue.main.async {
                    self.booksCV.reloadData()
                }
            }
        }
    }
}

extension DiscoverVC: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = booksCV.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        cell.titleBook.text = books[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowBookDetails", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*  if segue.identifier == "ShowBookDetails", let bookDetailsVC = segue.destination as? BookDetailsVC, let selectedRow = sender as? Int {
            bookDetailsVC.book = books[selectedRow]
        }*/
    }
}
