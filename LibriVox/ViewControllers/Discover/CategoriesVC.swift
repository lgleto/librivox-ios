//
//  CategoriesVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 12/04/2023.
//

import UIKit
import FirebaseFirestore

class CategoriesVC: UIViewController {
    
    var genres: [GenreWithColor]?
    var isLoaded = false
    
    @IBOutlet weak var categoriesTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriesTV.dataSource = self
        categoriesTV.delegate = self
        
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
                    self.categoriesTV.reloadData()
                    self.isLoaded = true
                }
            }
        }
        
        
    }
}
extension CategoriesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !isLoaded{
            return UITableViewCell()
        }else{
            let cell = categoriesTV.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
            
            if let genre = genres?[indexPath.row]{
                cell.nameCategory.text = genre.name
                cell.backGroundCategory.backgroundColor = stringToColor(color: String(genre.mainColor?.dropFirst() ?? "FFFFFF"))
            }
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGenreSection",
           let indexPath = categoriesTV.indexPathForSelectedRow,
           let genre = genres?[indexPath.item],
           let genreVC = segue.destination as? GenreVC {
            genreVC.genre = genre
        }
    }
}
