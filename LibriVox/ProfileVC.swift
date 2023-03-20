//
//  ProfileVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 20/03/2023.
//

import UIKit

class ProfileVC: UIViewController {

    
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Make the profile picture rounded and beautiful
        profilePic.layer.borderWidth = 10
        profilePic.layer.borderColor = UIColor.lightGray.cgColor
        profilePic.layer.cornerRadius = 100
        profilePic.clipsToBounds = true
        profilePic.contentMode = UIView.ContentMode.scaleAspectFit
        profilePic.frame.size.width = 200
        profilePic.frame.size.height = 200
        profilePic.center = self.view.center
        
        // Do any additional setup after loading the view.
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
