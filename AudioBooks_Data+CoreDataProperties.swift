//
//  AudioBooks_Data+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 11/07/2023.
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
    @NSManaged public var imageUrl: String?
    @NSManaged public var isFav: Bool
    @NSManaged public var isFinished: Bool
    @NSManaged public var isReading: Bool
    @NSManaged public var language: String?
    @NSManaged public var numSections: String?
    @NSManaged public var sectionStopped: Int32
    @NSManaged public var timeStopped: Int32
    @NSManaged public var title: String?
    @NSManaged public var totalTime: String?
    @NSManaged public var totalTimeSecs: Int32
    @NSManaged public var urlZipFile: String?
    @NSManaged public var sections_book: NSSet?

}

// MARK: Generated accessors for sections_book
extension AudioBooks_Data {

    @objc(addSections_bookObject:)
    @NSManaged public func addToSections_book(_ value: Sections)

    @objc(removeSections_bookObject:)
    @NSManaged public func removeFromSections_book(_ value: Sections)

    @objc(addSections_book:)
    @NSManaged public func addToSections_book(_ values: NSSet)

    @objc(removeSections_book:)
    @NSManaged public func removeFromSections_book(_ values: NSSet)

}

extension AudioBooks_Data : Identifiable {

}
