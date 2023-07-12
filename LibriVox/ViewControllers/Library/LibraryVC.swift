//
//  LibraryVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 23/03/2023.
//

import UIKit

class LibraryVC: UIViewController {
    
    @IBOutlet weak var totalFinishedBooksLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var totalReadingBooksLabel: UILabel!
    var container : ContainerPagesVC?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
  
    func animateLabelIncrement(label: UILabel, toValue: Int, duration: TimeInterval) {
        var currentValue = 0
        let valueIncrement = 1
        let totalSteps = abs(toValue)
        let incrementDuration = duration / TimeInterval(totalSteps)
        
        let timer = Timer.scheduledTimer(withTimeInterval: incrementDuration, repeats: true) { timer in
            currentValue += valueIncrement
            label.text = "\(currentValue)"
            
            if currentValue == toValue {
                timer.invalidate()
            }
        }
                RunLoop.main.add(timer, forMode: .common)
    }


    var totalFinishedBooks: Int?
    var totalReadingBooks: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        totalFinishedBooks = totalBooksByParameter(parameter: "isFinished", value: true)
        totalReadingBooks = totalBooksByParameter(parameter: "isReading", value: true)
        
        
        animateLabelIncrement(label: totalReadingBooksLabel, toValue: totalReadingBooks!, duration: 1)
        
        animateLabelIncrement(label: totalFinishedBooksLabel, toValue: totalFinishedBooks!, duration: 1)
        
        setSegmetedControl(segmentedControl)
        
        container = self.children[0] as? ContainerPagesVC
    }
    
    @IBAction func segmentedControl (_ sender: UISegmentedControl){
        container?.gotoPage(pageNumber:sender.selectedSegmentIndex)
    }
}

func setSegmetedControl(_ control : UISegmentedControl){
    let attributedSegmentFont = NSDictionary(object: UIFont(name: "Nunito", size: 14)!, forKey: NSAttributedString.Key.font as NSCopying)
    control.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject] as [NSObject : AnyObject] as? [NSAttributedString.Key : Any], for: .normal)
}
