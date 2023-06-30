//
//  BookDetailsVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 30/03/2023.
//

import UIKit
import SwaggerClient
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import CoreData




class BookDetailsVC: AdaptedVC {
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var showMoreBtn: UIButton!
    @IBOutlet weak var languageBook: UILabel!
    @IBOutlet weak var durationBook: UILabel!
    @IBOutlet weak var genreBook: UILabel!
    @IBOutlet weak var authorBook: UILabel!
    @IBOutlet weak var numSectionsBook: UILabel!
    @IBOutlet weak var descrBook: UILabel!
    @IBOutlet weak var sectionsTV: UITableView!
    @IBOutlet weak var bookImg: RoundedBookImageView!
    @IBOutlet weak var backgroundImage: BlurredImageView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    
    var book: Audiobook?
    var sections: [Section] = []
    private var rowsToBeShow:Int?
    
    var img: UIImage? = nil
    
    private func syncPlayPauseButton() {
        guard let id = book?._id else {
            return
        }
        
        /*if let currentAudiobookID = MiniPlayerManager.shared.currentAudiobookID,currentAudiobookID == id {
         playBtn.isSelected = MiniPlayerManager.shared.isPlaying
         }*/
    }
    
    @objc func miniPlayerDidUpdatePlayState(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isPlaying = userInfo["state"] as? Bool else {return}
        playBtn.isSelected = isPlaying
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = book?._id, let currentAudiobookID = MiniPlayerManager.shared.currentAudiobookID,currentAudiobookID == id {
            NotificationCenter.default.addObserver(self, selector: #selector(miniPlayerDidUpdatePlayState(_:)), name: Notification.Name("miniPlayerState"), object: nil)
        }
        
        sectionsTV.dataSource = self
        sectionsTV.delegate = self
        
        showMoreBtn.setTitle("Show all", for: .normal)
        showMoreBtn.setTitle("Hide all", for: .selected)
        sectionsTV.alwaysBounceVertical = false
        
        if let book = book {
            self.title = book.title!
            setData(book: book)
            
            
            guard let documentID = book._id else {return}
            
            
            let audiobook = getBookByIdCD(id: documentID)
            favBtn.isSelected = audiobook?.isFav ?? false
            
            /*isBookMarkedAs("isFav", value: true, documentID: documentID) { isMarked in
                DispatchQueue.main.async {
                    
                    self.favBtn.isSelected = isMarked ?? false ? true : false
                }
            }*/
        }
    }
    
    
    
    @IBAction func clickShowMore(_ sender: Any) {
        showMoreBtn.isSelected = !showMoreBtn.isSelected
        
        sectionsTV.reloadData()
    }
    
    func setData(book : Audiobook){
        if let img = img{
            bookImg.loadImage(from: img)
            backgroundImage.loadImage(from: img)
        }else{
            getCoverBook(id: book._id!,url: book.urlLibrivox!){
                img in
                if let img = img{
                    self.bookImg.loadImage(from: img)
                    self.backgroundImage.loadImage(from: img)
                }
            }
        }
        
        let authors = displayAuthors(authors: book.authors ?? [])
        let genres = displayGenres(strings: book.genres ?? [])
        
        durationBook.attributedText = stringFormatted(textBold: "Duration: ", textRegular: book.totaltime ?? "00:00:00", size: 15.0)
        genreBook.attributedText = stringFormatted(textBold: "Genre(s): ", textRegular: genres, size: 15.0)
        authorBook.attributedText = stringFormatted(textBold: "Author(s): ", textRegular: authors, size: 15.0)
        numSectionsBook.attributedText = stringFormatted(textBold: "Nº Sections: ", textRegular: book.numSections ?? "0", size: 15.0)
        languageBook.attributedText = stringFormatted(textBold: "Language: ", textRegular: book.language ?? "Not specified", size: 15.0)
        
        descrBook.text = removeHtmlTagsFromText(text: book._description ?? "No sinopse available")
        
    }
    
    @IBAction func clickFav(_ sender: Any) {
        let newIsFavValue = !favBtn.isSelected
        guard let book = book, let documentID = book._id else {return}
        
        
        isBookMarkedAs("isFav", value: true, documentID: documentID) { isMarked in
            guard isMarked != nil else{
                addToCollection(Book(book: book, isFav: newIsFavValue)) { success in}
                return
            }
            
            updateBookParameter("isFav", value: newIsFavValue, documentID: documentID)
        }
        
    }
    
    @IBAction func playBookBtn(_ sender: Any) {
        playBtn.isSelected = !playBtn.isSelected
        updateUserParameter("lastBook", value: (book?._id)!)
        addTrendingToBook(book: book!, lvlTrending: 5) { yes in
            print("sucess")
        }
    }
    
}

extension BookDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionsNum = book?.sections?.count else{return 0}
        
        let showAllRows = showMoreBtn.isSelected
        switch sectionsNum{
        case ..<20:
            rowsToBeShow =  showAllRows ?  sectionsNum : sectionsNum / 2
        case 20..<50:
            rowsToBeShow = showAllRows ?  sectionsNum : sectionsNum / 3
        default:
            rowsToBeShow = showAllRows ? sectionsNum : 30
        }
        
        heightConstant.constant = CGFloat(Double(rowsToBeShow!) * 80)
        return rowsToBeShow!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sectionsTV.dequeueReusableCell(withIdentifier: "SectionsCell", for: indexPath) as! SectionsCell
        let section = book?.sections?[indexPath.row]
        
        let seconds = Int(section?.playtime ?? "Not found") ?? 0
        
        cell.titleSection.text = section?.title
        cell.durationSection.text! = "Duration: \(secondsToMinutes(seconds: seconds))min "
        return cell
    }
}

/*func isBookMarkedAsFavorite(bookID: String) -> Bool {
    guard let authUID = UserDefaults.standard.string(forKey: "currentUserID") else {
        return false
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "id == %@", authUID)
    
    do {
        let users = try context.fetch(userFetchRequest)
        guard let currentUser = users.first else {
            return false
        }
        
        if let existingBookInfo = currentUser.books_Info?.first(where: { ($0 as! Books_Info).audioBook_Data?.id == bookID }) as? Books_Info {
            return existingBookInfo.isFav
        }
        
    } catch {
        print("Error: \(error)")
    }
    
    return false
}*/
