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
    
    
    var id: String?
    var timeStopped: String?
    var isReading: Bool?
    var isFav: Bool?
    var key: String?
    
    
    init?(dict: [String:Any]) {
        
        self.id = ((dict[BookUser.ID] as? String))
        self.timeStopped = ((dict[BookUser.TIME_STOPPED] as? String))
        self.isReading = ((dict[BookUser.IS_READING] as? Bool))
        self.isFav = (dict[BookUser.IS_FAV] as? Bool)
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
