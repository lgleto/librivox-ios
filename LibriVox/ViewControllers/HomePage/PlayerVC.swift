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
    //var book = Audiobook(_id: "52", title: "", _description: "", genres: [], authors: [], numSections: "", sections: [], language: "", urlZipFile: "https://www.archive.org/download/letters_brides_0709_librivox/letters_brides_0709_librivox_64kb_mp3.zip", urlLibrivox: "", urlProject: "", urlRss: "", totaltime: "", totaltimesecs: 0)
    var book = Audiobook()
    var basefolder = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let fileManager = FileManager.default
        basefolder = folderPath(id: book._id!)
        let specificFolderName = "mp3"
        
        
        if(fileManager.fileExists(atPath: basefolder)) {
            do {
                    let attributes = try fileManager.attributesOfItem(atPath: basefolder)
                    if let type = attributes[FileAttributeKey.type] as? FileAttributeType,
                       type == FileAttributeType.typeDirectory {
                        // The specific folder exists
                        print("The specific folder exists.")
                    } else {
                        // A file with the same name exists, but it's not a folder
                        print("A file with the same name exists, but it's not a folder.")
                    }
                } catch {
                    // Error occurred while retrieving attributes
                    print("Error: \(error)")
                }
        } else {
            // The specific folder does not exist
            print("The specific folder does not exist.")
            
        }
        

        

        

        
        
        
    }
    
   // func playMP3(){
   //     playerHandler.prepareSongAndSession(
   //         urlString: url.absoluteString,
   //         imageUrl: "",
   //         title: "Titulo not found",
   //         artist: displayAuthors(authors: book.authors!),
   //         albumTitle: book.title!,
   //         duration: book.totaltimesecs!)
   //
   //     playerHandler.onIsPlayingChanged { isPlaying in
   //        //handle play pause buttons
   //
   //     }
   //
   //     playerHandler.onProgressChanged { progress in
   //        // handle time display and tickers
   //     }
   // }
    
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


