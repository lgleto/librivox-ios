//
//  ReadingVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 26/04/2023.
//

import UIKit

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwaggerClient



/*class Repository {
     class func getArticles ( category :String,
                   context : NSManagedObjectContext,
              callback : @escaping ([Article], Error?)->() )
    {
        var chachedArtilces : [Article] = getCachedArticles(category: category, context: context)
        callback(chachedArtilces, nil )
 
        NewsAPI.topHeadlinesGet(apiKey: NEWS_API_KEY,
                                country: COUNTRY,
                                category: category) { (articles, error) in
            if (error == nil){
                if let arts = articles?.articles {
                    for article in arts{
                        _ = ArticleCache.addItem(url: article.url ?? "",
                                             jsonString: article.toJsonString(),
                                             category: category,
                                             inManagedObjectContext: context)
                    }
                }
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                chachedArtilces = getCachedArticles(category: category, context: context)
                callback(chachedArtilces, nil )
            }else {
                callback(chachedArtilces, error )
                print(error.debugDescription)
            }
        }
    }
}*/

class ReadingVC: UITableViewController {
    //var finalList: [Book] = []
    var finalList = [Books_Info]()
    var allButtons: [ToggleBtn] = []
    var lastBook: Int?
    let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(miniPlayerDidUpdatePlayState(_:)), name: Notification.Name("miniPlayerState"), object: nil)
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        finalList = fetchBooksByParameterCD(parameter: "isReading", value: true)
        /*for book in finalList{
            addAudiobookCD(audioBook: convertToAudiobook(audioBookData: book.audioBook_Data!))}*/
        spinner.stopAnimating()
        
        tableView.reloadSections([0], with: UITableView.RowAnimation.left)
        checkAndUpdateEmptyState(list: finalList, alertImage: UIImage(named: "readingBook")!,view: tableView, alertText: "No books being read")
        
        /*getBooksByParameter("isReading", value: true){ books in
            self.finalList = books
            self.spinner.stopAnimating()
            
            if !books.isEmpty{
                for book in books{
                    addBookCD(book: book)
                }
            }
 
            self.tableView.reloadSections([0], with: UITableView.RowAnimation.left)
            checkAndUpdateEmptyState(list: self.finalList, alertImage: UIImage(named: "readingBook")!,view: self.tableView, alertText: "No books being read")
        }*/
    }
    
    @objc func miniPlayerDidUpdatePlayState(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isPlaying = userInfo["state"] as? Bool else {return}
        guard let lastBook = lastBook else{return}
        
        allButtons[lastBook].isSelected = isPlaying
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingCellTVC", for: indexPath) as! ReadingCellTVC
        
        let book = finalList[indexPath.row].audioBook_Data
        cell.titleBook.text = book?.title
        cell.authorsBook.text = "Author: \(book?.authors)"
        cell.imgBook.image = nil
        
        if let imgData = book?.image, let img = UIImage(data: imgData) {
                cell.imgBook.loadImage(from: img)
        }

        cell.durationBook.text = "Duration: \(book?.totalTime)"
       /* let book = finalList[indexPath.row].book
        
        cell.titleBook.text = book.title
        cell.authorsBook.text = "Author: \(displayAuthors(authors: book.authors ?? []))"
        cell.imgBook.image = nil
        
        if let imgUrl = finalList[indexPath.row].imageUrl,let url = URL(string:imgUrl){
            cell.imgBook.loadImageURL(from: url)
        }
       
        
        getCoverBook(id: book._id!, url: book.urlLibrivox!){img in
            if let img = img{
                cell.imgBook.loadImage(from: img)}
        }
        
        if let duration = book.totaltime{cell.durationBook.text = "Duration: \(duration)"}*/
        allButtons.append(cell.playBtn)
        
        
        cell.playBtn.tag = indexPath.row
        
        cell.playBtn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func click(_ sender: UIButton) {
        allButtons.forEach { $0.isSelected = false}
        
        sender.isSelected = true
        
        if lastBook != sender.tag{
            if let tabBarController = tabBarController as? HomepageTBC {
                tabBarController.addChildView(book: finalList[sender.tag].audioBook_Data!)
            }
        }else{sender.isSelected = false}
        
        self.lastBook = sender.tag
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = tableView.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = convertToAudiobook(audioBookData: finalList[indexPath.row].audioBook_Data!)
            if let imgData = finalList[indexPath.row].audioBook_Data?.image, let img = UIImage(data: imgData) {
                detailVC.img = img
            }
        }
    }
}

func updateBookInfoParameter(bookInfo: Books_Info, parameter: String, value: Any) {
    let context = bookInfo.managedObjectContext
    bookInfo.setValue(value, forKey: parameter)
    
    do {
        try context?.save()
        print("Updated the book_info parameter.")
    } catch {
        print("Error: \(error)")
    }
}
