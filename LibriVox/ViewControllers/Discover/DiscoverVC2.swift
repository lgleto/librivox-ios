//
//  DiscoverVC2.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 04/04/2023.
//

import UIKit
import SwaggerClient
import FirebaseFirestore

class DiscoverVC2: UIViewController {
    
    var authors: [Author]?
    var genres: [Genre]?
    
    @IBOutlet weak var genresCV: UICollectionView!
    @IBOutlet weak var authorsCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorsCV.dataSource = self
        authorsCV.delegate = self
        
        genresCV.dataSource = self
        genresCV.dataSource = self
        
        let db = Firestore.firestore()
        let genresRef = db.collection("genres")
        
        genresRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                
                let genres = querySnapshot!.documents.compactMap { document -> Genre? in
                    guard let id = document.data()["id"] as? String,
                          let name = document.data()["name"] as? String else {
                        print("Invalid data format for document \(document.documentID)")
                        return nil
                    }
                    return Genre(_id: id, name: name)
                }
                
                self.genres = genres
                
                DispatchQueue.main.async {
                    self.authorsCV.reloadData()
                }
                
            }
        }
        
        
        DefaultAPI.authorsGet(format:"json") { data, error in
            if let error = error {
                print("Error getting root data:", error)
                return
            }
            
            if let data = data {
                self.authors = data.authors
                DispatchQueue.main.async {
                    self.genresCV.reloadData()
                }
            }
        }
    }
}

extension DiscoverVC2: UICollectionViewDataSource, UICollectionViewDelegate{
    
    //TODO: Select only the top genres
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = authorsCV.dequeueReusableCell(withReuseIdentifier: "AuthorsCell", for: indexPath) as! AuthorsCell
        
        switch collectionView.tag {
        case 0:
            cell.nameAuthor.text = genres?[indexPath.row].name
        case 1:
            cell.nameAuthor.text = authors?[indexPath.row].firstName
        default:
            fatalError("Invalid collection view tag")
        }
        
        return cell
    }
    
}

