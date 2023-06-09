//
//  AuthorCD+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/06/2023.
//
//

import Foundation
import CoreData


extension AuthorCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorCD> {
        return NSFetchRequest<AuthorCD>(entityName: "AuthorCD")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var id: String?
    @NSManaged public var lastName: String?
    @NSManaged public var audiobook: NSSet?

}

// MARK: Generated accessors for audiobook
extension AuthorCD {

    @objc(addAudiobookObject:)
    @NSManaged public func addToAudiobook(_ value: AudiobookCD)

    @objc(removeAudiobookObject:)
    @NSManaged public func removeFromAudiobook(_ value: AudiobookCD)

    @objc(addAudiobook:)
    @NSManaged public func addToAudiobook(_ values: NSSet)

    @objc(removeAudiobook:)
    @NSManaged public func removeFromAudiobook(_ values: NSSet)

}

extension AuthorCD : Identifiable {

}
