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

    var book : SwaggerClient.Audiobook?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(book)
        if let book = book {
                    durationBook.text = book.totaltime ?? ""
                    authorBook.text = book.authors?.first?.firstName ?? ""
                    descrBook.text = book.language ?? ""
                }

    }
}
