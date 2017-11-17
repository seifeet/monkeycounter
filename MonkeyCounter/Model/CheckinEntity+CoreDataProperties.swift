//
//  CheckinEntity+CoreDataProperties.swift
//  
//
//  Created by AT on 6/6/17.
//
//

import Foundation
import CoreData


extension CheckinEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CheckinEntity> {
        return NSFetchRequest<CheckinEntity>(entityName: "CheckinEntity")
    }

    @NSManaged public var uuid: String?
    @NSManaged public var event_uuid: String?
    @NSManaged public var type_raw: Int32
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var created_at: NSDate?

}
