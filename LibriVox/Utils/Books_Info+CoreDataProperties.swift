//
//  Books_Info+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 14/06/2023.
//
//

import Foundation
import CoreData


extension Books_Info {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Books_Info> {
        return NSFetchRequest<Books_Info>(entityName: "Books_Info")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isFav: Bool
    @NSManaged public var isReading: Bool
    @NSManaged public var isFinished: Bool
    @NSManaged public var sectionStopped: String?
    @NSManaged public var timeStopped: Int16
    @NSManaged public var user: User_CD?
    @NSManaged public var audioBook_Data: AudioBooks_Data?

}

extension Books_Info : Identifiable {

}
