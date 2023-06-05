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

class PlayerVC: UIViewController {
    @IBOutlet weak var slider: UISlider!
    var playerHandler : PlayerHandler = PlayerHandler()
    @IBOutlet weak var playBtn: ToggleBtn!
    @IBOutlet weak var labelRemainingTime: UILabel!
    @IBOutlet weak var labelMaxTime: UILabel!
    var coverbook : UIImage?
    var currentSection : Int?
    var book = Audiobook()
    var basefolder = ""
    var isChangingSlidePosition = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let fileManager = FileManager.default
        basefolder = folderPath(id: book._id!)
        self.navigationItem.title = book.title
        labelMaxTime.text = secondsToTime(Int(book.sections![0].playtime!) ?? 1)
        slider.maximumValue = secondsToMillis(Int(book.sections![0].playtime!) ?? 1)
        if let fileNames = getFilesInFolder(folderPath: basefolder) {
            playMP3(url: "\(basefolder)/\(fileNames[0])")
        }
        
        
        
    }
    func playMP3(url: String ){
        let urlString = URL(fileURLWithPath:  url )
        
        getCoverBook(id: book._id!, url: book.urlLibrivox!) {  image in
            self.playerHandler.prepareSongAndSession(
                urlString: urlString.absoluteString,
                image: image!,
                title: self.book.title ?? "Title Not found",
                artist: displayAuthors(authors: self.book.authors!),
                albumTitle: self.book.title!,
                duration: Int(self.book.sections![0].playtime!)!)
        }

   
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
    
    
    @IBAction func sectionsBTN(_ sender: Any) {
        performSegue(withIdentifier: "PlayerToSections", sender: book)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomepageToTrendingBooks") {
            
        } else if (segue.identifier == "PlayerToSections"){
            let destVC = segue.destination as! SectionsTVC
            destVC.book = sender as? Audiobook
        }
        
    }
    

}


