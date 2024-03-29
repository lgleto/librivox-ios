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
    var finalList = [AudioBooks_Data](){
        didSet {
            self.tableView.reloadSections([0], with: UITableView.RowAnimation.none)
            checkAndUpdateEmptyState(list: finalList, alertImage: UIImage(named: "readingBook")!,view: self.tableView, alertText: "No books being read")
        }
    }
    var playerHandler : PlayerHandler = PlayerHandler.sharedInstance
    var allButtons: [ToggleBtn] = []
    var lastBook: Int?
    let spinner = UIActivityIndicatorView(style: .medium)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func contextDidChange(_ notification: Notification) {
        finalList = fetchBooksByParameterCD(parameter: "isReading", value: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        finalList = fetchBooksByParameterCD(parameter: "isReading", value: true)
        spinner.stopAnimating()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let persistentContainer = appDelegate.persistentContainer
            NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: persistentContainer.viewContext)
        }
        
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
        
        let book = finalList[indexPath.row]
        cell.titleBook.text = book.title
        cell.authorsBook.text = "Author(s): \(book.authors ?? "")"
        cell.imgBook.image = nil
        
        if let img = loadImageFromDocumentDirectory(id: book.id!){
            cell.imgBook.loadImage(from: img)
        }
        
        cell.durationBook.text = "Duration: \(book.totalTime ?? "")"
        
        allButtons.append(cell.playBtn)
        
        let progressDB = getPercentageOfBook(id: finalList[indexPath.row].id!, sectionNumber: Int(finalList[indexPath.row].sectionStopped))
        cell.progress.setProgress(progressDB, animated: true)
        
        cell.playBtn.tag = indexPath.row
        
        cell.playBtn.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func click(_ sender: UIButton) {
        allButtons.forEach { $0.isSelected = false}
                
        if lastBook != sender.tag{
            goToMiniPlayer(book: finalList[sender.tag], parentVC: self)
            playerHandler.playPause()

        }else{
            playerHandler.playPause()
        }
        
        print("resultado \(playerHandler.isPlaying)")
        sender.isSelected = playerHandler.isPlaying
        self.lastBook = sender.tag

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = tableView.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = convertToAudiobook(audioBookData: finalList[indexPath.row])
            if let img = loadImageFromDocumentDirectory(id: finalList[indexPath.row].id!) {
                detailVC.img = img
            }
        }
    }
}

