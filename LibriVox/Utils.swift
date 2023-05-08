//
//  Utils.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 03/04/2023.
//

import Foundation
import SwaggerClient
import Kingfisher

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

func getCoverBook(url: String, _ callback: @escaping (URL?) -> Void){
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    
    let session = URLSession.init(configuration: URLSessionConfiguration.default)
    session.dataTask(with: request) {data,response,error in
        
        if let data = data, let contents = String(data: data, encoding: .ascii) {
            if let range = contents.range(of: #"<img\s+src="([^"]+)".+?alt="book-cover-large".+?>"#, options: .regularExpression) {
                let imageURL = String(contents[range].split(separator: "\"")[1])
                callback(URL(string: imageURL))
            }
            
        } else {
            print("Error: \(error?.localizedDescription ?? "unknown error")")
        }
        
    }.resume()
}

func getPhotoAuthor(authorId: String, _ callback: @escaping (URL?) -> Void){
    getWikipediaLink(authorId: authorId){ title in
        
        let name = title.lastPathComponent
        getMainImageFromWikipedia(name: name){imgC in
            
            if let imgC = imgC{
              //  img.kf.setImage(with: imgC)
              //  img.contentMode = .scaleAspectFill
                callback(imgC)
                
            }else{
                callback(nil)
                //img.image =  imageWith(name: name)
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

func removeImageNLabelAlert(view: UIScrollView) {
    for subview in view.subviews {
        if let stackView = subview as? UIStackView {
            stackView.removeFromSuperview()
            return
        }
    }
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
