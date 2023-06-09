//
//  CategoriesVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 12/04/2023.
//

import UIKit
import FirebaseFirestore

class CategoriesVC: AdaptedVC {
    
    var genres: [GenreWithColor]?
    var isLoaded = false
    
    @IBOutlet weak var categoriesTV: UITableView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriesTV.dataSource = self
        categoriesTV.delegate = self
        
        getGenresFromDb(){ genres in
            self.genres = genres
            
            DispatchQueue.main.async {
                self.categoriesTV.reloadData()
            }
        }
    }
}

extension CategoriesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = categoriesTV.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
        
        if let genre = genres?[indexPath.row]{
            guard let id = genre._id, let name = genre.name, let mainColor = genre.mainColor?.dropFirst()else{
                return UITableViewCell()
            }
            
            cell.nameCategory.text = name
            cell.backGroundCategory.backgroundColor = stringToColor(color: String(mainColor))
            cell.descriptionCategory.text = genre.descr
           
            cell.backGroundCategory.loadImage(from: imageWith(name: name)!)
        }
        
        return cell
        
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
