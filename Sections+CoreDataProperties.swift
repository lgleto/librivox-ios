//
//  Sections+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/06/2023.
//
//

import Foundation
import CoreData


extension Sections {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sections> {
        return NSFetchRequest<Sections>(entityName: "Sections")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var playTime: String?
    @NSManaged public var sectionNumber: String?
    @NSManaged public var title: String?
    @NSManaged public var weight: Double
    @NSManaged public var audioBook_Data: AudioBooks_Data?

}

extension Sections : Identifiable {

}