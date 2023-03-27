//
//  HomePageViewController.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 16/03/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class HomePageViewController: UIViewController {
  
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var backgroundContinueReading: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var trendingBooks: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logo.layer.cornerRadius = logo.layer.bounds.height / 2
        
        imgBook.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        progress.transform = progress.transform.scaledBy(x: 1, y:0.5)
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
    }
}



