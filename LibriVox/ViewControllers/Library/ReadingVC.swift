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

class ReadingVC: UITableViewController {
    var finalList = [Books_Info]()
    var allButtons: [ToggleBtn] = []
    var lastBook: Int?
    let spinner = UIActivityIndicatorView(style: .medium)
    
    
    override func viewWillAppear(_ animated: Bool) {
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        finalList = fetchBooksByParameterCD(parameter: "isReading", value: true)
      
        spinner.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(self, selector: #selector(miniPlayerDidUpdatePlayState(_:)), name: Notification.Name("miniPlayerState"), object: nil)
        
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
