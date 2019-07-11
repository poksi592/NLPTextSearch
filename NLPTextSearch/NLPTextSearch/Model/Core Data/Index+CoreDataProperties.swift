//
//  Index+CoreDataProperties.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 11.07.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//
//

import Foundation
import CoreData


extension Index {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Index> {
        return NSFetchRequest<Index>(entityName: "Index")
    }

    @NSManaged public var token: String?
    @NSManaged public var indexedMessages: Set<IndexedMessages>?

}

// MARK: Generated accessors for indexedMessages
extension Index {

    @objc(addIndexedMessagesObject:)
    @NSManaged public func addToIndexedMessages(_ value: IndexedMessages)

    @objc(removeIndexedMessagesObject:)
    @NSManaged public func removeFromIndexedMessages(_ value: IndexedMessages)

    @objc(addIndexedMessages:)
    @NSManaged public func addToIndexedMessages(_ values: Set<Int64>)

    @objc(removeIndexedMessages:)
    @NSManaged public func removeFromIndexedMessages(_ values: Set<Int64>)

}
