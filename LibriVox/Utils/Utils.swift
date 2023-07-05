//
//  Utils.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 03/04/2023.
//

import Foundation
import SwaggerClient
import Network
import UIKit

func showConfirmationAlert(_ view: UIViewController, _ title: String, _ msg: String? = nil){
    let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        alert.dismiss(animated: true)
        //view.navigationController?.popViewController(animated: true)
    }))
    
    view.present(alert, animated: true, completion: nil)
}

func removeHtmlTagsFromText(text: String)-> String{
    let regex = try! NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive)
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
}

func displayGenres(strings: [Genre]) -> String {
    var result = ""
    for (index, string) in strings.enumerated() {
        result += string.name ?? ""
        if index != strings.count - 1 {
            result += ", "
        }
    }
    return result
}

func createGenresArray(from string: String) -> [Genre] {
    let genreNames = string.components(separatedBy: ", ")
    let genres = genreNames.map { Genre(name: $0) }
    return genres
}


func createAuthorsArray(from string: String) -> [Author] {
    let authorNames = string.components(separatedBy: ", ")
    let authors = authorNames.map { fullName -> Author in
        let nameComponents = fullName.components(separatedBy: " ")
        let firstName = nameComponents.first ?? ""
        let lastName = nameComponents.dropFirst().joined(separator: " ")
        return Author(firstName: firstName, lastName: lastName)
    }
    return authors
}

func displayAuthors(authors: [Author]) -> String {
    var stringNames = ""
    
    for (i, author) in authors.enumerated() {
        stringNames += (author.firstName ?? "") + " " + (author.lastName ?? "")
        if i != authors.count - 1 {
            stringNames += ", "
        }
    }
    
    return stringNames
}

func secondsToMinutes(seconds: Int) -> Int{
    return seconds/60
}

func imageWith(name: String?) -> UIImage? {
    let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    let nameLabel = UILabel(frame: frame)
    nameLabel.textAlignment = .center
    nameLabel.textColor = .white
    nameLabel.font = UIFont.boldSystemFont(ofSize: 64)
    
    var initials = ""
    if let initialsArray = name?.components(separatedBy: " ") {
        if let firstWord = initialsArray.first {
            if let firstLetter = firstWord.first {
                initials += String(firstLetter).capitalized }
        }
        if initialsArray.count > 1, let lastWord = initialsArray.last {
            if let lastLetter = lastWord.first { initials += String(lastLetter).capitalized
            }
        }
    } else {
        return nil
    }
    
    nameLabel.text = initials
    UIGraphicsBeginImageContext(frame.size)
    if let currentContext = UIGraphicsGetCurrentContext() {
        nameLabel.layer.render(in: currentContext)
        let nameImage = UIGraphicsGetImageFromCurrentImageContext()
        return nameImage
    }
    return nil
}


class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let authorPhotoCache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        authorPhotoCache.countLimit = 100
    }
    
    func image(for id: String) -> UIImage? {
        return cache.object(forKey: id as NSString)
    }
    
    func insertImage(_ image: UIImage?, for id: String) {
        guard let image = image else {
            cache.removeObject(forKey: id as NSString)
            return
        }
        
        cache.setObject(image, forKey: id as NSString)
    }
    
    func authorPhoto(for id: String) -> UIImage? {
        return authorPhotoCache.object(forKey: id as NSString)
    }
    
    func insertAuthorPhoto(_ image: UIImage?, for id: String) {
        guard let image = image else {
            authorPhotoCache.removeObject(forKey: id as NSString)
            return
        }
        
        authorPhotoCache.setObject(image, forKey: id as NSString)
    }
}

func getCoverBook(id: String, url: String? = nil, _ callback: @escaping (UIImage?) -> Void) {
    if let cachedImage = loadImageFromDocumentDirectory(id: id) {
        callback(cachedImage)
    } else if let cachedImage = ImageCache.shared.image(for: (id as NSString) as String){
        callback(cachedImage)
    }else{
        guard let imageURL = URL(string: url ?? "") else {
            callback(nil)
            return
        }
        getBookCoverFromURL(url: url) { fetchedImageURL in
            guard let fetchedImageURL = fetchedImageURL else {
                callback(nil)
                return
            }
            ImageCache.shared.insertImage(fetchedImageURL, for: (id as NSString) as String)
            callback(fetchedImageURL)
        }
    }
}



func getBookCoverFromURL(url: String?, _ callback: @escaping (UIImage?) -> Void){
    guard let url = URL(string: url ?? "") else{return}
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let session = URLSession(configuration: .default)
    session.dataTask(with: request) { data, response, error in
        
        if let data = data, let contents = String(data: data, encoding: .ascii) {
            if let range = contents.range(of: #"<img\s+src="([^"]+)".+?alt="book-cover-large".+?>"#, options: .regularExpression) {
                guard let imageURL =  URL(string: String(contents[range].split(separator: "\"")[1])) else{callback(nil)
                    return
                }
                if let imageData = try? Data(contentsOf: imageURL) {
                    let image = UIImage(data: imageData)
                    callback(image)
                } else {
                    callback(nil)
                }
            }
        } else {
            callback(nil)
        }
        
    }.resume()
}

func isImageSavedInDocumentDirectory(id: String) -> Bool {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let imgBooksDirectory = documentsDirectory.appendingPathComponent("ImgBooks")
    let fileURL = imgBooksDirectory.appendingPathComponent(id)
    
    return fileManager.fileExists(atPath: fileURL.path)
}

func downloadAndSaveImage(id: String, completion: @escaping (Bool) -> Void) {
    let imageRef = storage.child("BookCover/\(id).jpg")
    
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(false)
            }
        } else if let imageData = data, let image = UIImage(data: imageData) {
            saveImageToDocumentDirectory(id: id, image: image)
            DispatchQueue.main.async {
                completion(true)
            }
        } else {
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}


func saveImageToDocumentDirectory(id: String, image: UIImage) {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let imgBooksDirectory = documentsDirectory.appendingPathComponent("ImgBooks")
    
    if !fileManager.fileExists(atPath: imgBooksDirectory.path) {
        do {
            try fileManager.createDirectory(at: imgBooksDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating ImgBooks directory:", error)
            return
        }
    }
    
    let fileURL = imgBooksDirectory.appendingPathComponent(id)
    
    if !fileManager.fileExists(atPath: fileURL.path) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
            } catch {
                print("Error saving image:", error)
            }
        }
    }
}

func loadImageFromDocumentDirectory(id: String) -> UIImage? {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let imageURL = documentsDirectory.appendingPathComponent("ImgBooks").appendingPathComponent(id)
    
    guard fileManager.fileExists(atPath: imageURL.path) else {
        return nil
    }
    
    if let image = UIImage(contentsOfFile: imageURL.path) {
        return image
    }
    return nil
}



func getPhotoAuthor(authorId: String?, _ callback: @escaping (UIImage?) -> Void) {
    
    let defaultAuthorPhoto = UIImage(systemName: "person.crop.square")?.withTintColor(.systemGray4, renderingMode: .alwaysOriginal)
    guard let authorId = authorId else {
        DispatchQueue.main.async {
            callback(defaultAuthorPhoto)}
        return
    }
    
    if let cachedImage = ImageCache.shared.authorPhoto(for: authorId) {
        DispatchQueue.main.async {
            callback(cachedImage)
        }
    } else {
        getWikipediaLink(authorId: authorId) { title in
            guard let title = title else {
                ImageCache.shared.insertAuthorPhoto(defaultAuthorPhoto, for: authorId)
                callback(defaultAuthorPhoto)
                return
            }
            
            let name = title.lastPathComponent
            getMainImageFromWikipedia(name: name) { imgC in
                if let imgC = imgC {
                    DispatchQueue.main.async {
                        callback(imgC)
                    }
                    ImageCache.shared.insertAuthorPhoto(imgC, for: authorId)
                } else {
                    DispatchQueue.main.async {
                        callback(defaultAuthorPhoto)
                    }
                }
            }
            
        }
    }
}

func getWikipediaLink(authorId: String, _ callback: @escaping (URL?) -> Void) {
    var request = URLRequest(url: URL(string: "https://librivox.org/author/\(authorId)")!)
    request.httpMethod = "GET"
    
    let session = URLSession.init(configuration: URLSessionConfiguration.default)
    session.dataTask(with: request) { data, response, error in
        if let data = data, let contents = String(data: data, encoding: .utf8) {
            if let range = contents.range(of: #"<a\s+href="([^"]+)">Wiki - [^<]+</a>"#, options: .regularExpression) {
                let wikiURL = String(contents[range].split(separator: "\"")[1])
                callback(URL(string: wikiURL))
            } else {
                callback(nil)
            }
        } else {
            print("Error: \(error?.localizedDescription ?? "unknown error")")
            callback(nil)
        }
    }.resume()
}



func getMainImageFromWikipedia(name: String,_ callback: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: "https://en.wikipedia.org/w/api.php?action=query&titles=\(name)&prop=pageimages&format=json&piprop=original") else {
        print("Error: Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task = session.dataTask(with: request) { (data, response, error) in
        DispatchQueue.main.async {
            guard let data = data else {
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                callback(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let query = json["query"] as? [String: Any],
                   let pages = query["pages"] as? [String: Any],
                   let page = pages.values.first as? [String: Any],
                   let props = page["original"] as? [String: Any],
                   let originalURLString = props["source"] as? String,
                   let url = URL(string: originalURLString) {
                    if let imageData = try? Data(contentsOf: url) {
                        let image = UIImage(data: imageData)
                        callback(image)
                    } else {callback(nil)}
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                callback(nil)
            }
        }
    }
    task.resume()
}



func setImageNLabelAlert(view : UIScrollView, img : UIImage, text: String){
    let templateImage = img.withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: templateImage)
    imageView.contentMode = .scaleAspectFill
    imageView.tintColor = UIColor.lightGray
    imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    
    let label = UILabel()
    label.text = text
    label.textAlignment = .center
    label.numberOfLines = 0
    label.textColor = UIColor.lightGray
    label.font = UIFont(name: "Nunito", size: 17)
    
    let stackView = UIStackView(arrangedSubviews: [imageView, label])
    stackView.axis = .vertical
    stackView.spacing = 15
    
    view.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
}


func checkAndUpdateEmptyState<T>(list:[T], alertImage: UIImage, view: UIScrollView, alertText: String) {
    list.count > 0 ? removeImageNLabelAlert(view: view) : setImageNLabelAlert(view: view, img: alertImage, text: alertText)
}

func removeImageNLabelAlert(view: UIScrollView) {
    for subview in view.subviews {
        if let stackView = subview as? UIStackView {
            stackView.removeFromSuperview()
            return
        }
    }
}


func stringFormatted(textBold: String, textRegular: String, size: CGFloat) -> NSMutableAttributedString{
    let attrsBold = [NSAttributedString.Key.font : UIFont(name: "Nunito ExtraLight SemiBold", size: size)]
    let attributedString = NSMutableAttributedString(string:textBold, attributes:attrsBold)
    
    let attrsLight = [NSAttributedString.Key.font : UIFont(name: "Nunito ExtraLight Light", size: size)]
    let normalString = NSMutableAttributedString(string: textRegular, attributes: attrsLight)
    
    attributedString.append(normalString)
    
    return attributedString
}

func stringToColor(color: String) -> UIColor {
    guard let i = UInt(color, radix: 16) else {
        return UIColor.white
    }
    return UIColor(
        red: CGFloat((i & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((i & 0xFF00) >> 8) / 255.0,
        blue: CGFloat(i & 0xFF) / 255.0,
        alpha: 1.0
    )
}

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}


protocol NetworkCheckObserver: class {
    func statusDidChange(status: NWPath.Status)
}

class NetworkCheck {
    
    struct NetworkChangeObservation {
        weak var observer: NetworkCheckObserver?
    }
    
    private var monitor = NWPathMonitor()
    private static let _sharedInstance = NetworkCheck()
    private var observations = [ObjectIdentifier: NetworkChangeObservation]()
    var currentStatus: NWPath.Status {
        get {
            return monitor.currentPath.status
        }
    }
    
    class func sharedInstance() -> NetworkCheck {
        return _sharedInstance
    }
    
    init() {
        monitor.pathUpdateHandler = { [unowned self] path in
            for (id, observations) in self.observations {
                
                //If any observer is nil, remove it from the list of observers
                guard let observer = observations.observer else {
                    self.observations.removeValue(forKey: id)
                    continue
                }
                
                DispatchQueue.main.async(execute: {
                    observer.statusDidChange(status: path.status)
                })
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    func addObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = NetworkChangeObservation(observer: observer)
    }
    
    func removeObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
    
}

func folderPath(id:String) -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let docURL = URL(string: "\(documentsDirectory)/\(id)/mp3")!
    print("Datapath ->", docURL.absoluteString)
    //let dataPath = docURL.appendingPathComponent("/mp3")
    return docURL.absoluteString
}

func documentPath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    //let dataPath = docURL.appendingPathComponent("/mp3")
    return documentsDirectory
}

func millisToTime(_ timeMillis: Int) -> String {
    let seconds = abs(timeMillis / 1000)
    let minutes: Int = seconds / 60
    return String(format: "%02d:%02d", (minutes % 60), (seconds % 60))
}

func secondsToTime(_ seconds: Int) -> String {
    let minutes: Int = seconds / 60
    return String(format: "%02d:%02d", (minutes % 60), (seconds % 60))
}

func secondsToMillis(_ seconds: Int) -> Float {
    return Float(seconds * 1000)
}

func downloadImage(url: URL, imageView: UIImageView) {
    
    getDataFromUrl(url: url) { (data, response, error)  in
        guard let data = data, error == nil else {
            return
        }
        DispatchQueue.main.async() { () -> Void in
            imageView.alpha = 0.0
            UIView.transition(with: imageView, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                imageView.image = UIImage(data: data)
                imageView.alpha = 1.0;
            }, completion: nil)
        }
    }
}

func downloadImage(url: URL, callback: @escaping  (UIImage)->() ) {
    getDataFromUrl(url: url) { (data, response, error)  in
        guard let data = data, error == nil else {
            return
        }
        DispatchQueue.main.async() { () -> Void in
            callback(UIImage(data: data) ?? UIImage())
        }
    }
}

func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
        completion(data, response, error)
    }.resume()
}

func showProgressBarAlert(_ view: UIViewController) {
    // Create a UIAlertController
    let alertController = UIAlertController(title: "Progress", message: "Please wait...", preferredStyle: .alert)
    
    alertController.preferredContentSize = CGSize(width: 300, height: 250)
    
    
    // Create a UIProgressView
    let progressView = UIProgressView(progressViewStyle: .default)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    
    // Add the progress view to the alert controller
    alertController.view.addSubview(progressView)
    
    // Add constraints to center the progress view
    progressView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 8).isActive = true
    progressView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -8).isActive = true
    progressView.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor, constant: 32).isActive = true
    //alertController.view.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
    // Adjust the constant value as needed
    
    // Adjust the frame of the progress view to create additional space below it
    progressView.frame = CGRect(x: progressView.frame.origin.x,
                                y: progressView.frame.origin.y,
                                width: progressView.frame.size.width,
                                height: progressView.frame.size.height + 150) // Adjust the height as needed
    
    // Adjust the width as needed
    
    
    // Start the progress animation
    progressView.setProgress(0.3, animated: true)
    
    // Present the alert controller
    view.present(alertController, animated: true, completion: nil)
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

func bitToMegabyteString(_ bits:Int64) -> String {
    let megabytes = bits / 8 / 1024 / 1024
    let correctString = "\(megabytes)MB"
    return correctString
}

func filePathFromDownloadUrl2(url:URL) -> URL {
    let componenents = url.pathComponents
    let lastpathComponent = componenents.last
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let filePath = URL(fileURLWithPath: documentsURL.absoluteString).appendingPathComponent(lastpathComponent!)
    return filePath
}

func getFilesInFolder(folderPath: String) -> [String]? {
    do {
        let fileManager = FileManager.default
        let fileURLs = try fileManager.contentsOfDirectory(atPath: folderPath)
        
        // Sort the file names in alphabetical order
        let sortedFileNames = fileURLs.sorted()
        return sortedFileNames
    } catch {
        print("Error while getting the files: \(error.localizedDescription)")
        return nil
    }
}

func checkIfFileExists(book:Audiobook) -> Bool {
    let fileManager = FileManager.default
    let basefolder = folderPath(id: book._id!)
    print(basefolder)
    
    if(fileManager.fileExists(atPath: basefolder)) {
        do {
            
            let attributes = try fileManager.attributesOfItem(atPath: basefolder)
            if let type = attributes[FileAttributeKey.type] as? FileAttributeType,
               type == FileAttributeType.typeDirectory {
                // The specific folder exists
                print("The specific folder exists.")
                return true
                //
                
            } else {
                // A file with the same name exists, but it's not a folder
                print("A file with the same name exists, but it's not a folder.")
                return false
                
            }
        } catch {
            print("Error: \(error)")
            return false
            // Error occurred while retrieving attributes
            
        }
    } else {
        // The specific folder does not exist
        print("The specific folder does not exist.")
        return false
        
        
    }
}

func titlePlayer(bookTitle: String, sectionTitle: String) -> String {
    let finalTitle = ("\(bookTitle) - \(sectionTitle)")
    return finalTitle
}


protocol PlayableItemProtocol {
    var _id      : String?    { get set }
    var title    : String?   { get set }
    var imageUrl : String?   { get set }
    var urlZipFile  : String?   { get set }
    var timeStopped : Int?      { get set }
    var sectionStopped : String?     { get set }
    var isFav : Bool?     { get set }
    var sections : [Section]? { get set }
}

extension Audiobook : PlayableItemProtocol {
}

/*extension AudioBooks_Data: PlayableItemProtocol {
 var _id: String? {
 get { return id }
 set { id = newValue }
 }
 
 var timeStopped: Int? {
 get { return Int(timeStopped ?? 0) }
 set { timeStopped = newValue != nil ? Int(Int32(newValue!)) : 0 }
 }
 
 var isFav: Bool? {
 get { return isFav }
 set { isFav = newValue! }
 }
 
 
 /* var sections: [Section]? {
  get {
  if let sectionsSet = sections as? Set<Section> {
  return Array(sectionsSet)
  }
  return nil
  }
  set {
  if let newValue = newValue {
  sections = NSSet(array: newValue)
  } else {
  sections = nil
  }
  }
  }*/
 }*/



