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
    
    var dataloaded = false
    @IBOutlet weak var authorsCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorsCV.dataSource = self
        authorsCV.delegate = self
        
        let db = Firestore.firestore()
        let genresCollection = db.collection("genres")
        
    
       /* DefaultAPI.author2Get(format: "json"){
            data, error in
            print(data?.authors)
        }*/
        
        genresCollection.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting genres: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let genre = document.data() as! Genre
                    self.genres?.append(genre)
                }
            }
        }
        
        print(genres)
        
        
    }
}

extension DiscoverVC2: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        
        let cell = authorsCV.dequeueReusableCell(withReuseIdentifier: "AuthorsCell", for: indexPath) as! AuthorsCell
    
        cell.nameAuthor.text = genres?[indexPath.row].name
        return cell
    }
    
}

