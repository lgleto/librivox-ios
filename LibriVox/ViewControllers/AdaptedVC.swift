//
//  AdaptedVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 31/05/2023.
//

import UIKit

class AdaptedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
  

}
