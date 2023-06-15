//
//  AudioBooks_Data+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 15/06/2023.
//
//

import Foundation
import CoreData


extension AudioBooks_Data {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioBooks_Data> {
        return NSFetchRequest<AudioBooks_Data>(entityName: "AudioBooks_Data")
    }

    @NSManaged public var authors: String?
    @NSManaged public var descr: String?
    @NSManaged public var genres: String?
    @NSManaged public var id: String?
    @NSManaged public var language: String?
    @NSManaged public var numSections: String?
    @NSManaged public var title: String?
    @NSManaged public var totalTime: String?
    @NSManaged public var totalTimeSecs: Int32
    @NSManaged public var books_Info: NSSet?
    @NSManaged public var sections: NSSet?

}

// MARK: Generated accessors for books_Info
extension AudioBooks_Data {

    @objc(addBooks_InfoObject:)
    @NSManaged public func addToBooks_Info(_ value: Books_Info)

    @objc(removeBooks_InfoObject:)
    @NSManaged public func removeFromBooks_Info(_ value: Books_Info)

    @objc(addBooks_Info:)
    @NSManaged public func addToBooks_Info(_ values: NSSet)

    @objc(removeBooks_Info:)
    @NSManaged public func removeFromBooks_Info(_ values: NSSet)

}

// MARK: Generated accessors for sections
extension AudioBooks_Data {

    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: Sections)

    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: Sections)

    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSSet)

    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSSet)

}

extension AudioBooks_Data : Identifiable {

}
