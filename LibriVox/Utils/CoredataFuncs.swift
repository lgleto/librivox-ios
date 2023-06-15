//
//  CoredataFuncs.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 15/06/2023.
//

import Foundation
import CoreData
import UIKit
import SwaggerClient
import FirebaseAuth

func addAudiobookCD(audioBook: Audiobook) -> AudioBooks_Data? {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let bookFetchRequest: NSFetchRequest<AudioBooks_Data> = AudioBooks_Data.fetchRequest()
    bookFetchRequest.predicate = NSPredicate(format: "id == %@", audioBook._id ?? "")
    
    do {
        let matchingBooks = try context.fetch(bookFetchRequest)
        if let existingBook = matchingBooks.first {
            return existingBook
        } else {
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
            
            if let url = audioBook.urlLibrivox{
                getBookCoverFromURL(url: url){img
                    in
                    newBookData.image = img?.jpegData(compressionQuality: 1.0)
                }
            }
            
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
            return newBookData
        }
    } catch {
        print("Error: \(error)")
        return nil
    }
}


func addBookCD(book: Book) {
    if let currentUser = Auth.auth().currentUser {
        let currentUserID = currentUser.uid
        UserDefaults.standard.set(currentUserID, forKey: "currentUserID")
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    if let authUID = UserDefaults.standard.string(forKey: "currentUserID"){
        let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "id == %@", authUID)
        
        do {
            let users = try context.fetch(userFetchRequest)
            guard let currentUser = users.first else {
                return
            }
            
            let audiobook = addAudiobookCD(audioBook: book.book)
            
            if let existingBookInfo = currentUser.books_Info?.first(where: { ($0 as! Books_Info).audioBook_Data?.id == audiobook?.id! }) as? Books_Info {
                return
            }
            
            let bookUser = Books_Info(context: context)
            bookUser.isFav = book.isFav ?? false
            bookUser.isReading = book.isReading ?? false
            bookUser.isFinished = book.isFinished ?? false
            bookUser.audioBook_Data = audiobook
            
            currentUser.addToBooks_Info(bookUser)
            
            try context.save()
            print("Saved the book.")
        } catch {
            print("Error: \(error)")
        }
    }
}


/* CORE DATA*/
func fetchBooksByParameterCD(parameter: String, value: Bool) -> [AudioBooks_Data] {
    /*SELECT *
     FROM ZUSER_CD AS user
     JOIN ZBOOKS_INFO AS books ON books.ZUSER = user.Z_PK
     JOIN ZAUDIOBOOKS_DATA AS audiobooks ON audiobooks.Z_PK = books.ZAUDIOBOOK_DATA
     WHERE user.ZID = "kioLmq1BWWRFM2wJHCRJnONveLG2"  AND books.ZISFAV = true*/
     
    if let authUID = UserDefaults.standard.string(forKey: "currentUserID") {
           var matchingBooks: [AudioBooks_Data] = []
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           
           let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
           userFetchRequest.predicate = NSPredicate(format: "id == %@", authUID)
           
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
    
       return []
}

func saveCurrentUser(name: String, email: String){
    if let authUID = UserDefaults.standard.string(forKey: "currentUserID"){
        let fetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", authUID)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            
            if existingUsers.isEmpty {
                let newUser = User_CD(context: context)
                newUser.id = authUID
                newUser.name = name
                newUser.email = email
                
                try context.save()
                print("User added successfully.")
            } else {
                print("User already exists.")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
