//
//  Message+CoreDataProperties.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 11.07.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var content: String?
    @NSManaged public var messageID: Int64
    @NSManaged public var subject: String?
    @NSManaged public var attachmentFilename: String?
    @NSManaged public var ocrText: String?

}
