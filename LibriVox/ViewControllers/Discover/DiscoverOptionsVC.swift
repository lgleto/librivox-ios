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
        
       genresCV.dataSource = self
        genresCV.delegate = self
        
        authorsCV.dataSource = self
        authorsCV.delegate = self
        
        getGenresFromDb(){ genres in
            self.genres = genres
            
            DispatchQueue.main.async {
              self.genresCV.reloadData()
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
                    self.authorsCV.reloadData()
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
        
        switch collectionView.tag {
        case 0:
            let cell = genresCV.dequeueReusableCell(withReuseIdentifier: "AuthorsCell", for: indexPath) as! AuthorsCell
            
            cell.nameAuthor.text = genres?[indexPath.row].name
            let colorString = genres?[indexPath.row].mainColor!
            cell.circleBackground.backgroundColor = stringToColor(color: String(colorString?.dropFirst() ?? "FFFFFF"))
            cell.circleBackground.image = imageWith(name: genres?[indexPath.row].name)
           
            return cell
            
        case 1:
            let cell = authorsCV.dequeueReusableCell(withReuseIdentifier: "AuthorsCell2", for: indexPath) as! AuthorsCell
        
            if let author = authors?[indexPath.row] {
                let firstName = author.firstName ?? "Unknown"
                let lastName = author.lastName ?? "Author"
                
                cell.circleBackground.image = nil
                cell.nameAuthor.text = "\(firstName) \(lastName)"
                
                if let id = author._id{
                    getPhotoAuthor(authorId: id){img in
                        if let img = img{
                            cell.circleBackground.kf.setImage(with: img)
                        }
                        else{
                            cell.circleBackground.image = imageWith(name: author.firstName)
                        }
                    }
                }
            }
            
            return cell
        default:
            fatalError("Invalid collection view tag")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGenreSection",
           let indexPath = genresCV.indexPathsForSelectedItems?.first,
           let genre = genres?[indexPath.item],
           let genreVC = segue.destination as? GenreVC {
            genreVC.genre = genre
        }
        else if segue.identifier == "showAuthor",
           let indexPath = authorsCV.indexPathsForSelectedItems?.first,
           let author = authors?[indexPath.row],
           let authorPageVC = segue.destination as? AuthorPageVC {
            authorPageVC.author = author
        }
    }
    
    
}



