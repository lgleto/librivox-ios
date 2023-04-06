//
//  DiscoverRealVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 06/04/2023.
//

import UIKit

protocol DiscoverRealDelegate: AnyObject {
    func didChangeSearchText(_ text: String)
}

class DiscoverRealVC: UIViewController {
        
    weak var delegate: DiscoverRealDelegate?
    
    @IBOutlet weak var container: UIView!
    
    var emptyStateVC: DiscoverVC2?
    var resultsVC: DiscoverVC?
    
    @IBAction func searchHandler(_ sender: UITextField) {
        if let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
            
            print("bro")
            delegate?.didChangeSearchText(searchText)
            addViewController(resultsVC!, container, emptyStateVC)
            
        } else {
            addViewController(emptyStateVC!,container,resultsVC)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyStateVC = storyboard?.instantiateViewController(withIdentifier: "EmptyStateViewController") as? DiscoverVC2
        resultsVC = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as? DiscoverVC
        
        
        // Add the empty state view controller to the container view
        addChild(emptyStateVC!)
        container.addSubview(emptyStateVC!.view)
        emptyStateVC!.view.frame = container.bounds
        emptyStateVC!.didMove(toParent: self)
    }
    
    func addViewController(_ childViewController: UIViewController, _ container: UIView, _ stateViewController: UIViewController?) {
        // Add the new child view controller
        addChild(childViewController)
        container.addSubview(childViewController.view)
        childViewController.view.frame = container.bounds
        childViewController.didMove(toParent: self)
        
        // Remove the empty state view controller if it's currently added
        if let stateVC = stateViewController, stateVC.parent != nil {
            stateVC.willMove(toParent: nil)
            stateVC.view.removeFromSuperview()
            stateVC.removeFromParent()
        }
    }
}
