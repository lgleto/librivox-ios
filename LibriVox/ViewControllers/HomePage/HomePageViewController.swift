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
import Alamofire

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var authorBook: UILabel!
    
    @IBOutlet weak var durationBook: UILabel!
    @IBOutlet weak var titleBook: UILabel!
    @IBOutlet weak var playBTN: UIButton!
    @IBOutlet weak var IndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var imgBook: LoadingImage!
    @IBOutlet weak var backgroundContinueReading: UIView!
    @IBOutlet weak var progress: UIProgressView!
    let db = Firestore.firestore()
    @IBOutlet weak var trendingBooks: UITableView!
    var booksTrending = [Audiobook]()
    var networkCheck = NetworkCheck.sharedInstance()
    
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
        
        print("Diretoria: \(NSHomeDirectory())")
        
        //        IndicatorView.startAnimating()
        //      IndicatorView.hidesWhenStopped = true
        let  selectedImage  = UIImage(named: "pause.svg")
        let normalImage = UIImage(named: "play.svg")
        
        playBTN.setImage(normalImage, for: .normal)
        playBTN.setImage(selectedImage, for: .selected)
        checkWifi()
        
        loadCurrentUser { user in
            guard let name = Auth.auth().currentUser?.displayName else { return }
            self.nameText.text = "Hello \(user?.username ?? name )"
            
            if let bookId = user?.lastBook, let audioBook = getBookByIdCD(id: bookId){
                self.setLastBook(audioBook: audioBook)
            }
        }

        progress.transform = progress.transform.scaledBy(x: 1, y:0.5)
        
        trendingBooks.delegate = self
        trendingBooks.dataSource = self
        
    }
    
    func setLastBook(audioBook: AudioBooks_Data){
      /*  if let imgData = audioBook.image, let img = UIImage(data: imgData) {
                self.imgBook.loadImage(from: img)
            }*/
        titleBook.text = audioBook.title
        durationBook.text = "Duratin: \(audioBook.totalTime)"
        authorBook.text = "Author(s): \(audioBook.authors)"
        
        progress.setProgress(45, animated: true)
        
    }
    @IBAction func playButton(_ sender: Any) {
        if (!checkIfFileExists(book: localBooks[1])) {
            PreparePlayerAlert.show(parentVC: self, title: "teste", book: localBooks[1] as! PlayableItemProtocol) { _ , book in
                PlayerVC.show(parentVC: self, book: book)
                
            }
        } else {
            PlayerVC.show(parentVC: self, book: localBooks[1] as! PlayableItemProtocol)
        }
        
    }
    
    @IBAction func allTrending(_ sender: Any) {
        //performSegue(withIdentifier: "allTrending", sender: nil)
        addTrendingtoBookSave(idBook: localBooks[1]._id!) { yes in
            if yes {
                print("sucessefully updated trending")
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "homepageToPlayer") {
            let destVC = segue.destination as! PlayerVC
            destVC.book = sender as! PlayableItemProtocol
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
        getCoverBook(id: localBooks[indexPath.row]._id!, url: localBooks[indexPath.row].urlLibrivox!){img in
            if let img = img{
                cell.bookCover.loadImage(from: img)
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
                guard let data = data else {return}
                print(data.books![0].title!)
                self.localBooks.append(data.books![0])
                self.trending.removeFirst()
                self.addForTrending(onCompelition: onCompelition)
            }
        }else {
            print("trending is empty")
            //print(self.localBooks)
        }
        if let c = onCompelition{
            c()
        }
        
    }
    
    
    func loadTrending(callback: @escaping ()->() ) {
        
        
        let db = Firestore.firestore()
        let booksRef = db.collection("books")
        booksRef.order(by: "trending", descending: true).limit(to: 3)
        
        
        booksRef.getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
                let alert = UIAlertController(title: "Error getting Trending", message: "Error getting the trending books, probably due to slow internet connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        self.IndicatorView.startAnimating()
                        self.checkWifi()
                        
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                    @unknown default:
                        print("this wasnt suposed to happen")
                    }
                }))
                self.IndicatorView.stopAnimating()
                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                for document in querySnapshot!.documents {
                    let s = document.data()
                    let book = Trending(dict: s)
                    self.trending.append(book!)
                }
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
        //if networkCheck.currentStatus == .satisfied{
        //Do something
        self.loadTrending {
            print("sdasda")
            
            self.trendingBooks.reloadData()
            //            self.IndicatorView.stopAnimating()
        }
        
        /* }else{
         //Show no network alert
         let alert = UIAlertController(title: "No Internet", message: "You dont have internet connection", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Retry",style: .default, handler: { action in
         switch action.style{
         case .default:
         self.IndicatorView.startAnimating()
         self.checkWifi()
         
         
         case .cancel:
         print("cancel")
         
         case .destructive:
         print("destructive")
         
         @unknown default:
         print("this wasnt suposed to happen")
         }
         }))
         self.IndicatorView.stopAnimating()
         self.present(alert, animated: true, completion: nil)
         }*/
    }
    
}

