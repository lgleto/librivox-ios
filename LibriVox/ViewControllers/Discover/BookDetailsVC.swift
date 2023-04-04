//
//  BookDetailsVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 30/03/2023.
//

import UIKit
import SwaggerClient

class BookDetailsVC: UIViewController {
    
    @IBOutlet weak var bookImg: RoundedBookImageView!
    @IBOutlet weak var durationBook: UILabel!
    @IBOutlet weak var genreBook: UILabel!
    @IBOutlet weak var authorBook: UILabel!
    @IBOutlet weak var numSectionsBook: UILabel!
    @IBOutlet weak var descrBook: UILabel!
    @IBOutlet weak var sectionsTV: UITableView!
    @IBOutlet weak var backgroundImage: BlurredImageView!
    var book: Audiobook?
    var sections: [SwaggerClient.Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionsTV.dataSource = self
        sectionsTV.delegate = self
        
        if let book = book {
            descrBook.text = removeHtmlTagsFromText(text: book._description ?? "")
            numSectionsBook.text = book.numSections
            genreBook.text = displayGenres(strings: book.genres ?? [])
            authorBook.text = (book.authors?[0].firstName ?? "") + " " + (book.authors?[0].lastName ?? "")
            durationBook.text = book.totaltime
        }
    }
}

extension BookDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sectionsTV.dequeueReusableCell(withIdentifier: "SectionsCell", for: indexPath) as! SectionsCell
        let section = book?.sections?[indexPath.row]
        
        let seconds = Int(section?.playtime ?? "Not found") ?? 0
       
        cell.titleSection.text = section?.title
        cell.durationSection.text! = "Duration: \(secondsToMinutes(seconds: seconds))min "
        return cell
    }
}

