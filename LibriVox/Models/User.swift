//
//  User.swift
//  LibriVox
//
//  Created by Leandro Silva on 23/03/2023.
//

import Foundation

class User {
    static let NAME = "name"
    static let USERNAME = "username"

    var name: String?
    var username: String?
    var description: String?
    var email: String?
    var lastBook: String?
    
    init?(dict: [String:Any]) {
        self.name     = (dict["name"] as? String)
        self.username       = (dict["username"       ]as? String)
        self.description      = (dict["description"      ] as? String)
        self.lastBook      = (dict["lastBook"] as? String)
        self.email = (dict["email"] as? String ?? "")//TODO: remove ??
    }
}
