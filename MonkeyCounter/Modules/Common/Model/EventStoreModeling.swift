//
//  EventStoreModeling.swift
//  MonkeyCounter
//
//  Created by AT on 4/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

/// Represents an event list.
/// Not thread-safe.
/// Must be run on the main queue.
public protocol EventStoreModeling {
    
    /// Total number of events
    var count: Property<Int?> { get }
    
    /// Get all events from the local storage.
    ///
    /// - Parameters:
    ///   - force: If true all items will be re-fetched.
    ///   - completed: Called once all events have been fetched.
    func fetchAll(force: Bool, completed: @escaping ((Void) -> Void))
    
    /// An event at an index.
    ///
    /// - Parameter index: The index of the message.
    /// - Returns: A jsq message.
    func event(at index: Int) -> MCEvent
    
    /// Data change type (insert, update, etc.).
    var dataChanged: Property<ChangeType?> { get }
    
    /// Start monitoring all locations
    func startMonitoring()

    /// Increment event counter by 1
    ///
    /// - Parameter index: index
    func increment(eventId: String)
    
    /// Increment event count and insert a check-in entry.
    ///
    /// - Parameters:
    ///   - event:  An event associated with the check-in.
    func incrementAndInsertCheckin(for event: MCEvent)
    
    /// Decrement event counter by 1
    ///
    /// - Parameter eventId: The id of the event counter
    func decrement(eventId: String)
    
    /// Remove and event from the storage.
    ///
    /// - Parameter eventId: The id of the event counter
    func delete(eventId: String)
    
    /// Insert an event into the storage.
    ///
    /// - Parameter event: The event to insert.
    func insert(event: MCEvent)
    
    /// Subscribe to region event monitoring.
    func subscribe()

}
