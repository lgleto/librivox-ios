//
//  DiscoverVC2.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 04/04/2023.
//

import UIKit
import SwaggerClient
import FirebaseFirestore

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
        
        getGenresFromDb(){ genres in
            self.genres = genres
            
            DispatchQueue.main.async {
                self.authorsCV.reloadData()
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
            
            cell.circleBackground.image = imageWith(name: genres?[indexPath.row].name)
            
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
    }
    
    
}



