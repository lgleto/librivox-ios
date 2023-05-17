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
    
    let delegate = DownloadDelegate()
    @IBOutlet weak var progressBar: UIProgressView!
    var playerHandler : PlayerHandler = PlayerHandler()
    @IBOutlet weak var playBtn: ToggleBtn!
    var coverbook : UIImage?
    //var book = Audiobook(_id: "52", title: "", _description: "", genres: [], authors: [], numSections: "", sections: [], language: "", urlZipFile: "https://www.archive.org/download/letters_brides_0709_librivox/letters_brides_0709_librivox_64kb_mp3.zip", urlLibrivox: "", urlProject: "", urlRss: "", totaltime: "", totaltimesecs: 0)
    var book = Audiobook()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        delegate.progressBar = progressBar
        let fileManager = FileManager.default

        let specificFolderName = "mp3"
        
        
        if(fileManager.fileExists(atPath: "\(folderPath())/\(self.book._id!)/mp3/")) {
            do {
                    let attributes = try fileManager.attributesOfItem(atPath: "\(folderPath())/\(self.book._id!)/mp3/")
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
            getMP3()
        }
        

        
        
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
        
        
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)

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

            let task = session.downloadTask(with: url) { localUrl, response, error in
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

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    var startTime: Date?
    var progressBar: UIProgressView?

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // File download completed
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Calculate the remaining time
        guard let startTime = startTime else { return }
        let elapsedTime = Date().timeIntervalSince(startTime)
        let bytesPerSecond = Double(totalBytesWritten) / elapsedTime
        let remainingBytes = totalBytesExpectedToWrite - totalBytesWritten
        let remainingTime = TimeInterval(remainingBytes / Int64(bytesPerSecond))
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        // Update your UI with the remaining time
        DispatchQueue.main.async {
            // Update your UI elements with the remaining time
            self.progressBar?.progress = progress
            print("Remaining time: \(remainingTime) seconds")
        }
    }
}
