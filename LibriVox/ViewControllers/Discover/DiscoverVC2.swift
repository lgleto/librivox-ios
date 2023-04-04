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
                    let genre = document.data()["name"] as! String
                    print("Genre: \(genre)")
                }
            }
        }
        
        
        DefaultAPI.rootGet(format: "json",extended: 1) { data, error in
            if let error = error {
                print("Error getting root data:", error)
                return
            }
            
            if let data = data {
                self.genres = extractGenres(from: data.books  ?? [])
                self.dataloaded = true
            }
        }
    }
}

func extractGenres(from books: [Audiobook]) -> [Genre] {
    let initial: [Genre] = []
    
    let genres = books.reduce(into: initial) { result, book in
        if let bookGenres = book.genres {
            for genre in bookGenres {
                if !result.contains(where: { $0.name == genre.name }) {
                    result.append(genre)
                }
            }
         
        }
    }
    return genres
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

