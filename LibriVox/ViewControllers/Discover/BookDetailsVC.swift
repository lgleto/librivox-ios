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
    
    var book : SwaggerClient.Audiobook?    //var fg: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let book = book {
            descrBook.text = book.title
            authorBook.text = (book.authors?[0].firstName ?? "") + " " + (book.authors?[0].lastName ?? "")
            durationBook.text = book.totaltime
        }
        
        
    }
}
