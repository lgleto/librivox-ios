//
//  GenreVCV.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 12/04/2023.
//

import UIKit
import SwaggerClient

class GenreVC: UIViewController {
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var tvBooksByGenre: UITableView!
    
    var genre:GenreWithColor?
    var audioBooks: [Audiobook]?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var isLoaded = false
    @IBOutlet weak var backgroundLabel: RoundedBookImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvBooksByGenre.delegate = self
        tvBooksByGenre.dataSource = self
        
        if let genre = genre{
            genreLabel.text = genre.name
            
            let mainColor = genre.mainColor
            backgroundLabel.backgroundColor = stringToColor(color: String(mainColor?.dropFirst() ?? "FFFFFF"))
            
            
            DefaultAPI.audiobooksGenregenreGet(genre: genre.name! , format:"json", extended: 1) { data, error in
                if let error = error {
                    print("Error getting root data:", error.localizedDescription)
                    return
                }
                
                if let data = data {
                    self.audioBooks = data.books ?? []
                    
                    DispatchQueue.main.async {
                        
                        self.spinner.stopAnimating()
                        self.tvBooksByGenre.reloadData()
                        self.isLoaded = true
                    }
                }
            }
        }
        
        
    }
}


extension GenreVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioBooks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !isLoaded{ return UITableViewCell() }
        else{
            let cell = tvBooksByGenre.dequeueReusableCell(withIdentifier: "AudioBooksTVC", for: indexPath) as! AudioBooksTVC
            
            let book = audioBooks?[indexPath.row]
            
            cell.titleAudioBook.text = book?.title
            if let duration = book?.totaltime{
                cell.durationAudioBook.text! = duration
            }
            cell.genresAudioBooks.text! += displayGenres(strings: book?.genres ?? [])
            cell.authorAudioBook.text! += displayAuthors(authors: book?.authors ?? [])
            cell.backgroundAudioBook.backgroundColor = stringToColor(color: String(genre?.secondaryColor?.dropFirst() ?? "FFFFFF"))
            cell.imgAudioBook.image = nil

    
            getCoverBook(url: (book?.urlLibrivox!)!){img in
                cell.imgAudioBook.kf.setImage(with: img)
            }
            
            return cell
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsPage2", let indexPath = tvBooksByGenre.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = audioBooks![item]
        }
    }
}

