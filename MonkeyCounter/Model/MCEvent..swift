//
//  MCEvent.swift
//  MonkeyCounter
//
//  Created by AT on 6/9/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

public struct MCEvent: EntityModeling {

    public let count: Int64
    public let step: Int16
    public let text: String
    public let latitude: Double
    public let longitude: Double
    public let uuid: String
    public let createdAt: Date
    
    init(count: Int64 = 0,
         step: Int16 = 1,
         text: String,
         latitude: Double,
         longitude: Double,
         uuid: String = UUID().uuidString,
         createdAt: NSDate = NSDate()) {
        
        self.count = count
        self.step = step
        self.text = text
        self.latitude = latitude
        self.longitude = longitude
        self.uuid = uuid
        self.createdAt = createdAt as Date
    }
    
    /// A predicate that can be used to fetch an entity.
    ///
    /// - Returns: An entity predicate.
    public func fetchPredicate() -> NSPredicate {
        return NSPredicate(format: "uuid == %@", self.uuid)
    }
    
    /// Increment count by 1.
    ///
    /// - Returns: A new event model.
    public func increment() -> MCEvent {
        return MCEvent(count: self.count + 1,
                       step: self.step,
                       text: self.text,
                       latitude: self.latitude,
                       longitude: self.longitude,
                       uuid: self.uuid,
                       createdAt: self.createdAt as NSDate)
    }
    
    /// Decrement count by 1.
    ///
    /// - Returns: A new event model.
    public func decrement() -> MCEvent {
        return MCEvent(count: self.count - 1,
                       step: self.step,
                       text: self.text,
                       latitude: self.latitude,
                       longitude: self.longitude,
                       uuid: self.uuid,
                       createdAt: self.createdAt as NSDate)
    }
    
    public func toRegion() -> CLCircularRegion {
        
        let coord = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        
        let region = CLCircularRegion(center: coord, radius: 30, identifier: self.uuid)

        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        return region
    }
}
