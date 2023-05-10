//
//  DiscoverVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 29/03/2023.
//

import UIKit
import SwaggerClient
import Kingfisher
import Alamofire

class ResultBooksVC: UIViewController, DiscoverRealDelegate {
    
    var filteredBooks: [Audiobook] = []
    
    private var timer: Timer?
    private let searchDelay = 0.5

    @IBOutlet weak var booksCV: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        filteredBooks = []
        booksCV.reloadData()
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        booksCV.dataSource = self
        booksCV.delegate = self
    }
    
    public func didChangeSearchText(_ text: String) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: searchDelay, repeats: false) { _ in
            self.applySearchFilter(text)
            print("didChange executou \(text)")
            
        }
    }
    
    //TODO: FIX (`-´) ele continua mesmo se mudo para o outro controller
    func applySearchFilter(_ text: String) {
        filteredBooks = []
        removeImageNLabelAlert(view: booksCV)
        if !text.isEmpty {
            if let spinner = self.spinner {
                spinner.startAnimating()
            }
            
             DefaultAPI.audiobooksTitletitleGet(title: text, format: "json", extended: 1) { data, error in
                if let error = error {
                    print("Error getting root data:", error)
                    
                    let alertImage = UIImage(named: "notFound")
                    let alertText = "No data available"
                    setImageNLabelAlert(view: self.booksCV, img: alertImage!, text: alertText)
                }
                
                print("executou com \(text)")
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
}

extension ResultBooksVC: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredBooks.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = booksCV.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        cell.titleBook.text = filteredBooks[indexPath.row].title
        cell.imageBook.image = nil
        getCoverBook(url: filteredBooks[indexPath.row].urlLibrivox!){img in
            if let img = img{
                cell.imageBook.loadImage(from: img)
                cell.background.kf.setImage(with: img)
            }
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

