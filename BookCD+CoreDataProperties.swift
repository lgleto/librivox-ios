//
//  BookCD+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/06/2023.
//
//

import Foundation
import CoreData


extension BookCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookCD> {
        return NSFetchRequest<BookCD>(entityName: "BookCD")
    }

    @NSManaged public var isFav: Bool
    @NSManaged public var isReading: Bool
    @NSManaged public var isFinished: Bool
    @NSManaged public var sectionStopped: Int64
    @NSManaged public var timeStopped: Int64
    @NSManaged public var id: String?
    @NSManaged public var audiobook: AudiobookCD?

}

extension BookCD : Identifiable {

}
