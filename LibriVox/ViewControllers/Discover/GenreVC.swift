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
    
    @IBOutlet weak var backgroundLabel: RoundView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvBooksByGenre.delegate = self
        tvBooksByGenre.dataSource = self
        
        if let genre = genre{
            guard let id = genre._id, let name = genre.name, let mainColor = genre.mainColor else{
                //TODO: Make an alert to retry, popback to the previous controller
                return
            }
            genreLabel.text = name
            backgroundLabel.backgroundColor = stringToColor(color: String(mainColor.dropFirst()))
            
            DefaultAPI.audiobooksGenregenreGet(genre: name.URLEncoded , format:"json", extended: 1) { data, error in
                if let error = error {
                    print("Error getting root data:", error.localizedDescription)
                    self.spinner.stopAnimating()
                    return
                }
                
                if let data = data {
                    self.audioBooks = data.books ?? []
                    
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.tvBooksByGenre.reloadData()
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
        
        let cell = tvBooksByGenre.dequeueReusableCell(withIdentifier: "AudioBooksTVC", for: indexPath) as! AudioBooksTVC
        
        if let book = audioBooks?[indexPath.row]{
            guard let id = book._id, let title = book.title, let secondaryColor = genre?.secondaryColor?.dropFirst() else{
                return UITableViewCell()
            }
            
            cell.titleAudioBook.text = title
            cell.genresAudioBooks.text! += displayGenres(strings: book.genres ?? [])
            cell.authorAudioBook.text = displayAuthors(authors: book.authors ?? [])
            cell.backgroundAudioBook.backgroundColor = stringToColor(color: String(secondaryColor))
            cell.imgAudioBook.image = nil
            
            if let duration = book.totaltime{
                cell.durationAudioBook.text! = duration
            }
            
            getCoverBook(id: book._id!, url: (book.urlLibrivox!)){img in
                guard let img = img else{
                    //TODO: Generate a book cover
                    return
                }
                cell.imgAudioBook.loadImage(from: img)
            }
        }
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

extension String {
    var URLEncoded:String {
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        let unreservedCharsSet: CharacterSet = CharacterSet(charactersIn: unreservedChars)
        let encodedString = self.addingPercentEncoding(withAllowedCharacters: unreservedCharsSet)!
        return encodedString
    }
}
