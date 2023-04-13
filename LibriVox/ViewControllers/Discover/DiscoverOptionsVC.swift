//
//  DiscoverVC2.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 04/04/2023.
//

import UIKit
import SwaggerClient
import FirebaseFirestore

public struct GenreWithColor{
    
    public var _id: String?
    public var name: String?
    public var mainColor: String?
    public var secondaryColor: String?
}

class DiscoverOptionsVC: UIViewController {
    
    var authors: [Author]?
    var genres: [GenreWithColor]?
    
    @IBOutlet weak var genresCV: UICollectionView!
    @IBOutlet weak var authorsCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorsCV.dataSource = self
        authorsCV.delegate = self
        
        genresCV.dataSource = self
        genresCV.dataSource = self
        
        //addColorToGenre()
        
        let db = Firestore.firestore()
        let genresRef = db.collection("genres")
        
        genresRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                
                let genres = querySnapshot!.documents.compactMap { document -> GenreWithColor? in
                    guard let id = document.data()["id"] as? String,
                          let name = document.data()["name"] as? String,let mainColor = document.data()["mainColor"] as? String,let secondaryColor = document.data()["secondaryColor"] as? String
                    else {
                        print("Invalid data format for document \(document.documentID)")
                        return nil
                    }
                    return GenreWithColor(_id: id, name: name, mainColor: mainColor, secondaryColor: secondaryColor)
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

extension DiscoverOptionsVC: UICollectionViewDataSource, UICollectionViewDelegate{
    
    //TODO: Select only the top genres
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = authorsCV.dequeueReusableCell(withReuseIdentifier: "AuthorsCell", for: indexPath) as! AuthorsCell
        
        switch collectionView.tag {
        case 0:
            cell.nameAuthor.text = genres?[indexPath.row].name
            
            let colorString = genres?[indexPath.row].mainColor!
            cell.circleBackground.backgroundColor = stringToColor(color: String(colorString?.dropFirst() ?? "FFFFFF"))
        case 1:
            cell.nameAuthor.text = authors?[indexPath.row].firstName
        default:
            fatalError("Invalid collection view tag")
        }
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGenreSection",
           let indexPath = authorsCV.indexPathsForSelectedItems?.first,
           let genre = genres?[indexPath.item],
           let genreVC = segue.destination as? GenreVC {
            genreVC.genre = genre
        }
        /*else if segue.identifier == "showAuthorSection",
         let indexPath = genresCV.indexPathsForSelectedItems?.first,
         let genre = genres?[indexPath.item].name,
         let genreVC = segue.destination as? AuthorVC {
         genreVC.genre = genre
         }*/
    }
    
    
}

