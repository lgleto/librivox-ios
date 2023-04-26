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
        
        setSegmetedControl(segmentedControl)
        
        container = self.children[0] as? ContainerPagesVC
        container?.didMove = { page in
            self.segmentedControl.selectedSegmentIndex = page
        }
    }
    
    @IBAction func segmentedControl (_ sender: UISegmentedControl){
        container?.gotoPage(pageNumber:sender.selectedSegmentIndex)
    }
}

func setSegmetedControl(_ control : UISegmentedControl){
    let attributedSegmentFont = NSDictionary(object: UIFont(name: "Nunito", size: 14)!, forKey: NSAttributedString.Key.font as NSCopying)
    control.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject] as [NSObject : AnyObject] as? [NSAttributedString.Key : Any], for: .normal)
}
