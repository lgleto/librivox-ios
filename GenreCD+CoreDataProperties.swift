//
//  GenreCD+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/06/2023.
//
//

import Foundation
import CoreData


extension GenreCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GenreCD> {
        return NSFetchRequest<GenreCD>(entityName: "GenreCD")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var audiobook: NSSet?

}

// MARK: Generated accessors for audiobook
extension GenreCD {

    @objc(addAudiobookObject:)
    @NSManaged public func addToAudiobook(_ value: AudiobookCD)

    @objc(removeAudiobookObject:)
    @NSManaged public func removeFromAudiobook(_ value: AudiobookCD)

    @objc(addAudiobook:)
    @NSManaged public func addToAudiobook(_ values: NSSet)

    @objc(removeAudiobook:)
    @NSManaged public func removeFromAudiobook(_ values: NSSet)

}

extension GenreCD : Identifiable {

}
