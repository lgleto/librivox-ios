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
                   book: PlayableItemProtocol,
           onCallback: ((Bool, PlayableItemProtocol) -> Void)?)
  {
      PreparePlayerAlert.show(parentVC: parentVC, content: .error(title: title), book: book, onCallback: onCallback)
  }

  static func show(parentVC: UIViewController,
           content: Content,
                   book: PlayableItemProtocol,
           onCallback: ((Bool,PlayableItemProtocol) -> Void)?)
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
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var expectedBytes: UILabel!
    @IBOutlet weak var currentBytes: UILabel!
    
    
  var callback: ((Bool , PlayableItemProtocol) -> Void)?
    var book: PlayableItemProtocol?
    
  var content: Content = .empty

    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // imageIcon.image = imageIcon.image?.withRenderingMode(.alwaysTemplate)
    // imageIcon.tintColor = UIColor.init(named: colorAccentName)!

    // Do any additional setup after loading the view.
      if let image = loadImageFromDocumentDirectory(id: (book?._id)!){
          print("oii")
      } else if let cachedImage = ImageCache.shared.image(for: (book?._id)!){
          saveImageToDocumentDirectory(id: (book?._id)!, image: cachedImage)
      }
      
      progressBar.setProgress(0.3, animated: true)
      DownloadMP3()
  }
    
    private func getCoverBook2(id: String, url: String, _ callback: @escaping (UIImage?) -> Void) {
        
    }
    
    func changeStatus(label:String, roundIndicatior:Bool, progressIndicator:Float) {
        //
        //self.labelTitle.text = label
        self.progressBar.setProgress(progressIndicator/4, animated: true)
        self.infoLabel.text = label
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
        guard let url = URL(string: self.book!.urlZipFile!) else {
            return
        }
        
        let baseUrl = filePathFromDownloadUrl2(url: URL(string: self.book!.urlZipFile!)!)
        let destinationPath = folderPath(id: book!._id!)
        
        DownloadManager.shared.addDownload(url: url, destinationURL: baseUrl) { progress, currentBits, expectedBits in
            DispatchQueue.main.async {
                self.progressBar.progress = progress
                self.currentBytes.text = bitToMegabyteString(currentBits)
                self.expectedBytes.text = bitToMegabyteString(expectedBits)
            }
        } onCompletion: { error, _, localURL in
            if let error = error {
                print("Error downloading file: \(error.localizedDescription)")
                return
            }
            
            let fileManager = FileManager.default
            do {
                if !fileManager.fileExists(atPath: destinationPath) {
                    try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
                }
                
                do {
                    try SSZipArchive.unzipFile(atPath: localURL.path, toDestination: destinationPath, overwrite: true, password: nil)
                    do {
                        try fileManager.removeItem(at: baseUrl)
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                if let callback = self.callback {
                                    callback(false, self.book!)
                                }
                            }
                        }
                    } catch {
                        print("Error removing zip file")
                    }
                } catch {
                    print("Error extracting zip file: \(error.localizedDescription)")
                }
            } catch {
                print("Error creating destination directory: \(error.localizedDescription)")
            }
        }
    }



}




