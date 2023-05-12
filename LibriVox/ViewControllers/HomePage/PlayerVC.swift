//
//  PlayerVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 11/05/2023.
//

import UIKit

class PlayerVC: UIViewController {

    @IBOutlet weak var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view.
        
        let  selectedImage  = UIImage(named: "pause.svg")
        let normalImage = UIImage(named: "play.svg")
        
        playBtn.setImage(normalImage, for: .normal)
        playBtn.setImage(selectedImage, for: .selected)
    }
}
