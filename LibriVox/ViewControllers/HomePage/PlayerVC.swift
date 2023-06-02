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
    @IBOutlet weak var progressBar: UIProgressView!
    var playerHandler : PlayerHandler = PlayerHandler()
    @IBOutlet weak var playBtn: ToggleBtn!
    var coverbook : UIImage?
    var book = Audiobook()
    var basefolder = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let fileManager = FileManager.default
        basefolder = folderPath(id: book._id!)
        
        if let fileNames = getFilesInFolder(folderPath: basefolder) {
            playMP3(url: "\(basefolder)/\(fileNames[0])")
        }
        
        
        
    }
    func playMP3(url: String ){
        let urlString = URL(fileURLWithPath:  url )
        playerHandler.prepareSongAndSession(
            urlString: urlString.absoluteString,
            imageUrl: "",
            title: book.title ?? "Title Not found",
            artist: displayAuthors(authors: book.authors!),
            albumTitle: book.title!,
            duration: book.totaltimesecs!)
   
        playerHandler.onIsPlayingChanged { isPlaying in
           //handle play pause buttons
   
        }
   
        playerHandler.onProgressChanged { progress in
           // handle time display and tickers
        }
    }
    
    @IBAction func playBTN(_ sender: Any) {
        playerHandler.playPause()
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


