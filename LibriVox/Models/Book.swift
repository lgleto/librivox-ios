//
//  BookUser.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/04/2023.
//

import Foundation
import SwaggerClient
struct Book {
    var book: Audiobook
    var isReading: Bool
    var isFav: Bool
    var isFinished: Bool
    var sectionStopped: Int32?
    var timeStopped: Int32?
    var imageUrl: String?
    
    init(book: Audiobook, isReading: Bool = false, isFav: Bool = false, isFinished: Bool = false, sectionStopped: Int32? = nil, timeStopped: Int32? = nil, imageUrl: String? = nil) {
        self.book = book
        self.isReading = isReading
        self.isFav = isFav
        self.isFinished = isFinished
        self.sectionStopped = sectionStopped
        self.timeStopped = timeStopped
        self.imageUrl = imageUrl
    }
    
    func getBookDictionary() -> [String: Any]? {
        do {
            let jsonData = try JSONEncoder().encode(book)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            
            var resultDictionary: [String: Any] = [
                "audiobook": dictionary,
                "isReading": isReading,
                "isFav": isFav,
                "isFinished": isFinished,
                "sectionStopped": sectionStopped,
                "timeStopped": timeStopped,
                "imageUrl": imageUrl
            ]
            
            return resultDictionary
        } catch {
            print("Error converting book to dictionary: \(error.localizedDescription)")
            return nil
        }
    }
}

