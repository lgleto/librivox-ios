//
//  Utils.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 03/04/2023.
//

import Foundation
import SwaggerClient
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


func getUserInfo(_ field: UserData,_ callback: @escaping (String?) -> Void) {
    let db = Firestore.firestore()
    
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    userRef.getDocument { (document, error) in
        if let error = error {
            print("Error getting user document: \(error.localizedDescription)")
            callback(nil)
        } else if let document = document, document.exists {
            let data = document.data()
            let name = data?["\(field)"] as? String
            callback(name)
        } else {
            print("User document does not exist")
            callback(nil)
        }
    }
}

func updateUserInfo(name: String, username: String, email: String) {
    let db = Firestore.firestore()
    var dataToUpdate = [String: Any]()
    
    dataToUpdate = [
        UserData.name.rawValue: name,
        UserData.username.rawValue: username,
        UserData.email.rawValue: email
    ]
    
    db.collection("users").document(Auth.auth().currentUser!.uid).updateData(dataToUpdate) { err in
        if let err = err {
            print("Error writing document: \(err.localizedDescription)")
        } else {
            print("Document successfully updated!")
        }
    }
}

func showAlert(_ view : UIViewController,_ message: String) {
    let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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


func getGenresFromDb(callback: @escaping ([GenreWithColor]) -> Void){
    var db = Firestore.firestore()
    let genresRef = db.collection("genres")
    
    genresRef.getDocuments{(querySnapshot, err) in
        if let error = err{
            print("Error: \(err?.localizedDescription)")
            return
        }
        else
        {
            let genres = querySnapshot!.documents.compactMap { document -> GenreWithColor? in
                guard let id = document.data()["id"] as? String,
                      let name = document.data()["name"] as? String,let mainColor = document.data()["mainColor"] as? String,let secondaryColor = document.data()["secondaryColor"] as? String,let descr = document.data()["description"] as? String?
                else {
                    print("Invalid data format for document \(document.documentID)")
                    return nil
                }
                return GenreWithColor(_id: id, name: name, mainColor: mainColor, secondaryColor: secondaryColor, descr: descr)
                
            }
            
            callback(genres)
        }
        
    }
}
func getBooksFromUser(isReading: Bool? = nil, isFavorite: Bool? = nil, completion: @escaping ([Audiobook]) -> Void) {
    
    var finalList: [Audiobook] = []
    
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
    let bookCollectionRef = userRef.collection("bookCollection")
    
    bookCollectionRef.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error getting documents: \(error.localizedDescription)")
            return
        }
        
        guard let documents = querySnapshot?.documents else {
            print("No documents found")
            return
        }
        
        for document in documents {
            if let book = BookUser(data: document.data()) {
                
                if let isReading = isReading, book.isReading != isReading {
                    continue
                }
                
                if let isFavorite = isFavorite, book.isFav != isFavorite {
                    continue
                }
                
                DefaultAPI.audiobooksIdBookIdGet(bookId: Int64(book.id)!, format: "json", extended: 1) { data, error in
                    if let error = error {
                        print("Error:", error.localizedDescription)
                        return
                    }
                    if let data = data {
                        finalList.append(contentsOf: data.books!)
                        print(data)
                    }
                    
                    completion(finalList)
                }
            }
        }
    }
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

func downloadProfileImage(_ name: String, _ imageView: UIImageView) {
    let storageRef = Storage.storage().reference()
    let imageRef = storageRef.child("images/\(Auth.auth().currentUser!.uid)/userPhoto")
    
    let defaultImage = imageWith(name: name)
    imageView.image = defaultImage
    imageView.backgroundColor = UIColor(named: "Green Tone")
    
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
        } else {
            if let imageData = data {
                imageView.image = UIImage(data: imageData)
            }
        }
    }
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
