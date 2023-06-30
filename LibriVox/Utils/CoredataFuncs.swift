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
    guard totalBookTime > 0 else {
        return 0.0
    }
    
    let weight = Double(sectionTime) / Double(totalBookTime) * 100
    return weight
}

func deleteAudiobookCD(bookId: String) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let bookFetchRequest: NSFetchRequest<AudioBooks_Data> = AudioBooks_Data.fetchRequest()
    bookFetchRequest.predicate = NSPredicate(format: "id == %@", bookId)
    
    do {
        let matchingBooks = try context.fetch(bookFetchRequest)
        if let existingBook = matchingBooks.first {
            // Delete sections related to the book
            if let sections = existingBook.sections {
                for section in sections {
                    context.delete(section as! NSManagedObject)
                }
            }
            
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

            try context.save()
        } else {
            // Create a new book entry
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
                    if let playTime = Int(section.playTime ?? "0") {
                        section.weight = calculateSectionWeight(sectionTime: playTime, totalBookTime: audioBook.totaltimesecs ?? 0)
                    }
                    sections.insert(section)
                }

                newBookData.sections = sections as NSSet
            }

            newBookData.isFav = book.isFav ?? false
            newBookData.isReading = book.isReading ?? false
            newBookData.isFinished = book.isFinished ?? false
            newBookData.sectionStopped = Int32(book.sectionStopped ?? "0") ?? 0
            newBookData.timeStopped = Int32(book.timeStopped ?? 0)

            // Check if the image is already saved in the document directory
            if !isImageSavedInDocumentDirectory(id: audioBook._id!){
                downloadAndSaveImage(id: audioBook._id!){result in}
            }

            do {
                try context.save()
            } catch {
                print("Error: \(error)")
            }
        }
    } catch {
        print("Error: \(error)")
    }
}

func getPercentageOfBook(id: String, sectionNumber: Int) -> Double {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Sections> = Sections.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "audioBook_Data.id == %@", id)
    
    do {
        let sections = try context.fetch(fetchRequest)
        let filteredSections = sections.filter { Int($0.sectionNumber ?? "0") ?? 0 < sectionNumber }
        let totalWeight = filteredSections.reduce(0.0) { $0 + $1.weight }
        return totalWeight
    } catch {
        print("Error fetching sections: \(error)")
        return 0.0
    }
}



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

