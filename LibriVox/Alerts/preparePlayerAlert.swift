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
           onCallback: ((Bool, Audiobook) -> Void)?)
  {
      PreparePlayerAlert.show(parentVC: parentVC, content: .error(title: title), book: book, onCallback: onCallback)
  }

  static func show(parentVC: UIViewController,
           content: Content,
                   book: Audiobook,
           onCallback: ((Bool,Audiobook) -> Void)?)
  {
    let storyBoard = UIStoryboard(name: "HomePage", bundle: nil)
    let vc: PreparePlayerAlert = storyBoard.instantiateViewController(withIdentifier: "PreparePlayerAlert") as! PreparePlayerAlert
    vc.content = content
      vc.book = book
    vc.callback = { yes, book in
      if let callback = onCallback {
        callback(yes, book)
      }
    }
    vc.modalTransitionStyle = .coverVertical
    vc.modalPresentationStyle = .overFullScreen

    parentVC.present(vc, animated: true, completion: nil)
  }
    
  //@IBOutlet var imageIcon: UIImageView!
  //@IBOutlet var labelTitle: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var expectedBytes: UILabel!
    @IBOutlet weak var currentBytes: UILabel!
    
    
  var callback: ((Bool , Audiobook) -> Void)?
    var book: Audiobook?
    
  var content: Content = .empty

  override func viewDidLoad() {
    super.viewDidLoad()
    // imageIcon.image = imageIcon.image?.withRenderingMode(.alwaysTemplate)
    // imageIcon.tintColor = UIColor.init(named: colorAccentName)!

    // Do any additional setup after loading the view.
      
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
                          self.dismiss(animated: true) {
                          if let c = self.callback {
                              c(false, self.book!)
                          }
                        }

                      }
                      //
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
        //
        //self.labelTitle.text = label
        self.progressBar.setProgress(progressIndicator/4, animated: true)
    }


  @IBAction func buttonConfirm(_ sender: Any) {
      if let c = self.callback {
          c(true, self.book!)
      }
  }
    
   
  @IBAction func buttonCancel(_ sender: Any) {
      DownloadManager.shared.cancelDownload()
      dismiss(animated: true) {
      if let c = self.callback {
          c(false, self.book!)
      }
    }
      
  }
    func DownloadMP3() {
        let fileManager = FileManager()
        
        guard let url = URL(string: self.book!.urlZipFile!) else {
            return
        }
        
         let baseUrl = filePathFromDownloadUrl2(url: URL(string: self.book!.urlZipFile!)!)
        
        let destinationPath = folderPath(id: book!._id!)

        DownloadManager.shared.addDownload(url: url, destinationURL: baseUrl) { progress, currentBits, expectedBits in
            self.progressBar.progress = progress
            self.currentBytes.text = bitToMegabyteString(currentBits)
            self.expectedBytes.text = bitToMegabyteString(expectedBits)
        } onCompletion: { err, url, localURL in
            do {
                if !fileManager.fileExists(atPath: destinationPath) {
                    try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
                }
                do {
                    try SSZipArchive.unzipFile(atPath: localURL.path, toDestination: destinationPath, overwrite: true, password: nil)
                    do {
                        try fileManager.removeItem(at: baseUrl)
                        self.dismiss(animated: true) {
                        if let c = self.callback {
                            c(false, self.book!)
                        }
                      }
                    } catch {
                        print("Error removing rar file")
                    }
                } catch {
                    print("Error extracting zip file: \(error.localizedDescription)")
                }
            } catch {
                print("Error moving zip file: \(error.localizedDescription)")
            }
        }
        
    }


}




