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
      
    

        
        /*let fetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "id == %@", userID!)
         
         do {
         let existingUsers = try context.fetch(fetchRequest)
         
         if existingUsers.isEmpty {
         // User does not exist, create and add a new user
         let newUser = User_CD(context: context)
         newUser.id = userID
         newUser.name = "Glorinha"
         newUser.email = "gloria gmail"
         newUser.lastBook = "3"
         
         // Add any additional properties as needed
         
         try context.save()
         print("User added successfully.")
         } else {
         print("User already exists.")
         }
         } catch {
         // Handle the error
         print("Error: \(error)")
         }
         
         */
        
        
        //ADD BOOK
        
        /*let currentUserID = Auth.auth().currentUser?.uid // Replace with the actual current user's ID
         let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
         userFetchRequest.predicate = NSPredicate(format: "id == %@", currentUserID!)
         
         do {
         let users = try context.fetch(userFetchRequest)
         guard let currentUser = users.first else {
         // Handle the case when the current user is not found
         return
         }
         
         let newBookData = AudioBooks_Data(context: context)
         newBookData.id = "21"
         newBookData.title = "Ihuuuu"
         newBookData.genres = "Aventura"
         newBookData.descr = "dasihudsahdsaudiusajda"
         newBookData.language = "Paraquedas"
         newBookData.numSections = "20"
         newBookData.totalTime = "1:30:44"
         newBookData.totalTimeSecs = 667
         
         let books_Info = Books_Info(context: context)
         books_Info.audioBook_Data = newBookData
         books_Info.isFinished = true
         books_Info.isFav = false
         // Associate the book data with the current user
         currentUser.addToBooks_Info(books_Info)
         
         // Save the changes to the database
         try context.save()
         print("saved the book")
         } catch {
         // Handle the error
         print("Error: \(error)")
         }*/
        
        
        getBooksByParameter("isFinished", value: true){ books in
            self.finalList = books
            self.spinner.stopAnimating()
            addAudiobookCD(audioBook: books[0].book)
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



func addAudiobookCD(audioBook: Audiobook) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let bookFetchRequest: NSFetchRequest<AudioBooks_Data> = AudioBooks_Data.fetchRequest()
    bookFetchRequest.predicate = NSPredicate(format: "id == %@", audioBook._id ?? "")
    
    do {
        let matchingBooks = try context.fetch(bookFetchRequest)
        guard matchingBooks.isEmpty else {
            print("Book with ID \(audioBook._id ?? "") already exists.")
            return
        }
        
        let newBookData = AudioBooks_Data(context: context)
        newBookData.id = audioBook._id
        newBookData.title = audioBook.title
        newBookData.authors = displayAuthors(authors: audioBook.authors ?? [])
        newBookData.genres = displayGenres(strings: audioBook.genres ?? [])
        newBookData.descr = removeHtmlTagsFromText(text: audioBook._description ?? "")
        newBookData.language = audioBook.language
        newBookData.numSections = audioBook.numSections
        newBookData.totalTime = audioBook.totaltime
        newBookData.totalTimeSecs = Int32(audioBook.totaltimesecs ?? 0)
        
        var sections = Set<Sections>()

        if let sectionsData = audioBook.sections {
            for sectionData in sectionsData {
                let section = Sections(context: context)
                section.title = sectionData.title
                section.sectionNumber = sectionData.sectionNumber
                section.playTime = sectionData.playtime
                section.fileName = sectionData.fileName
                
                sections.insert(section)
                
            }
            newBookData.sections = sections as NSSet
        }
        
        
        try context.save()
        print("Saved the book.")
    } catch {
        // Handle the error
        print("Error: \(error)")
    }
}

func addBookCD(book: Books_Info){
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let currentUserID = Auth.auth().currentUser?.uid // Replace with the actual current user's ID
    let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "id == %@", currentUserID!)
    
    do {
        let users = try context.fetch(userFetchRequest)
        guard let currentUser = users.first else {
            return
        }
        
        
        currentUser.addToBooks_Info(book)
        
        
        try context.save()
        print("saved the book")
    } catch {
        print("Error: \(error)")
    }
}

/* CORE DATA*/
func fetchBooksByParameterCD(parameter: String, value: Bool) -> [AudioBooks_Data] {
    /*SELECT *
     FROM ZUSER_CD AS user
     JOIN ZBOOKS_INFO AS books ON books.ZUSER = user.Z_PK
     JOIN ZAUDIOBOOKS_DATA AS audiobooks ON audiobooks.Z_PK = books.ZAUDIOBOOK_DATA
     WHERE user.ZID = "kioLmq1BWWRFM2wJHCRJnONveLG2"  AND books.ZISFAV = true*/
    
    let userID = Auth.auth().currentUser?.uid
    var matchingBooks: [AudioBooks_Data] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "id == %@", userID!)
    do {
        let fetchedUsers = try context.fetch(userFetchRequest)
        if let currentUser = fetchedUsers.first {
            if let booksInfo = currentUser.books_Info {
                let bookInfoFetchRequest: NSFetchRequest<Books_Info> = Books_Info.fetchRequest()
                bookInfoFetchRequest.predicate = NSPredicate(format: "user == %@ AND \(parameter) == %@", currentUser, NSNumber(value: value))
                bookInfoFetchRequest.relationshipKeyPathsForPrefetching = ["audioBook_Data"]
                
                let matchingBookInfos = try context.fetch(bookInfoFetchRequest)
                for bookInfo in matchingBookInfos {
                    if let audioBookData = bookInfo.audioBook_Data {
                        matchingBooks.append(audioBookData)
                    }
                }
            }
        } else {
            print("User not found.")
        }
    } catch {
        print("Error: \(error)")
    }
    
    return matchingBooks
}

