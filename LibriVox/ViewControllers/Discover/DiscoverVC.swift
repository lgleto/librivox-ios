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
    
    private var emptyStateVC: DiscoverOptionsVC?
    private var resultsVC: ResultBooksVC?
    
    @IBAction func searchHandler(_ sender: UITextField) {
        if let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
            
            self.resultsVC?.didChangeSearchText(searchText)
            
            
            addViewController(resultsVC!, container, emptyStateVC)
            
        } else {
            addViewController(emptyStateVC!,container,resultsVC)
            print("executou inicio")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        
        guard let currentViewController = children.first else {
            addChild(childViewController)
            container.addSubview(childViewController.view)
            childViewController.view.frame = container.bounds
            childViewController.didMove(toParent: self)
            return
        }
        
        currentViewController.willMove(toParent: nil)
        currentViewController.view.removeFromSuperview()
        currentViewController.removeFromParent()
        
        
        addChild(childViewController)
        container.addSubview(childViewController.view)
        childViewController.view.frame = container.bounds
        childViewController.didMove(toParent: self)
        
    }
}
