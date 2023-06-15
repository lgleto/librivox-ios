//
//  User_CD+CoreDataProperties.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 15/06/2023.
//
//

import Foundation
import CoreData


extension User_CD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User_CD> {
        return NSFetchRequest<User_CD>(entityName: "User_CD")
    }

    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var lastBook: String?
    @NSManaged public var name: String?
    @NSManaged public var books_Info: NSSet?

}

// MARK: Generated accessors for books_Info
extension User_CD {

    @objc(addBooks_InfoObject:)
    @NSManaged public func addToBooks_Info(_ value: Books_Info)

    @objc(removeBooks_InfoObject:)
    @NSManaged public func removeFromBooks_Info(_ value: Books_Info)

    @objc(addBooks_Info:)
    @NSManaged public func addToBooks_Info(_ values: NSSet)

    @objc(removeBooks_Info:)
    @NSManaged public func removeFromBooks_Info(_ values: NSSet)

}

extension User_CD : Identifiable {

}
