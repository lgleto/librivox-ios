//
//  ListBooksCell.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 30/03/2023.
//

import UIKit

class ListBooksCell: UICollectionViewCell {
    @IBOutlet weak var background: BlurredImageView!
    @IBOutlet weak var titleBook: UILabel!
    @IBOutlet weak var imageBook: RoundedBookImageView!
    @IBOutlet weak var isFav: ToggleBtn!
}
