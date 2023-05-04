//
//  BookUser.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/04/2023.
//

import Foundation

struct BookUser {
    let id: String
    let timeStopped: String
    let isReading: Bool
    let isFav: Bool?
    var key: String
    
    init?(data: [String: Any]) {
        guard let id = data["id"] as? String,
              let timeStopped = data["timeStopped"] as? String,
              let isReading = data["isReading"] as? Bool else {
            return nil
        }
        let isFav = data["isFav"] as? Bool
        
        self.id = id
        self.timeStopped = timeStopped
        self.isReading = isReading
        self.isFav = isFav
        self.key = ""
    }
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "timeStopped": timeStopped,
            "isReading": isReading,
            "isFav": isFav as Any
        ]
    }
}
