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
    @IBOutlet weak var IndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var imgBook: LoadingImage!
    @IBOutlet weak var backgroundContinueReading: UIView!
    @IBOutlet weak var progress: UIProgressView!
    let db = Firestore.firestore()
    @IBOutlet weak var trendingBooks: UITableView!
    
    var booksTrending = [Audiobook]()
    var networkCheck = NetworkCheck.sharedInstance()
    var allButtons: [ToggleBtn] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    var lastAudioBook = AudioBooks_Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllBooks()
        //checkWifi()
        
        loadCurrentUser { user in
            guard let name = Auth.auth().currentUser?.displayName else { return }
            self.nameText.text = "Hello \(user?.username ?? name )"
            
            if let bookId = user?.lastBook,let audioBook = getBookByIdCD(id: bookId){
                self.setLastBook(audioBook: audioBook)
                self.lastAudioBook = audioBook
            }
        }
        //removeImageNLabelAlert(view: trendingBooks)
        loadTrending(){
            self.trendingBooks.reloadData()
        }
        
        progress.transform = progress.transform.scaledBy(x: 1, y:0.6)
        
        trendingBooks.delegate = self
        trendingBooks.dataSource = self
        
    }
    
    func setLastBook(audioBook: AudioBooks_Data){
        getCoverBook(id: audioBook.id!){img in
            if let img = img{
                self.imgBook.loadImage(from: img)
            }
        }
        
        titleBook.text = audioBook.title ?? ""
        durationBook.text = "Duration: \(audioBook.totalTime ?? "")"
        authorBook.text = "Author(s): \(audioBook.authors ?? "")"
        print("oupa \(audioBook.id) \(Int(audioBook.sectionStopped))")
        
        let progressDB = getPercentageOfBook(id: audioBook.id!, sectionNumber: Int(audioBook.sectionStopped))
        progress.setProgress(progressDB, animated: true)
    }
    
    
    @IBAction func playButton(_ sender: Any) {
        goToPlayer(book: lastAudioBook, parentVC: self)
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
        if localBooks.count == 0{
            setImageNLabelAlert(view: trendingBooks, img: UIImage(named: "no-wifi")!, text: "Unable to connect to the internet. Please check your network connection and try again later.")

        }
        return localBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellBook
        
        cell.title.text = self.localBooks[indexPath.row].title
        cell.author.text = "Author: \(displayAuthors(authors: self.localBooks[indexPath.row].authors ?? []))"
        cell.duration.text = "Duration: \(self.localBooks[indexPath.row].totaltime!)"
        cell.genre.text = "Genre: \(displayGenres(strings: self.localBooks[indexPath.row].genres ?? []))"
        cell.trendingNumber.text = "\(indexPath.row + 1)."
        
        cell.bookCover.image = nil
        getCoverBook(id: localBooks[indexPath.row]._id!, url: localBooks[indexPath.row].urlLibrivox!){img in
            if let img = img{
                cell.bookCover.loadImage(from: img)
            }
        }
        cell.playBtn.tag = indexPath.row
        allButtons.append(cell.playBtn)
        
        cell.playBtn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)

        return cell
    }
    
    @objc func click(_ sender: UIButton) {
        allButtons.forEach { $0.isSelected = false}
        
        //playerHandler.playPause()
        //sender.isSelected = playerHandler.isPlaying
        
        /*if lastBook != sender.tag{*/
        print("dude \(localBooks[sender.tag].title)")
        goToPlayer(book: localBooks[sender.tag], parentVC: self)
           
        //self.lastBook = sender.tag
    }
    @IBAction func BTNTrendingBooks(_ sender: Any) {
        performSegue(withIdentifier: "HomepageToTrendingBooks", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "homeToBookDetail", sender: localBooks[indexPath.row])
    }
    
    
    
    var localBooks = [Audiobook]()
    func loadTrending(callback: @escaping ()->() ) {
        let db = Firestore.firestore()
        let booksRef = db.collection("books")
        let trendingLvl = booksRef.order(by: "trending", descending: false)
        let query = trendingLvl.limit(to: 3)
        

        query.getDocuments{ querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
                let alert = UIAlertController(title: "Error getting Trending", message: "Error getting the trending books, probably due to slow internet connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                    switch action.style{
                    case .default: break
                        //self.IndicatorView.startAnimating()
                        //self.checkWifi()
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    @unknown default:
                        print("this wasnt suposed to happen")
                    }
                }))
                //self.IndicatorView.stopAnimating()
                self.present(alert, animated: true, completion: nil)
                
            } else {
                for document in querySnapshot!.documents {
                    let s = document.data()
                    let book = Audiobook(dict: s)
                    self.localBooks.append(book)
                    removeImageNLabelAlert(view: self.trendingBooks)
                }
                callback()
            }
        }
    }
    
   /* func checkWifi() {
        networkCheck = NetworkCheck.sharedInstance()
        print("enter check wifi")
        if networkCheck.currentStatus == .satisfied{
            removeImageNLabelAlert(view: trendingBooks)
            loadTrending(){
                self.trendingBooks.reloadData()
            }
        } else{
            setImageNLabelAlert(view: trendingBooks, img: UIImage(named: "no-wifi")!, text: "Unable to connect to the internet. Please check your network connection and try again later.")

            /* //Show no network alert
             let alert = UIAlertController(title: "No Internet", message: "You dont have internet connection", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Retry",style: .default, handler: { action in
             switch action.style{
             case .default:
             self.IndicatorView.startAnimating()
             self.checkWifi()*
             
             
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
        
    }*/
    
}
