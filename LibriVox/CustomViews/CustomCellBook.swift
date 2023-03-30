//
//  CustomCell.swift
//  LibriVox
//
//  Created by Leandro Silva on 30/03/2023.
//

import Foundation
import UIKit

class CustomCellBook : UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var author: UILabel!
    
    @IBOutlet weak var bookCover: RoundedBookImageView!
    
    @IBOutlet weak var trendingNumber: UILabel!
    
    @IBOutlet weak var genre: UILabel!
    
    @IBOutlet weak var duration: UILabel!
}
