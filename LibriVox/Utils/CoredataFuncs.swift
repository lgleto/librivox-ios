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

func calculateSectionWeight(sectionTime: Int, totalBookTime: Int) -> Double {
    let sectionTimeInSeconds = Double(sectionTime) / 1000.0
    let totalBookTimeInSeconds = Double(totalBookTime) / 1000.0
    
    guard totalBookTimeInSeconds > 0 else {
        return 0.0 // Return 0 if the total book time is zero or negative to avoid division by zero
    }
    
    let weight = (sectionTimeInSeconds / totalBookTimeInSeconds) * 100.0
    return weight
}

func deleteAudiobookCD(bookId: String) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let bookFetchRequest: NSFetchRequest<AudioBooks_Data> = AudioBooks_Data.fetchRequest()
    bookFetchRequest.predicate = NSPredicate(format: "id == %@", bookId)
    
    do {
        let matchingBooks = try context.fetch(bookFetchRequest)
        if let existingBook = matchingBooks.first {
            // Delete related objects first
            
            // Delete sections related to the book
            if let sections = existingBook.sections {
                for section in sections {
                    context.delete(section as! NSManagedObject)
                }
            }
            
            // Delete the book itself
            context.delete(existingBook)
            
            try context.save()
            print("Deleted the book.")
        }
    } catch {
        print("Error deleting the book: \(error)")
    }
}


func addAudiobookCD(book: Book) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let audioBook = book.book
    
    let bookFetchRequest: NSFetchRequest<AudioBooks_Data> = AudioBooks_Data.fetchRequest()
    bookFetchRequest.predicate = NSPredicate(format: "id == %@", audioBook._id ?? "")
    
    do {
        let matchingBooks = try context.fetch(bookFetchRequest)
        if let existingBook = matchingBooks.first {
            existingBook.isFav = book.isFav ?? false
            existingBook.isReading = book.isReading ?? false
            existingBook.isFinished = book.isFinished ?? false
            existingBook.sectionStopped = Int32(book.sectionStopped ?? "0") ?? 0
            existingBook.timeStopped = Int32(book.timeStopped ?? 0)
            existingBook.imageUrl = book.imageUrl
            try context.save()
            print("Updated the book.")
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
            newBookData.imageUrl = audioBook.imageUrl
            newBookData.urlZipFile = audioBook.urlZipFile
            
            var sections = Set<Sections>()
            
            if let sectionsData = audioBook.sections {
                for sectionData in sectionsData {
                    let section = Sections(context: context)
                    section.title = sectionData.title
                    section.sectionNumber = sectionData.sectionNumber
                    section.playTime = sectionData.playtime
                    section.fileName = sectionData.fileName
                    /*section.weight = calculateSectionWeight(sectionTime: Int(from: section.playTime ?? 0), totalBookTime: Int(newBookData.totalTimeSecs))*/
                    sections.insert(section)
                }
                
                newBookData.sections = sections as NSSet
            }
            
            
            newBookData.isFav = book.isFav ?? false
            newBookData.isReading = book.isReading ?? false
            newBookData.isFinished = book.isFinished ?? false
            newBookData.sectionStopped = Int32(book.sectionStopped ?? "0") ?? 0
            newBookData.timeStopped = Int32(book.timeStopped ?? 0)
            
            //TODO: IT IS THE BEST APPROACH? I DONT THINK SO
            /*let dispatchGroup = DispatchGroup()
             dispatchGroup.enter()
             
             if let url = audioBook.urlLibrivox {
             getBookCoverFromURL(url: url) { img in
             newBookData.image = img?.jpegData(compressionQuality: 1.0)
             dispatchGroup.leave()
             }
             } else {dispatchGroup.leave()}
             
             dispatchGroup.wait()*/
            
            do {
                try context.save()
                //print("Saved the book.")
            } catch {
                print("Error: \(error)")
            }
        }
    } catch {
        print("Error: \(error)")
    }
}


/*func addBookCD(book: Book) {
 let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
 do {
 
 let audiobook = addAudiobookCD(audioBook: book.book)
 
 if let existingBookInfo = currentUser.books_Info?.first(where: { ($0 as! Books_Info).audioBook_Data?.id == audiobook?.id! }) as? Books_Info {
 existingBookInfo.isFav = book.isFav ?? existingBookInfo.isFav
 existingBookInfo.isReading = book.isReading ?? existingBookInfo.isReading
 existingBookInfo.isFinished = book.isFinished ?? existingBookInfo.isFinished
 existingBookInfo.sectionStopped = book.sectionStopped ?? existingBookInfo.sectionStopped
 existingBookInfo.timeStopped = Int32(book.timeStopped ?? 0)
 
 try context.save()
 print("Updated the book.")
 
 return
 }
 
 
 try context.save()
 print("Saved the book_info.")
 } catch {
 print("Error: \(error)")
 }
 
 }*/

func getBookByIdCD(id: String) -> AudioBooks_Data? {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let bookRequest: NSFetchRequest<AudioBooks_Data> = AudioBooks_Data.fetchRequest()
    bookRequest.predicate = NSPredicate(format: "id == %@", id)
    
    do {
        let audiobooks = try context.fetch(bookRequest)
        
        if let audiobook = audiobooks.first {
            return audiobook
        }
    } catch {
        print("Error: \(error)")
    }
    return nil
}


func fetchBooksByParameterCD(parameter: String, value: Bool) -> [AudioBooks_Data] {
    var matchingBooks: [AudioBooks_Data] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let bookRequest: NSFetchRequest<AudioBooks_Data> = AudioBooks_Data.fetchRequest()
    bookRequest.predicate = NSPredicate(format: "\(parameter) == %@", NSNumber(value: value))
    
    do {
        matchingBooks = try context.fetch(bookRequest)
    } catch {
        print("Error: \(error)")
    }
    
    return matchingBooks
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



func updateBookInfoParameter(book: AudioBooks_Data, parameter: String, value: Any) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let bookFetchRequest: NSFetchRequest<AudioBooks_Data> = AudioBooks_Data.fetchRequest()
    bookFetchRequest.predicate = NSPredicate(format: "id == %@", book.id!)

    do {
        let books = try context.fetch(bookFetchRequest)
        guard let existingBook = books.first else {
            return
        }

        existingBook.setValue(value, forKey: parameter)

        do {
            try context.save()
            print("Updated the book_info parameter.")
        } catch {
            print("Error: \(error)")
        }

    } catch {
        print("Error: \(error)")
    }
}

