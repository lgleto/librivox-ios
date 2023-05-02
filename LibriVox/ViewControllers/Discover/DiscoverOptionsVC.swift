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
            
            cell.circleBackground.backgroundColor = .black
            if let author = authors?[indexPath.row] {
                let firstName = author.firstName ?? "Unknown"
                let lastName = author.lastName ?? "Author"
                
                cell.nameAuthor.text = "\(firstName) \(lastName)"
                
            }
            
            return cell
        default:
            fatalError("Invalid collection view tag")
        }
    }
    
    func getCoverArtUrl(from bookPageLink: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: bookPageLink) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  error == nil,
                  let html = String(data: data, encoding: .utf8),
                  let range = html.range(of: "<a>Download Cover Art</a>") else {
                completion(nil)
                return
            }

            let startIndex = range.lowerBound
            let substring = String(html[startIndex...])

            if let startRange = substring.range(of: "https://"),
               let endRange = substring[startRange.upperBound...].range(of: ".jpg") {
                let coverArtUrl = String(substring[startRange.lowerBound..<endRange.upperBound])
                print("\(coverArtUrl) aiii daddyy")
                completion(coverArtUrl)
            } else {
                completion(nil)
            }
        }

        task.resume()
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



