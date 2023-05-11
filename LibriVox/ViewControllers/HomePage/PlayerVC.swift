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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
