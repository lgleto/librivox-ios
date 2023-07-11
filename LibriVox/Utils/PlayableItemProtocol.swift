//
//  PlayableItemProtocol.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 11/07/2023.
//

import Foundation
import SwaggerClient

protocol PlayableItemProtocol {
    var _id      : String?    { get set }
    var title    : String?   { get set }
    var imageUrl : String?   { get set }
    var urlZipFile  : String?   { get set }
    var timestopped : Int?      { get set }
    var sectionstopped : String?     { get set }
    var isfav : Bool?     { get set }
    var sections : [Section]? { get set }
}

extension Audiobook : PlayableItemProtocol {
    var sectionstopped: String? {
        get {
            return sectionStopped
        }
        set {
            sectionstopped = newValue
        }
    }
    
    var timestopped: Int? {
        get {
            return timeStopped
        }
        set {
            timeStopped = newValue
        }
    }
    
    var isfav: Bool? {
        get {
            return isFav
        }
        set {
            isFav = newValue
        }
    }
    
}

extension AudioBooks_Data: PlayableItemProtocol {
    var sectionstopped: String? {
        get {
            return String(sectionStopped)
        }
        set {
            sectionStopped = Int32(sectionStopped)
        }
    }
    
    var _id: String? {
        get { return id }
        set { id = newValue }
    }
    
    var timestopped: Int? {
        get { return Int(timeStopped ?? 0) }
        set { timeStopped = Int32(newValue != nil ? Int(Int32(newValue!)) : 0) }
    }
    
    var isfav: Bool? {
        get { return isFav }
        set { isFav = newValue! }
    }
    
    
    var sections: [Section]? {
        get {
            if let sectionsSet = sections_book as? Set<Sections> {
                let convertedSections = sectionsSet.compactMap { convertToSection(section: $0) }
                return convertedSections
            }
            return nil
        }
        set {
            if let newValue = newValue {
                let convertedSections = newValue.compactMap { convertToSections(section: $0) }
                sections_book = NSSet(array: convertedSections)
            } else {
                sections_book = nil
            }
        }
    }

}

private func convertToSection(section: Sections) -> Section? {
    let convertedSection = Section(
                                   sectionNumber: "\(section.sectionNumber)",
                                   title: section.title,
                                   playtime: section.playTime,
                                   fileName: section.fileName)
    return convertedSection
}

// Helper method to convert Section to Sections
private func convertToSections(section: Section) -> Sections? {
    let sectionsEntity = Sections()
    sectionsEntity.sectionNumber = Int32(section.sectionNumber ?? "") ?? 0
    sectionsEntity.title = section.title
    sectionsEntity.playTime = section.playtime
    sectionsEntity.fileName = section.fileName

    return sectionsEntity
}
