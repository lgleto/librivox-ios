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


func getCoverBook(id: String, url: String, _ callback: @escaping (UIImage?) -> Void) {
    if let image = loadImageFromDocumentDirectory(id: id){
        print("foi do diretorio")
        callback(image)
    }else{
        getBookCoverFromURL(url: url){image in
            guard let image = image else{return}
            callback(image)
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
                let imageURL = String(contents[range].split(separator: "\"")[1])
                if let imageData = try? Data(contentsOf: URL(string: imageURL)!) {
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


func getPhotoAuthor(authorId: String, _ callback: @escaping (URL?) -> Void){
    getWikipediaLink(authorId: authorId){ title in
        
        let name = title.lastPathComponent
        getMainImageFromWikipedia(name: name){imgC in
            if let imgC = imgC{
                callback(imgC)
                
            }else{
                callback(nil)
            }
        }
    }
}

func getWikipediaLink(authorId: String, _ callback: @escaping (URL) -> Void){
    var request = URLRequest(url: URL(string: "https://librivox.org/author/\(authorId)")!)
    request.httpMethod = "GET"
    
    let session = URLSession.init(configuration: URLSessionConfiguration.default)
    session.dataTask(with: request) { data, response, error in
        if let data = data, let contents = String(data: data, encoding: .ascii) {
            if let range = contents.range(of: #"<a\s+href="([^"]+)">Wiki - [^<]+</a>"#, options: .regularExpression) {
                let wikiURL = String(contents[range].split(separator: "\"")[1])
                if let url = URL(string: wikiURL) {
                    callback(url)
                }
            }
        } else {
            print("Error: \(error?.localizedDescription ?? "unknown error")")
        }
    }.resume()
}



func getMainImageFromWikipedia(name: String,_ callback: @escaping (URL?) -> Void) {
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
                    callback(url)
                    
                } else {
                    callback(nil)
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


func checkAndUpdateEmptyState(list: [Audiobook], alertImage: UIImage, view: UIScrollView, alertText: String) {
    list.isEmpty ? setImageNLabelAlert(view: view, img: alertImage, text: alertText) : removeImageNLabelAlert(view: view)
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

func folderPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        //let dataPath = docURL.appendingPathComponent("/mp3")
        return docURL.absoluteString
    }

func millisToTime(_ timeMillis: Int) -> String {
    let seconds = abs(timeMillis / 1000)
    let minutes: Int = seconds / 60
    return String(format: "%02d:%02d", (minutes % 60), (seconds % 60))
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
