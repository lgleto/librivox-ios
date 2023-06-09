//
// Section.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Section: Codable {

    public var _id: String?
    public var sectionNumber: String?
    public var title: String?
    public var listenUrl: String?
    public var language: String?
    public var playtime: String?
    public var fileName: String?
    public var readers: [Reader]?
    public var genres: [Genre]?

    public init(_id: String? = nil, sectionNumber: String? = nil, title: String? = nil, listenUrl: String? = nil, language: String? = nil, playtime: String? = nil, fileName: String? = nil, readers: [Reader]? = nil, genres: [Genre]? = nil) {
        self._id = _id
        self.sectionNumber = sectionNumber
        self.title = title
        self.listenUrl = listenUrl
        self.language = language
        self.playtime = playtime
        self.fileName = fileName
        self.readers = readers
        self.genres = genres
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case sectionNumber = "section_number"
        case title
        case listenUrl = "listen_url"
        case language
        case playtime
        case fileName = "file_name"
        case readers
        case genres
    }

}
