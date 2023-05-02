//
//  Utils.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 03/04/2023.
//

import Foundation
import SwaggerClient
import FirebaseFirestore
import FirebaseAuth


func getNameOrUserName(_ field: String,_ callback: @escaping (String?) -> Void) {
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

func getCoverFromBook(url: String, _ callback: @escaping (URL?) -> Void){
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
func addDescr(){
    let genresRef = Firestore.firestore().collection("genres")
    let genres: [String: String] = [
        "Epics": "Long narrative poems that typically celebrate heroic deeds and legendary events.",
        "Fantastic Fiction": "Fictional stories that involve elements of fantasy, such as magic or mythical creatures.",
        "Historical Fiction": "Fictional stories that are set in a specific time period in history and often incorporate real events or people.",
        "Poetry": "Literary works that use language to evoke emotion and imagery through the use of meter, rhyme, and other techniques.",
        "Epistolary Fiction": "Fictional stories that are told through a series of letters or diary entries.","Action & Adventure Fiction": "Fictional stories that are focused on exciting and often dangerous events or exploits.",
        "Romance": "Fictional stories that focus on romantic relationships and emotions.",
        "Travel & Geography": "Non-fiction works that describe places, cultures, and landscapes around the world.",
        "Literary Fiction": "Fictional stories that are focused on the artistry of writing and often explore complex themes and ideas.",
        "Multi-version (Weekly and Fortnightly poetry)": "Poetry that is published on a regular schedule, often in installments.",
        "General Fiction": "Fictional stories that do not fit neatly into a specific genre or category.",
        "Crime & Mystery Fiction": "Fictional stories that are focused on solving a crime or uncovering a mystery.",
        "Sonnets": "Poems that have a specific form, consisting of 14 lines and a rhyme scheme.",
        "Children's Fiction": "Fictional stories that are intended for a young audience.",
        "Nautical & Marine Fiction": "Fictional stories that are set on or around the ocean.",
        "Religion": "Non-fiction works that explore religious beliefs and practices.",
        "Humorous Fiction": "Fictional stories that are intended to be funny or humorous.",
        "War & Military": "Fictional stories that are set during times of war or conflict and often focus on military themes.",
        "Myths, Legends & Fairy Tales": "Stories that involve mythical or magical elements and are often passed down through generations.",
        "Psychology": "Non-fiction works that explore human behavior and the mind.",
        "Biography & Autobiography": "Non-fiction works that tell the story of a person's life.",
        "Satire": "Literary works that use humor or irony to criticize society or human behavior.",
        "Philosophy": "Non-fiction works that explore the nature of reality, knowledge, and existence.",
        "Animals & Nature": "Non-fiction works that explore the natural world and its inhabitants.",
        "Non-fiction": "Works of literature that are based on real events or information.",
        "Astronomy, Physics & Mechanics": "Non-fiction works that explore the scientific principles of the natural world.",
        "Classics (Greek & Latin Antiquity)": "Works of literature from the ancient Greek and Roman civilizations.",
        "Published 1900 onward": "Literature that has been published since the turn of the 20th century."
    ]
    
    for (key, value) in genres {
        genresRef.whereField("name", isEqualTo: key).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documentID for \(key): \(error.localizedDescription)")
                return
            }
            
            guard let documentID = snapshot?.documents.first?.documentID else {
                print("DocumentID not found for \(key)")
                return
            }
            
            genresRef.document(documentID).setData(["description": value], merge: true) { (error) in
                if let error = error {
                    print("Error updating description for \(key): \(error.localizedDescription)")
                    return
                }
                
                print("Description added for \(key)")
            }
        }
    }
}

func addColorToGenre(){
    let baseColors = ["#CEB3E0", "#E5CDBE", "#D5B3E5", "#C1D5C7", "#A9C7E0", "#E5E4C1", "#E5BED1", "#D5B3A9", "#B3E5BE", "#B3D5E5", "#E5A9C1", "#B3E5A9", "#E0DCCD", "#BEBCE5", "#E5B3D5", "#F2DCC1", "#A9FFE5", "#E5CDBE", "#B39FDD", "#B3D5A9", "#BEC1E5", "#9FA9D5", "#F2B6B5", "#E5BEFF", "#A9C7FF", "#C7E5A9", "#B3E5B3", "#D6C1A9", "#E5B3E5", "#A9B3E5"]
    
    let lighterColors = ["#E6D4F2", "#F2E6E0", "#F1E6F2", "#E4F2E3", "#D4E6F1", "#F2F1E6", "#F2E0E6", "#F1E6D4", "#E6F2E0", "#E6F1F2", "#F2D4E6", "#E6F2D4", "#F4F1DE", "#E6E4F2", "#F2E6F1", "#F7E7CE", "#D4F2E6", "#F2E6E4", "#E6D4EF", "#E6F1D4", "#E0E6F2", "#D4F1E6", "#F7CAC9", "#E6E0F2", "#D4E6F2", "#E4F2E6", "#E6F2E6", "#EFE6D4", "#F2E6F2", "#E0E6F2"]
    
    let genresRef = Firestore.firestore().collection("genres")
    genresRef.getDocuments { querySnapshot, error in
        if let error = error {
            print("Error getting documents: \(error)")
        } else {
            let genres = querySnapshot!.documents
            for (index, genre) in genres.enumerated() {
                let mainColor = baseColors[index]
                let secondaryColor = lighterColors[index]
                genresRef.document(genre.documentID).updateData([
                    "mainColor": mainColor,
                    "secondaryColor": secondaryColor
                ]) { error in
                    if let error = error {
                        print("Error updating genre document: \(error)")
                    } else {
                        print("Genre document updated successfully")
                    }
                }
            }
        }
    }
    
}

