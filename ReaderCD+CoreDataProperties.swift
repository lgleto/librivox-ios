//
//  ReaderCD+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/06/2023.
//
//

import Foundation
import CoreData


extension ReaderCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReaderCD> {
        return NSFetchRequest<ReaderCD>(entityName: "ReaderCD")
    }

    @NSManaged public var displayName: String?
    @NSManaged public var readerId: String?
    @NSManaged public var section: NSSet?

}

// MARK: Generated accessors for section
extension ReaderCD {

    @objc(addSectionObject:)
    @NSManaged public func addToSection(_ value: SectionCD)

    @objc(removeSectionObject:)
    @NSManaged public func removeFromSection(_ value: SectionCD)

    @objc(addSection:)
    @NSManaged public func addToSection(_ values: NSSet)

    @objc(removeSection:)
    @NSManaged public func removeFromSection(_ values: NSSet)

}
