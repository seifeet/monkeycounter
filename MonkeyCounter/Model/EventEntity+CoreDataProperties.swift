//
//  EventEntity+CoreDataProperties.swift
//  
//
//  Created by AT on 5/22/17.
//
//

import Foundation
import CoreData


extension EventEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventEntity> {
        return NSFetchRequest<EventEntity>(entityName: "EventEntity")
    }

    @NSManaged public var count: Int64
    @NSManaged public var step: Int16
    @NSManaged public var text: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var uuid: String?
    @NSManaged public var created_at: NSDate?

}
