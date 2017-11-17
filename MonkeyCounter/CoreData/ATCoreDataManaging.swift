//
//  ATCoreDataManaging.swift
//  MonkeyCounter
//
//  Created by AT on 5/11/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift

public protocol ATCoreDataManaging {

    /// Fetch a managed object.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity.
    ///   - predicate: A predicate to use for fetching the object.
    /// - Returns: a `SignalProducer` emitting a managed object.
    func fetchObject(_ entityName:String, predicate:NSPredicate) -> SignalProducer<EntityModeling?, CoreDataError>
    
    /// Insert or upate a data model.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity.
    ///   - predicate: A predicate to use for fetching the object.
    /// - Returns: a `SignalProducer`.
    func insertOrUpdate(_ entityName:String, model:EntityModeling) -> SignalProducer<Void, CoreDataError>
    
    /// Delete a managed object.
    ///
    /// - Parameter object: an object to delete
    /// - Returns: a `SignalProducer`
    func deleteObject(_ entityName:String, object: EntityModeling) -> SignalProducer<Void, CoreDataError>

    /// Fetch all objects for a given entity.
    ///
    ///   - entityName: The name of the entity.
    /// - Returns: a `SignalProducer`
    func fetchAllObjects(_ entityName:String) -> SignalProducer<[EntityModeling], CoreDataError>

    /// Fetch all objects for a given entity.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity.
    ///   - predicate: An optional predicate.
    ///   - sort: An optional sort descriptor
    ///   - limit: An optional maximum number of items to fetch
    /// - Returns: A list of items.
    func fetchAllObjects(_ entityName:String,
                         predicate: NSPredicate?,
                         sort: [NSSortDescriptor]?,
                         limit: Int?
        ) -> SignalProducer<[EntityModeling], CoreDataError>
    
    /// Save managed context.
    ///
    /// - Returns:  a `SignalProducer`
    func save() -> SignalProducer<Void, CoreDataError>
}
