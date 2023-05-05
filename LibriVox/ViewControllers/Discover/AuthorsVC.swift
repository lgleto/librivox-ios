//
//  AuthorsVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 17/04/2023.
//


import UIKit
import SwaggerClient

class AuthorsVC: UIViewController {
    
    var isLoaded = false
    
    @IBOutlet weak var authorsCV: UICollectionView!
    var authors : [Author]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        authorsCV.dataSource = self
        authorsCV.delegate = self
        
        DefaultAPI.authorsGet(format:"json") { data, error in
            if let error = error {
                print("Error getting root data:", error)
                return
            }
            
            if let data = data {
                self.authors = data.authors
                DispatchQueue.main.async {
                    self.isLoaded = true
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
        
        if !isLoaded{ return UICollectionViewCell()}
        else{
            let cell = authorsCV.dequeueReusableCell(withReuseIdentifier: "AuthorProfileCell", for: indexPath) as! AuthorProfileCell
            
            var author = authors?[indexPath.row]
            
            if let author = author{
                getPhotoAuthor(authorId: author._id ?? "0", img: cell.authorPhoto)
                
                cell.nameAuthor.text = (author.firstName ?? "") + " " + (author.lastName ?? " ")
            }
            return cell
            
        }
        
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
