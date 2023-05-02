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

class DiscoverVC: UIViewController {
    
    @IBOutlet weak var container: UIView!
    
    var emptyStateVC: DiscoverOptionsVC?
    var resultsVC: ResultBooksVC?
    
    
    @IBAction func searchHandler(_ sender: UITextField) {
        if let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
            resultsVC?.didChangeSearchText(searchText)
            addViewController(resultsVC!, container, emptyStateVC)
            
        } else {
            addViewController(emptyStateVC!,container,resultsVC)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyStateVC = storyboard?.instantiateViewController(withIdentifier: "EmptyStateViewController") as? DiscoverOptionsVC
        resultsVC = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as? ResultBooksVC
        
        addChild(emptyStateVC!)
        container.addSubview(emptyStateVC!.view)
        emptyStateVC!.view.frame = container.bounds
        emptyStateVC!.didMove(toParent: self)
    }
    
    func addViewController(_ childViewController: UIViewController, _ container: UIView, _ stateViewController: UIViewController?) {
        
        addChild(childViewController)
        container.addSubview(childViewController.view)
        childViewController.view.frame = container.bounds
        childViewController.didMove(toParent: self)
        
        if let stateVC = stateViewController, stateVC.parent != nil {
            stateVC.willMove(toParent: nil)
            stateVC.view.removeFromSuperview()
            stateVC.removeFromParent()
        }
    }
}
