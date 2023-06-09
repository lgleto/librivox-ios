//
//  AudiobookCD+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/06/2023.
//
//

import Foundation
import CoreData


extension AudiobookCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudiobookCD> {
        return NSFetchRequest<AudiobookCD>(entityName: "AudiobookCD")
    }

    @NSManaged public var descr: String?
    @NSManaged public var id: String?
    @NSManaged public var language: String?
    @NSManaged public var numSections: String?
    @NSManaged public var title: String?
    @NSManaged public var totaltime: String?
    @NSManaged public var totaltimesecs: Int16
    @NSManaged public var urlLibrivox: String?
    @NSManaged public var urlProject: String?
    @NSManaged public var urlRss: String?
    @NSManaged public var urlZipFile: String?
    @NSManaged public var authors: NSSet?
    @NSManaged public var genres: NSSet?
    @NSManaged public var sections: NSSet?
    @NSManaged public var bookCD: BookCD?

}

// MARK: Generated accessors for authors
extension AudiobookCD {

    @objc(addAuthorsObject:)
    @NSManaged public func addToAuthors(_ value: AuthorCD)

    @objc(removeAuthorsObject:)
    @NSManaged public func removeFromAuthors(_ value: AuthorCD)

    @objc(addAuthors:)
    @NSManaged public func addToAuthors(_ values: NSSet)

    @objc(removeAuthors:)
    @NSManaged public func removeFromAuthors(_ values: NSSet)

}

// MARK: Generated accessors for genres
extension AudiobookCD {

    @objc(addGenresObject:)
    @NSManaged public func addToGenres(_ value: GenreCD)

    @objc(removeGenresObject:)
    @NSManaged public func removeFromGenres(_ value: GenreCD)

    @objc(addGenres:)
    @NSManaged public func addToGenres(_ values: NSSet)

    @objc(removeGenres:)
    @NSManaged public func removeFromGenres(_ values: NSSet)

}

// MARK: Generated accessors for sections
extension AudiobookCD {

    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: SectionCD)

    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: SectionCD)

    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSSet)

    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSSet)

}

extension AudiobookCD : Identifiable {

}
