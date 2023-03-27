//
// Audiobook.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Audiobook: Codable {

    public var _id: String?
    public var title: String?
    public var authors: [Author]?
    public var language: String?
    public var urlLibrivox: String?
    public var urlProject: String?
    public var urlRss: String?
    public var totaltime: String?
    public var totaltimesecs: Int?

    public init(_id: String? = nil, title: String? = nil, authors: [Author]? = nil, language: String? = nil, urlLibrivox: String? = nil, urlProject: String? = nil, urlRss: String? = nil, totaltime: String? = nil, totaltimesecs: Int? = nil) {
        self._id = _id
        self.title = title
        self.authors = authors
        self.language = language
        self.urlLibrivox = urlLibrivox
        self.urlProject = urlProject
        self.urlRss = urlRss
        self.totaltime = totaltime
        self.totaltimesecs = totaltimesecs
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case title
        case authors
        case language
        case urlLibrivox = "url_librivox"
        case urlProject = "url_project"
        case urlRss = "url_rss"
        case totaltime
        case totaltimesecs
    }

}