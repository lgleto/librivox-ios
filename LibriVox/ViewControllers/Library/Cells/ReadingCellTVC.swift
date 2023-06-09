//
//  ReadingCellTVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/04/2023.
//

import UIKit

class ReadingCellTVC: UITableViewCell {
    
    @IBOutlet weak var imgBook: RoundedBookImageView!
    
    @IBOutlet weak var titleBook: UILabel!
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var playBtn: ToggleBtn!
    @IBOutlet weak var durationBook: UILabel!
    @IBOutlet weak var authorsBook: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progress.transform = progress.transform.scaledBy(x: 1, y:0.6)
    }

    /*override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }*/

}
