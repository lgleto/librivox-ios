import UIKit
import SSZipArchive
import SwaggerClient

class PreparePlayerAlert: UIViewController {
    
    
    enum Content {
    case empty
    case error(title: String)
    case info(title: String)
  }

  static func show(parentVC: UIViewController,
           title: String,
                   book: Audiobook,
           onCallback: ((Bool) -> Void)?)
  {
      PreparePlayerAlert.show(parentVC: parentVC, content: .error(title: title), book: book, onCallback: onCallback)
  }

  static func show(parentVC: UIViewController,
           content: Content,
                   book: Audiobook,
           onCallback: ((Bool) -> Void)?)
  {
    let storyBoard = UIStoryboard(name: "HomePage", bundle: nil)
    let vc: PreparePlayerAlert = storyBoard.instantiateViewController(withIdentifier: "PreparePlayerAlert") as! PreparePlayerAlert
    vc.content = content
      vc.book = book
    vc.callback = { yes in
      if let callback = onCallback {
        callback(yes)
      }
    }
    vc.modalTransitionStyle = .coverVertical
    vc.modalPresentationStyle = .overFullScreen

    parentVC.present(vc, animated: true, completion: nil)
  }
    
  @IBOutlet var backgroundView: UIView!
  @IBOutlet var imageIcon: UIImageView!
  @IBOutlet var labelTitle: UILabel!
   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
  var callback: ((Bool) -> Void)?
    var book: Audiobook?
    
  var content: Content = .empty

  override func viewDidLoad() {
    super.viewDidLoad()
    // imageIcon.image = imageIcon.image?.withRenderingMode(.alwaysTemplate)
    // imageIcon.tintColor = UIColor.init(named: colorAccentName)!

    // Do any additional setup after loading the view.
      
      backgroundView.layer.cornerRadius = 8
      activityIndicator.startAnimating()
      progressBar.setProgress(0.3, animated: true)
      let fileManager = FileManager.default
      let basefolder = folderPath(id: book?._id ?? "52")
      print(basefolder)
      
      if(fileManager.fileExists(atPath: basefolder)) {
          do {
              
              let attributes = try fileManager.attributesOfItem(atPath: basefolder)
                  if let type = attributes[FileAttributeKey.type] as? FileAttributeType,
                     type == FileAttributeType.typeDirectory {
                      // The specific folder exists
                      changeStatus(label: "Found audiobook, changing to Player", roundIndicatior: true, progressIndicator: 4.0)
                      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                          
                      }
                      //performSegue(withIdentifier: "PlayerToSections", sender: book)
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
          changeStatus(label: "No audiobook found, starting download", roundIndicatior: true, progressIndicator: 2.0)
          DownloadMP3()
          // The specific folder does not exist
          print("The specific folder does not exist.")
          
          
      }
  }
    func changeStatus(label:String, roundIndicatior:Bool, progressIndicator:Float) {
        self.labelTitle.text = label
        if (roundIndicatior) {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        self.progressBar.setProgress(progressIndicator/4, animated: true)
    }


  @IBAction func buttonConfirm(_ sender: Any) {
    dismiss(animated: true) {
      if let c = self.callback {
        c(true)
      }
    }
  }
   
  @IBAction func buttonCancel(_ sender: Any) {
    dismiss(animated: true) {
      if let c = self.callback {
        c(false)
      }
    }
  }
    func DownloadMP3() {
        let delegate = DownloadDelegate()
        delegate.progressBar = self.progressBar //Not working
        
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
        var basefolder = folderPath(id: book!._id!)
        guard let url = URL(string: self.book!.urlZipFile!) else {
            return
        }
         //not working

        let destinationPath = basefolder
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




