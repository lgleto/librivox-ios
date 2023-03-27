//
//  LibraryVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 23/03/2023.
//

import UIKit

class LibraryVC: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var container : ContainerPagesVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = self.children[0] as? ContainerPagesVC
        container?.didMove = { page in
            self.segmentedControl.selectedSegmentIndex = page
        }
    }
    
    @IBAction func segmentedControl (_ sender: UISegmentedControl){
        container?.gotoPage(pageNumber:sender.selectedSegmentIndex)
    }

}
