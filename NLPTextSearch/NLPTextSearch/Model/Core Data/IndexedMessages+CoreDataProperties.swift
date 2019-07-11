//
//  IndexedMessages+CoreDataProperties.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 11.07.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//
//

import Foundation
import CoreData


extension IndexedMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IndexedMessages> {
        return NSFetchRequest<IndexedMessages>(entityName: "IndexedMessages")
    }

    @NSManaged public var messageID: Int64
    @NSManaged public var index: Index?

}
