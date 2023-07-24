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
    var connection = true
    
    @IBAction func searchHandler(_ sender: UITextField) {
        if connection{
            if let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
                self.resultsVC?.didChangeSearchText(searchText)
                addViewController(resultsVC!, container, emptyStateVC)
            } else {
                addViewController(emptyStateVC!,container,resultsVC)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        checkWifi()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emptyStateVC = storyboard?.instantiateViewController(withIdentifier: "EmptyStateViewController") as? DiscoverOptionsVC
        resultsVC = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as? ResultBooksVC

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
    
    func checkWifi() {
        let networkCheck = NetworkCheck.sharedInstance()
        print("enter check wifi")
        if networkCheck.currentStatus == .satisfied {
            print("Connected to the internet")
            
            //removeImageNLabelAlert(view: self)
            connection = true
            
            addChild(emptyStateVC!)
            container.addSubview(emptyStateVC!.view)
            emptyStateVC!.view.frame = container.bounds
            emptyStateVC!.didMove(toParent: self)
        } else {
            connection = false
            removeChildViewControllers()
            setImageNLabelAlertVC(viewController: self, img: UIImage(named: "no-wifi")!, text: "Unable to connect to the internet. Please check your network connection and try again later.")
        }
    }

    func removeChildViewControllers() {
        emptyStateVC?.willMove(toParent: nil)
        emptyStateVC?.view.removeFromSuperview()
        emptyStateVC?.removeFromParent()
        
        resultsVC?.willMove(toParent: nil)
        resultsVC?.view.removeFromSuperview()
        resultsVC?.removeFromParent()
    }
}
