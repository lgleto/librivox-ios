//
//  User.swift
//  LibriVox
//
//  Created by Leandro Silva on 23/03/2023.
//

import Foundation
class User {
    var name: String
    var username: String
    var description: String
    
    init?(dict: [String:Any]) {
        self.name     = (dict["name"] as? String)!
        self.username       = (dict["username"       ]as? String)!
        self.description      = (dict["description"      ] as? String)!
    }
}
