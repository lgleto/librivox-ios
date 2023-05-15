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
    var playerHandler : PlayerHandler = PlayerHandler()
    @IBOutlet weak var playBtn: ToggleBtn!
    var coverbook : UIImage?
    var book = Audiobook(_id: "52", title: "", _description: "", genres: [], authors: [], numSections: "", sections: [], language: "", urlZipFile: "https://www.archive.org/download/letters_brides_0709_librivox/letters_brides_0709_librivox_64kb_mp3.zip", urlLibrivox: "", urlProject: "", urlRss: "", totaltime: "", totaltimesecs: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("\(folderPath())/\(self.book._id!)/mp3/letters_of_two_brides_01_debalzac_64kb.mp3")
        //getMP3()
        let url = URL(fileURLWithPath: "\(folderPath())/\(self.book._id!)/mp3/letters_of_two_brides_01_debalzac_64kb.mp3" )
        
        playerHandler.prepareSongAndSession(
            urlString: url.absoluteString,
            imageUrl: "",
            title: "Titulo not found",
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
    
    
    func getMP3() {
        guard let url = URL(string: self.book.urlZipFile!) else {
            return
        }

        let destinationPath = "\(folderPath())/\(self.book._id!)/mp3/"
        let fileManager = FileManager.default

        do {
            if !fileManager.fileExists(atPath: destinationPath) {
                try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
            }

            let destinationUrl = URL(fileURLWithPath: destinationPath).appendingPathComponent("audio.zip")

            let task = URLSession.shared.downloadTask(with: url) { localUrl, response, error in
                if let localUrl = localUrl {
                    do {
                        if fileManager.fileExists(atPath: destinationUrl.path) {
                            try fileManager.removeItem(at: destinationUrl)
                        }

                        try fileManager.moveItem(at: localUrl, to: destinationUrl)
                        print("Zip file downloaded and saved to: \(destinationUrl.path)")

                        do {
                            try SSZipArchive.unzipFile(atPath: destinationUrl.path, toDestination: destinationPath, overwrite: true, password: nil)

                            let subdirectories = try fileManager.contentsOfDirectory(atPath: destinationPath).filter {
                                $0.hasSuffix("librivox_64kb_mp3")
                            }

                            if let subdirectory = subdirectories.first {
                                let mp3Files = try fileManager.contentsOfDirectory(atPath: "\(destinationPath)/\(subdirectory)").filter {
                                    $0.hasSuffix(".mp3")
                                }

                                if let mp3File = mp3Files.first {
                                    let mp3FilePath = "\(destinationPath)/\(subdirectory)/\(mp3File)"
                                    // Play the mp3 file at mp3FilePath
                                    do {
                                        let url = URL(fileURLWithPath: mp3FilePath)
                                        let player = try AVAudioPlayer(contentsOf: url)
                                        player.prepareToPlay()
                                        player.play()
                                    } catch {
                                        print("Error playing mp3 file: \(error.localizedDescription)")
                                    }
                                }
                            }
                        } catch {
                            print("Error extracting zip file: \(error.localizedDescription)")
                        }
                    } catch {
                        print("Error moving zip file: \(error.localizedDescription)")
                    }
                } else {
                    print("Error downloading zip file: \(error?.localizedDescription ?? "Unknown error")")
                }
            }

            task.resume()
        } catch {
            print("Error creating destination directory: \(error.localizedDescription)")
        }
    }
}
