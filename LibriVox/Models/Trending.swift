//
//  Trending.swift
//  LibriVox
//
//  Created by Leandro Silva on 03/04/2023.
//

import Foundation

class Trending {
    var id: String = ""
    var trending: String = ""
    
    init?(dict: [String:Any]) {
        self.id     = (dict["id"] as? String)!
        self.trending       = (dict["trending"       ]as? String)!
    }
}
