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
    
    var genre:String?
    var audioBooks: [Audiobook]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvBooksByGenre.delegate = self
        tvBooksByGenre.dataSource = self
        
        if let genre = genre{
            genreLabel.text = genre
        }
        
        
        DefaultAPI.audiobooksGenregenreGet(genre: genre!, format:"json", extended: 1) { data, error in
            if let error = error {
                print("Error getting root data:", error)
                return
            }
            
            if let data = data {
                self.audioBooks = data.books ?? []
                
                DispatchQueue.main.async {
                    self.tvBooksByGenre.reloadData()
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
        let cell = tvBooksByGenre.dequeueReusableCell(withIdentifier: "AudioBooksTVC", for: indexPath) as! AudioBooksTVC
        let book = audioBooks?[indexPath.row]
        
        //let seconds = Int(book?.playtime ?? "Not found") ?? 0
        
        cell.titleAudioBook.text = book?.title
        // cell.durationAudioBook.text! = "Duration: \(secondsToMinutes(seconds: seconds))min "
        cell.genresAudioBooks.text! += displayGenres(strings: book?.genres ?? [])
        cell.authorAudioBook.text! += displayAuthors(authors: book?.authors ?? [])
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsPage2", let indexPath = tvBooksByGenre.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = audioBooks![item]
        }
    }
    
}

