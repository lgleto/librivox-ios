//
//  FinishedCVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/04/2023.
//

import UIKit
import SwaggerClient
import FirebaseFirestore
import FirebaseAuth
import CoreData

class FinishedCVC: UICollectionViewController {
    
    var finalList: [Book] = []
    
    let spinner = UIActivityIndicatorView(style: .medium)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        collectionView.backgroundView = spinner
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let userID = Auth.auth().currentUser?.uid
        
        print ("fav \(fetchBooksByParameterCD(parameter: "isFav", value: true))")
        print ("reading \(fetchBooksByParameterCD(parameter: "isReading", value: false))")
        

        /*LE OS LIVROS DE UM UTILIZADOR
         let fetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "id == %@", userID!)
         fetchRequest.relationshipKeyPathsForPrefetching = ["books_Info", "books_Info.audioBook_Data"]
         
         do {
         let fetchedUsers = try context.fetch(fetchRequest)
         if let currentUser = fetchedUsers.first {
         if let booksInfo = currentUser.books_Info {
         for bookInfo in booksInfo {
         if let audioBookData = bookInfo as? Books_Info, let audioBook = audioBookData.audioBook_Data {
         print("BOOK")
         print("Title: \(audioBook.title ?? "")")
         if let genres = audioBook.genres{
         print("Genres: \(genres)")}
         print("Authors: \(audioBook.authors)")
         // Print any additional properties you need
         
         print("----")
         }
         }
         }
         } else {
         print("User not found.")
         }
         } catch {
         // Handle the error
         print("Error: \(error)")
         }
         
         */
        
        /* let userID = Auth.auth().currentUser?.uid
         
         let fetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "id == %@", userID!)
         
         do {
         let existingUsers = try context.fetch(fetchRequest)
         
         if existingUsers.isEmpty {
         // User does not exist, create and add a new user
         let newUser = User_CD(context: context)
         newUser.id = userID
         newUser.name = "John Doe"
         newUser.email = "john.doe@example.com"
         newUser.lastBook = "Last Book Title"
         
         // Add any additional properties as needed
         
         try context.save()
         print("User added successfully.")
         } else {
         print("User already exists.")
         }
         } catch {
         // Handle the error
         print("Error: \(error)")
         }*/
        
        
        
        /*
         ADD BOOK
         
         let currentUserID = Auth.auth().currentUser?.uid // Replace with the actual current user's ID
         let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
         userFetchRequest.predicate = NSPredicate(format: "id == %@", currentUserID!)
         
         do {
         let users = try context.fetch(userFetchRequest)
         guard let currentUser = users.first else {
         // Handle the case when the current user is not found
         return
         }
         
         let newBookData = AudioBooks_Data(context: context)
         newBookData.id = "5"
         newBookData.title = "Book Title"
         newBookData.genres = "Genre 1, Genre 2"
         newBookData.authors = "Author 1, Author 2"
         newBookData.descr = "Book description"
         newBookData.language = "English"
         newBookData.numSections = "10"
         newBookData.totalTime = "1:30:00"
         newBookData.totalTimeSecs = 5400
         
         let books_Info = Books_Info(context: context)
         books_Info.audioBook_Data = newBookData
         books_Info.isFinished = true
         books_Info.isFav = true
         // Associate the book data with the current user
         currentUser.addToBooks_Info(books_Info)
         
         // Save the changes to the database
         try context.save()
         print("saved the book")
         } catch {
         // Handle the error
         print("Error: \(error)")
         }
         */
        
        //let bookEntity = BookCD(context: context)
        /*bookEntity.id = "1"
         bookEntity.isFav = true
         do{try context.save(); print("salvo")}catch{print("context save error")}*/
        
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "BookCD", in: context)
        
        getBooksByParameter("isFinished", value: true){ books in
            self.finalList = books
            self.spinner.stopAnimating()
            
            self.collectionView.reloadSections(IndexSet(integer: 0))
            checkAndUpdateEmptyState(list: self.finalList, alertImage: UIImage(named: "completedBook")!,view: self.collectionView, alertText: "No books finished yet")
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return finalList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
        
        let book = finalList[indexPath.row].book
        cell.titleBook.text = book.title
        cell.imageBook.image = nil
        getCoverBook(id:book._id! ,url: book.urlLibrivox!){img in
            
            if let img = img{
                cell.imageBook.loadImage(from: img)
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsBook", let indexPath = collectionView.indexPathsForSelectedItems?.first,
           let detailVC = segue.destination as? BookDetailsVC {
            let item = indexPath.item
            detailVC.book = finalList[item].book
        }
    }
}


func fetchBooksByParameterCD(parameter: String, value: Bool) -> [AudioBooks_Data] {
    var matchingBooks: [AudioBooks_Data] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    if let userID = UserDefaults.standard.string(forKey: "currentUserID") {
        let fetchRequest: NSFetchRequest<Books_Info> = Books_Info.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user.id == %@\(userID) AND \(parameter) == %@\(NSNumber(value: value))")

        do {
            let matchingBookInfos = try context.fetch(fetchRequest)
            for bookInfo in matchingBookInfos {
                if let audioBookData = bookInfo.audioBook_Data {
                    matchingBooks.append(audioBookData)
                }
            }
        } catch {
            // Handle the error
            print("Error: \(error)")
        }
    }

    return matchingBooks
}

