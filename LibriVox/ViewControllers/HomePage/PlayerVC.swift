//
//  PlayerVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 11/05/2023.
//

import UIKit
import SwaggerClient
import SSZipArchive
import AVFoundation

protocol DataDelegate: AnyObject {
    func didDismissWithData(currentSection: Int, book: PlayableItemProtocol)
}


class PlayerVC: UIViewController, DataDelegate {
    
    @IBOutlet weak var favBtn: ToggleBtn!
    func didDismissWithData(currentSection: Int, book:PlayableItemProtocol) {
        // Handle the passed data here
        self.currentSection = currentSection
        self.book = book
    }
    
    static func show(parentVC   : UIViewController,
                     book: PlayableItemProtocol
    )
      {
        let storyBoard :UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let vc : PlayerVC = storyBoard.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerVC
          vc.book = book
          
          vc.modalTransitionStyle = .coverVertical
          vc.modalPresentationStyle = .overFullScreen
          
          parentVC.present(vc, animated: true)
      }

    @IBAction func fav(_ sender: Any) {
        let newIsFavValue = !favBtn.isSelected
        updateBookParameter("isFav", value: newIsFavValue, documentID: (book?._id)!)
    }
    
    @IBOutlet weak var sectionNumber: UILabel!
    @IBOutlet weak var imgBook: LoadingImage!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var background: BlurredImageView!
    var playerHandler : PlayerHandler = PlayerHandler.sharedInstance
    @IBOutlet weak var playBtn: ToggleBtn!
    @IBOutlet weak var labelRemainingTime: UILabel!
    @IBOutlet weak var labelMaxTime: UILabel!
    var coverbook : UIImage?
    var currentSection : Int? {
        didSet{
            currentSection = currentSection! - 1
            if let bookId = book?._id {
                storeSectionTime(currentBookId: bookId)
            }
            playMP3(newSection: true)
        }
    }
    var book : PlayableItemProtocol?
    var basefolder = ""
    var isChangingSlidePosition = false
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        favBtn.isSelected = book?.isfav ?? false
        self.navigationItem.title = book?.title
        getCoverBook(id: (book?._id)!){img in
            if let img = img{
                self.imgBook.contentMode = .scaleAspectFill
                self.imgBook.loadImage(from: img)
                self.background.loadImage(from: img)}
        }
        sectionNumber.text = "Section Nº \(String(currentSection ?? 0))"
        playMP3(newSection: false)
        
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissVC))
                     gesture.direction = .down
                     view.isUserInteractionEnabled = true // For UIImageView
                     view.addGestureRecognizer(gesture)
    }
    func playMP3(newSection: Bool){
        
        
        if (!playerHandler.isPlaying || newSection){
            if let book = book{
                basefolder = folderPath(id: book._id!)
                let fileNames = getFilesInFolder(folderPath: basefolder)
                let url = "\(basefolder)/\(fileNames![currentSection ?? 0])"
                let urlString = URL(fileURLWithPath:  url )
                    self.playerHandler.prepareSongAndSession(
                        urlString: urlString.absoluteString,
                        image:  UIImage(systemName: "person.crop.square")!,
                        title: book.title ?? "Title Not found",
                        artist: "",
                        albumTitle: book.title!,
                        duration: Int(book.sections![currentSection ?? 1  - 1].playtime!)!)
           
                playerHandler.book = book
                playerHandler.currentSection = currentSection ?? 0
            }
            
        }
        
        labelMaxTime.text = secondsToTime(Int((playerHandler.book?.sections![playerHandler.currentSection ?? 1  - 1].playtime)!)!)
        slider.maximumValue = secondsToMillis(Int((playerHandler.book?.sections![playerHandler.currentSection ?? 1-1].playtime)!)!)
        titleLabel.text = titlePlayer(bookTitle: (playerHandler.book?.title)!, sectionTitle: (playerHandler.book?.sections![playerHandler.currentSection ?? 1  - 1].title)!)


   
        playerHandler.onIsPlayingChanged { isPlaying in
           //handle play pause buttons
            
            self.playBtn.setImage(isPlaying ? UIImage(named: "pause") : UIImage(named: "play") , for: .normal)
            
        }
   
        playerHandler.onProgressChanged { progress in
           // handle time display and tickers
            
            if !self.isChangingSlidePosition {
                self.slider.value = Float(progress)
                //self.labelMaxTime.text = millisToTime(progress)
                self.labelRemainingTime.text = millisToTime(progress)
            }
        }
    }
    
    @IBAction func playBTN(_ sender: Any) {
        playerHandler.playPause()
        if let bookId = book?._id {
            storeSectionTime(currentBookId: bookId)
        }
    }
    
    @IBAction func sliderPositionEndChanged(_ sender: UISlider) {
        isChangingSlidePosition=false
        playerHandler.seekTo(position: Int(sender.value))
    }
    
    @IBAction func sliderPositionChanged(_ sender: UISlider) {
        labelRemainingTime.text = millisToTime(Int(sender.value))
    }
    
    @IBAction func sliderPositionBeginChanged(_ sender: UISlider) {
        isChangingSlidePosition=true
    }
    
    @objc
    private func dismissVC() {
        if let bookId = book?._id {
            storeSectionTime(currentBookId: bookId)
        }
        dismiss(animated: true){
            if (!self.playerHandler.isPlaying) {
                var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                
                while (topController.presentedViewController != nil) {
                    topController = topController.presentedViewController!
                    
                }
            }
        }
    }
    
    
    @IBAction func sectionsBTN(_ sender: Any) {
        SectionsTVC.showSections(parentVC: self,title: "titulo", book: book!) { yes , book, currentSection in
            if (yes) {
                self.book = book
                self.currentSection = currentSection
                self.resetValues()
            }
            
        }
    }
    
    func resetValues() {
        self.slider.value = 0
        self.labelRemainingTime.text = millisToTime(0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomepageToTrendingBooks") {
            
        } else if (segue.identifier == "PlayerToSections"){
            let destVC = segue.destination as! SectionsTVC
            destVC.book = sender as? PlayableItemProtocol
        }
        
    }
    

    

}


