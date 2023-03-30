//
//  HomePageViewController.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 16/03/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var backgroundContinueReading: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var trendingBooks: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadCurrentUser { user in
            self.nameText.text = "Hello \(user?.username ?? "User not found")"
        }
        
        getCurrentUserName()
        
        nameText.text = "Hello \(Auth.auth().currentUser!.displayName!)"
        
        logo.layer.cornerRadius = logo.layer.bounds.height / 2
        
        imgBook.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        progress.transform = progress.transform.scaledBy(x: 1, y:0.5)
        
        
        
    }
    
    func getCurrentUserName(){
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellBook
        cell.title.text = "Percy Jackson: The Lightning Thief"
        cell.author.text = "Author: Rick Riordan"
        cell.duration.text = "Duration: 08:40:31"
        cell.genre.text = "Genre: Drama"
        cell.bookCover.image = UIImage(named: "28187")
        cell.trendingNumber.text = "1."
        
        return cell
    }
}
func loadCurrentUser( callback: @escaping (User?)->() ) {
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    db.collection("users")
      .document(currentUser!.uid)
      .addSnapshotListener({ snapshot, error in
        if let s = snapshot,
          let d = s.data(),
          let user = User.init(dict: d ) {
          callback(user )
        }else {
          callback(nil)
        }
      })
  }
