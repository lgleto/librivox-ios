//
//  AuthorPageVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 17/04/2023.
//

import UIKit
import SwaggerClient

class AuthorPageVC: UIViewController {
    
    var books: [Audiobook]?
    var isLoaded = false
    var author: Author?
    
    @IBOutlet weak var descrAuthor: UILabel!
    @IBOutlet weak var booksTV: UITableView!
    @IBOutlet weak var authorPhoto: CircularImageView!
    @IBOutlet weak var nameAuthor: UILabel!
    
    @IBOutlet weak var backgroundAuthor: BlurredImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        booksTV.dataSource = self
        booksTV.delegate = self
        
        
        if let author = author{
            
            if let id = author._id{
                getPhotoAuthor(authorId: id){img in
                    
                    if let img = img{
                        self.authorPhoto.loadImage(from: img)
                        //self.backgroundAuthor.loadImage(from: img)
                    }
                    else{
                        self.authorPhoto.loadImage(from: imageWith(name: author.firstName)!)
                        self.backgroundAuthor.image = imageWith(name: "\(author.firstName) \(author.lastName)")
                    }
                }
                
                getDescriptionAuthor(id: id) { description in
                    DispatchQueue.main.async {
                        self.descrAuthor.text = description
                    }
                }
            }
         
            
            if let lastName = author.lastName, let firstName = author.firstName{
                nameAuthor.text = "\(firstName) \(lastName)"
                
                DefaultAPI.audiobooksAuthorlastnameGet(lastname: lastName, format:"json", extended: 1) { data, error in
                    if let error = error {
                        print("Error getting root data:", error)
                        return
                    }
                    
                    if let data = data {
                        self.books = data.books
                        DispatchQueue.main.async {
                            self.isLoaded = true
                            self.booksTV.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func getDescriptionAuthor(id: String, _ callbackDecrip: @escaping (String?) -> Void){
        var request = URLRequest(url: URL(string: "https://librivox.org/author/\(id)")!)
        request.httpMethod = "GET"
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) {data,response,error in
            
            if let data = data, let contents = String(data: data, encoding: .ascii) {
                if let range = contents.range(of: #"<p\s+class=\"description\">(.+?)</p>"#, options: .regularExpression) {
                    let description = String(contents[range].dropFirst(23).dropLast(4))
                    callbackDecrip(description)
                } else {
                    callbackDecrip("No description available")
                }
                
            } else {
                print("Error: \(error?.localizedDescription ?? "unknown error")")
            }
            
        }.resume()
    }
}


extension AuthorPageVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !isLoaded{ print("nada")
            return UITableViewCell()  }
        else{
            let cell = booksTV.dequeueReusableCell(withIdentifier: "AuthorPageTVC", for: indexPath) as! AuthorPageTVC
            
            let book = books?[indexPath.row]
            
            cell.title.text = book?.title
            
            return cell
            
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = booksTV.indexPathForSelectedRow,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = books![indexPath.row]
        }
    }
}


class AuthorPageTVC: UITableViewCell
{
    @IBOutlet weak var title: UILabel!
}


