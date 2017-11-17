//
//  MCCheckin.swift
//  MonkeyCounter
//
//  Created by AT on 6/9/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreData

public enum CheckinType : Int32 {
    case Enter = 0
    case Exit  = 1
}

public struct MCCheckin: EntityModeling {

    public let uuid: String
    public let eventUuid: String
    public let type: CheckinType
    public let latitude: Double
    public let longitude: Double
    public let createdAt: Date
    
    init(uuid: String = UUID().uuidString,
         eventUuid: String,
         type: CheckinType,
         latitude: Double,
         longitude: Double,
         createdAt: Date = Date()) {
        
        self.uuid = uuid
        self.eventUuid = eventUuid
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }
    
    /// A predicate that can be used to fetch an entity.
    ///
    /// - Returns: An entity predicate.
    public func fetchPredicate() -> NSPredicate {
        return NSPredicate(format: "uuid == %@", self.uuid)
    }

}
