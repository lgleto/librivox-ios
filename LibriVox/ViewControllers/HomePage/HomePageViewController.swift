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
import SwaggerClient
import Reachability

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var IndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var backgroundContinueReading: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    let db = Firestore.firestore()
    @IBOutlet weak var trendingBooks: UITableView!
    var booksTrending = [Audiobook]()
    var networkCheck = NetworkCheck.sharedInstance()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IndicatorView.startAnimating()
        IndicatorView.hidesWhenStopped = true
        self.tabBarController?.tabBar.isHidden = false

        checkWifi()
        
        loadCurrentUser { user in
            self.nameText.text = "Hello \(user?.username ?? "User not found")"
        }
        
        //getCurrentUserName()
        
        //nameText.text = "Hello \(Auth.auth().currentUser!.displayName!)"
        
        logo.layer.cornerRadius = logo.layer.bounds.height / 2
        
        imgBook.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        progress.transform = progress.transform.scaledBy(x: 1, y:0.5)
        
        
        
        trendingBooks.delegate = self
        trendingBooks.dataSource = self
        
        
        

        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomepageToTrendingBooks") {
                
        } else if (segue.identifier == "homeToBookDetail"){
            let destVC = segue.destination as! BookDetailsVC
            destVC.book = sender as? Audiobook
        }
        
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (localBooks.count > 3) {
            return 3
        } else {
            print("Local Books count->" , localBooks.count)
            return localBooks.count
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellBook
        cell.selectionStyle = .none
        var authorsString = "Authors: "
        var genreString = "Genre: "
        cell.title.text = self.localBooks[indexPath.row].title
        if (self.localBooks.count > 1) {
            cell.author.text = "Author: \(self.localBooks[indexPath.row].authors![0].firstName!) \(self.localBooks[indexPath.row].authors![0].lastName!)"
        } else {
            for author_ in self.localBooks[indexPath.row].authors! {
                if (authorsString == "Authors: ") {
                    authorsString += "\(author_.firstName!) \(author_.lastName!)"
                } else {
                    authorsString += ", \(author_.firstName!) \(author_.lastName!) "
                }
                
            }
            cell.author.text = authorsString
        }

        
        cell.duration.text = "Duration: \(self.localBooks[indexPath.row].totaltime!)"
        
        for genre_ in self.localBooks[indexPath.row].genres! {
            genreString += "\(genre_.name!), "
        }
        
        cell.genre.text = "Genre: \(self.localBooks[indexPath.row].genres![0].name!)"
        cell.trendingNumber.text = "\(indexPath.row+1)."
        
        cell.bookCover.image = nil
        getCoverBook(url: localBooks[indexPath.row].urlLibrivox!){img in
            cell.bookCover.kf.setImage(with: img)
            DispatchQueue.main.async {
                   cell.bookCover.contentMode = .scaleToFill
               }
        }
        
        return cell
    }
    
    @IBAction func BTNTrendingBooks(_ sender: Any) {
        performSegue(withIdentifier: "HomepageToTrendingBooks", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "homeToBookDetail", sender: localBooks[indexPath.row])
    }

    
    
    
    var trending = [Trending]()
    var localBooks = [Audiobook]()
    func addForTrending(  onCompelition : (()->())? = nil ) {
        if let trend = trending.first {
            DefaultAPI.audiobooksIdBookIdGet(bookId: Int64(trend.id)!, format: "json", extended: 1) { data, error in
                //print(error!)
                print(data!.books![0].title!)
                self.localBooks.append(data!.books![0])
                self.trending.removeFirst()
                self.addForTrending(onCompelition: onCompelition)
            }
        }else {
            print("trending is empty")
            //print(self.localBooks)
            if let c = onCompelition{
                c()
            }
            
        }
    }
    
    func loadTrending(callback: @escaping ()->() ) {
        
        
        let db = Firestore.firestore()
        let booksRef = db.collection("books")
        booksRef.order(by: "trending", descending: true).limit(to: 3)
        
        booksRef.getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let s = document.data()
                    let book = Trending(dict: s)
                    self.trending.append(book!)
                    //print("\(document.documentID) => \(document.data())")
                }
                /*
                 for trend in trending {
                 print(Int64(trend.id)!)
                 DefaultAPI.idBookIdGet(bookId: Int64(trend.id)!, format: "json", extended: 1) { data, error in
                 print(data!.books![0].title!)
                 books.append(data!.books![0])
                 }
                 }*/
                self.addForTrending() {
                    print("inside loadTrending")
                    callback()
                }
                
                
            }
        }
    }

    func checkWifi() {
        networkCheck = NetworkCheck.sharedInstance()
        print("enter check wifi")
        if networkCheck.currentStatus == .satisfied{
                        //Do something
            self.loadTrending {
                print("sdasda")
                self.trendingBooks.reloadData()
                self.IndicatorView.stopAnimating()
            }
                    }else{
                        //Show no network alert
                        let alert = UIAlertController(title: "No Internet", message: "You dont have internet connection", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                            switch action.style{
                                case .default:
                                self.checkWifi()
                                
                                case .cancel:
                                print("cancel")
                                
                                case .destructive:
                                print("destructive")
                                
                            @unknown default:
                                print("this wasnt suposed to happen")
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
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

