//
//  DownloadVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 22/05/2023.
//

import UIKit
import SwaggerClient

class DownloadVC: UIViewController {

    @IBOutlet weak var progressIndicator: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelInfo: UILabel!
    var isRunning = false
    var book : Audiobook?
    var statusChangeCache = [ActivityCache]()
    override func viewDidLoad() {
        super.viewDidLoad()

        let fileManager = FileManager.default
        let basefolder = folderPath(id:  "52")
        print(basefolder)

        if(fileManager.fileExists(atPath: basefolder)) {
            do {
                
                let attributes = try fileManager.attributesOfItem(atPath: basefolder)
                    if let type = attributes[FileAttributeKey.type] as? FileAttributeType,
                       type == FileAttributeType.typeDirectory {
                        // The specific folder exists
                        changeStatus20(label: "Found audiobook", roundIndicatior: true, progressIndicator: 4.0)
                        hideStatus()
                        performSegue(withIdentifier: "PlayerToSections", sender: book)
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
            changeStatus20(label: "No audiobook found, starting download", roundIndicatior: true, progressIndicator: 2.0)
            // The specific folder does not exist
            print("The specific folder does not exist.")
            
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomepageToTrendingBooks") {
            
        } else if (segue.identifier == "downloadToSections"){
            let destVC = segue.destination as! SectionsTVC
            destVC.book = sender as? Audiobook
        }
        
    }
    
    func changeStatus20(label:String, roundIndicatior:Bool, progressIndicator:Float) {
        self.labelInfo.text = label
        if (roundIndicatior) {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        self.progressIndicator.setProgress(progressIndicator/4, animated: true)
    }
    
    func changeStatus(label:String, roundIndicatior:Bool, progressIndicator:Float) {
        self.statusChangeCache.append(ActivityCache(label: label, roundIndicator: roundIndicatior, progressIndicator: progressIndicator))
        if(self.isRunning == false){
            self.isRunning = true
            delayChange()
        }
        
        
    }
    
    func delayChange( onCompelition : (()->())? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            if let status = self.statusChangeCache.first {
                self.labelInfo.text = status.label
                if (status.roundIndicator) {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
                self.progressIndicator.setProgress(status.progressIndicator/4, animated: true)
                
                self.delayChange(onCompelition: onCompelition)
                
            } else {
                if let c = onCompelition{
                    self.isRunning = false
                    c()
                }
            }
        }
    }
    
    
    func hideStatus() {
        self.labelInfo.isHidden = true
        self.activityIndicator.isHidden = true
        self.progressIndicator.isHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

struct ActivityCache{
    var label: String = ""
    var roundIndicator: Bool = true
    var progressIndicator: Float = 0.0
    
}
