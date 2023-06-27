//
//  AudioBooks_Data+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/06/2023.
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
    @NSManaged public var sections: NSSet?

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
