//
//  CheckinStoreModeling.swift
//  MonkeyCounter
//
//  Created by AT on 6/14/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

/// Represents an event list.
/// Not thread-safe.
/// Must be run on the main queue.
public protocol CheckinStoreModeling {
    
    /// Total number of events
    var count: Property<Int?> { get }
    
    /// Get all events from the local storage.
    ///
    /// - Parameters:
    ///   - event: An id of the event.
    ///   - force: If true all items will be re-fetched.
    ///   - completed: Called once all items have been fetched.
    func fetchAll(for event:String, force: Bool, completed: @escaping ((Void) -> Void))
    
    /// An check-in at an index.
    ///
    /// - Parameter index: The index of the message.
    /// - Returns: A jsq message.
    func checkin(at index: Int) -> MCCheckin
    
    /// Data change type (insert, update, etc.).
    var dataChanged: Property<ChangeType?> { get }
    
    /// Insert a checkin into the storage.
    ///
    /// - Parameter model: A check-in item to insert.
    func insert(model: MCCheckin)
    
}
