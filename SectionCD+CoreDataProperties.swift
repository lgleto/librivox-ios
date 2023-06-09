//
//  SectionCD+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/06/2023.
//
//

import Foundation
import CoreData


extension SectionCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionCD> {
        return NSFetchRequest<SectionCD>(entityName: "SectionCD")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var id: String?
    @NSManaged public var language: String?
    @NSManaged public var listenUrl: String?
    @NSManaged public var playtime: String?
    @NSManaged public var sectionNumber: String?
    @NSManaged public var title: String?
    @NSManaged public var audiobook: AudiobookCD?
    @NSManaged public var reader: ReaderCD?

}

extension SectionCD : Identifiable {

}
