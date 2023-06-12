//
//  AuthorsVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 17/04/2023.
//


import UIKit
import SwaggerClient

class AuthorsVC: AdaptedVC {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var authorsCV: UICollectionView!
    var authors : [Author]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        authorsCV.dataSource = self
        authorsCV.delegate = self
        
        DefaultAPI.authorsGet(format:"json") { data, error in
            if let error = error {
                self.spinner.stopAnimating()
                print("Error getting root data:", error)
                return
            }
            
            if let data = data {
                self.authors = data.authors
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.authorsCV.reloadData()
                }
            }
        }
        
    }
}


extension AuthorsVC: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return authors?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = authorsCV.dequeueReusableCell(withReuseIdentifier: "AuthorProfileCell", for: indexPath) as! AuthorProfileCell
        
        if let author = authors?[indexPath.row]{
            let name = "\(author.firstName ?? "") \(author.lastName ?? "")"
            
            guard let id = author._id, !name.isEmpty else {
                return UICollectionViewCell()
            }
            
            cell.nameAuthor.text = name
            cell.authorPhoto.image = nil
            
            getPhotoAuthor(authorId: id){img in
                if let img = img{
                    cell.authorPhoto.loadImage(from: img)
                }
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAuthor",
           let indexPath = authorsCV.indexPathsForSelectedItems?.first,
           let author = authors?[indexPath.row],
           let authorPageVC = segue.destination as? AuthorPageVC {
            authorPageVC.author = author
        }
    }
}
