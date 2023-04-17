//
//  AuthorPageVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 17/04/2023.
//

import UIKit
import SwaggerClient

class AuthorPageVC: UIViewController {
    
    var lastName: String?
    var books: [Audiobook]?
    var isLoaded = false
    
    @IBOutlet weak var booksTV: UITableView!
    @IBOutlet weak var nameAuthor: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if navigationController != nil {
            print("View controller is embedded in a navigation controller")
        } else {
            print("View controller is not embedded in a navigation controller")
        }
        
        
        booksTV.dataSource = self
        booksTV.delegate = self
        
        if let lastName = lastName {
            
            DefaultAPI.audiobooksAuthorlastNameGet(lastName: lastName, format:"json") { data, error in
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextViewController = BookDetailsVC()
        nextViewController.book = books![indexPath.row]
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}


class AuthorPageTVC: UITableViewCell
{
    @IBOutlet weak var title: UILabel!
}





