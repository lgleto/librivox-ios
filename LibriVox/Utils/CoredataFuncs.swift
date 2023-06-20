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

            
            //TODO: IT IS THE BEST APPROACH? I DONT THINK SO
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            if let url = audioBook.urlLibrivox {
                getBookCoverFromURL(url: url) { img in
                    newBookData.image = img?.jpegData(compressionQuality: 1.0)
                    dispatchGroup.leave()
                }
            } else {dispatchGroup.leave()}
            
            dispatchGroup.wait()
            
            do {
                try context.save()
                //print("Saved the book.")
                return newBookData
            } catch {
                print("Error: \(error)")
                return nil
            }
        }
    } catch {
        print("Error: \(error)")
        return nil
    }
}


func addBookCD(book: Book) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    if let authUID = UserDefaults.standard.string(forKey: "currentUserID") {
        let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "id == %@", authUID)
        
        do {
            let users = try context.fetch(userFetchRequest)
            guard let currentUser = users.first else {
                return
            }
            
            let audiobook = addAudiobookCD(audioBook: book.book)
            
            if let existingBookInfo = currentUser.books_Info?.first(where: { ($0 as! Books_Info).audioBook_Data?.id == audiobook?.id! }) as? Books_Info {
                existingBookInfo.isFav = book.isFav ?? existingBookInfo.isFav
                existingBookInfo.isReading = book.isReading ?? existingBookInfo.isReading
                existingBookInfo.isFinished = book.isFinished ?? existingBookInfo.isFinished
                
                try context.save()
                print("Updated the book.")
                
                return
            }
            
            let bookUser = Books_Info(context: context)
            bookUser.isFav = book.isFav ?? false
            bookUser.isReading = book.isReading ?? false
            bookUser.isFinished = book.isFinished ?? false
            bookUser.audioBook_Data = audiobook
            
            currentUser.addToBooks_Info(bookUser)
            
            try context.save()
            print("Saved the book_info.")
        } catch {
            print("Error: \(error)")
        }
    }
}



/* CORE DATA*/
func fetchBooksByParameterCD(parameter: String, value: Bool) -> [Books_Info] {
    /*SELECT *
     FROM ZUSER_CD AS user
     JOIN ZBOOKS_INFO AS books ON books.ZUSER = user.Z_PK
     JOIN ZAUDIOBOOKS_DATA AS audiobooks ON audiobooks.Z_PK = books.ZAUDIOBOOK_DATA
     WHERE user.ZID = "kioLmq1BWWRFM2wJHCRJnONveLG2"  AND books.ZISFAV = true*/
     
    if let authUID = UserDefaults.standard.string(forKey: "currentUserID") {
           var matchingBooks: [Books_Info] = []
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
                       
                       matchingBooks = try context.fetch(bookInfoFetchRequest)
                       
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


func convertToAudiobook(audioBookData: AudioBooks_Data) -> Audiobook {
    var audiobook = Audiobook()
    audiobook._id = audioBookData.id
    audiobook.title = audioBookData.title
    audiobook._description = audioBookData.descr
    //audiobook.genres = decodeGenres(audioBookData.genres)
    //audiobook.authors = decodeAuthors(audioBookData.authors)
    audiobook.numSections = audioBookData.numSections
    audiobook.sections = decodeSections(audioBookData.sections)
    audiobook.language = audioBookData.language
    audiobook.totaltime = audioBookData.totalTime
    audiobook.totaltimesecs = Int(audioBookData.totalTimeSecs)
    return audiobook
}

func decodeSections(_ sections: NSSet?) -> [Section]? {
    guard let sectionSet = sections as? Set<Sections> else { return nil }
    
    let sortedSections = sectionSet.sorted { $0.sectionNumber! < $1.sectionNumber! }
    
    var decodedSections: [Section] = []
    
    for sectionData in sortedSections {
        var section = Section()
        section.title = sectionData.title
        section.sectionNumber = sectionData.sectionNumber
        section.playtime = sectionData.playTime
        section.fileName = sectionData.fileName
        
        decodedSections.append(section)
    }
    
    return decodedSections
}



func updateBookInfoParameter(book: Book, parameter: String, value: Any) {
    guard let authUID = UserDefaults.standard.string(forKey: "currentUserID") else {
        return
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let userFetchRequest: NSFetchRequest<User_CD> = User_CD.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "id == %@", authUID)
    
    do {
        let users = try context.fetch(userFetchRequest)
        guard let currentUser = users.first else {
            return
        }
        
        if let existingBookInfo = currentUser.books_Info?.first(where: { ($0 as! Books_Info).audioBook_Data?.id == book.book._id }) as? Books_Info {
            existingBookInfo.setValue(value, forKey: parameter)
            
            do {
                try context.save()
                print("Updated the book_info parameter.")
            } catch {
                print("Error: \(error)")
            }
            
            return
        }
        
        // If the Books_Info object doesn't exist, I can create it here
        
    } catch {
        print("Error: \(error)")
    }
}
