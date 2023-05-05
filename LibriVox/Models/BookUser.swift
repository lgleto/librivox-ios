//
//  BookUser.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/04/2023.
//

import Foundation

struct BookUser {
    
    static let ID = "id"
    static let IS_FAV = "isFav"
    static let IS_READING = "isReading"
    static let TIME_STOPPED = "timeStopped"
    
    
    let id: String
    let timeStopped: String
    let isReading: Bool
    let isFav: Bool?
    var key: String
    
    init?(data: [String: Any]) {
        guard let id = data[BookUser.ID] as? String,
              let timeStopped = data[BookUser.TIME_STOPPED] as? String,
              let isReading = data[BookUser.IS_READING] as? Bool else {
            return nil
        }
        let isFav = data[BookUser.IS_FAV] as? Bool
        
        self.id = id
        self.timeStopped = timeStopped
        self.isReading = isReading
        self.isFav = isFav
        self.key = ""
    }
    
    var dictionary: [String: Any] {
        return [
            BookUser.ID: id,
            BookUser.TIME_STOPPED: timeStopped,
            BookUser.IS_READING: isReading,
            BookUser.IS_FAV: isFav as Any
        ]
    }
}
