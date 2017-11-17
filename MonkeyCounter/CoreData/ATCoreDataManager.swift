//
//  ATCoreDataManager.swift
//  MonkeyCounter
//
//  Created by AT on 5/11/17.
//  Copyright © 2017 AT. All rights reserved.
//

import CoreData
import Foundation
import ReactiveSwift

///
/// A simple thread safe core data manager.
///
/// Partially based on http://themainthread.com/blog/2015/08/core-data-stack-in-swift.html
///

public class ATCoreDataManager: ATCoreDataManaging {
    
    static let defaultModelUrl:URL? = {
        return Bundle.main.url(forResource: AppConstants.DefaultModelName, withExtension: "momd")
    }()
    
    static let defaultStoreUrl:URL = {
        let libraryDirectoryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        return libraryDirectoryUrl.appendingPathComponent(AppConstants.DefaultSQLiteDBName)
    }()
    
    /// Fetch a managed object.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity.
    ///   - predicate: A predicate to use for fetching the object.
    /// - Returns: a `SignalProducer` emitting a managed object.
    public func fetchObject(_ entityName:String, predicate:NSPredicate) -> SignalProducer<EntityModeling?, CoreDataError> {
        
        return SignalProducer
            { observer, disposable in
                
                if self.isDebug {
                    log.verbose("Current thread \(Thread.current)")
                }
                
                let fetchProducer = self.fetchEntity(entityName, predicate: predicate)
                    .on(value: { object in
                        if let entity = object as? CDEntityModeling {
                            observer.send(value: entity.toEntity())
                            observer.sendCompleted()
                        }
                    })
                    .on(failed: { error in
                        observer.send(error: error)
                    }, interrupted: {
                        observer.sendInterrupted()
                    })
                fetchProducer.start()
            }.producer.start(on: self._queueScheduler)
    }
    
    /// Insert or upate a data model.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity.
    ///   - predicate: A predicate to use for fetching the object.
    /// - Returns: a `SignalProducer`.
    public func insertOrUpdate(_ entityName:String, model:EntityModeling) -> SignalProducer<Void, CoreDataError> {
        
        return SignalProducer { observer, disposable in
            
            if self.isDebug {
                log.verbose("Current thread \(Thread.current)")
            }
            
            // 1. Try to fetch the object
            let fetchProducer = self.insertOrFetchEntity(entityName, predicate: model.fetchPredicate())
                .on(value: { result in
                    if let entity = result as? CDEntityModeling {
                        // update the entity
                        entity.fromEntity(entity: model)
                        observer.send(value: ())
                        observer.sendCompleted()
                    } else {
                        observer.send(error: CoreDataError.Unknown)
                    }
                })
                .on(failed : { error in
                    observer.send(error: error)
                })
            
            fetchProducer.start()
        }
    }
    
    /// Delete a managed object.
    ///
    /// - Parameter object: an object to delete
    /// - Returns: a `SignalProducer`
    public func deleteObject(_ entityName:String, object: EntityModeling) -> SignalProducer<Void, CoreDataError> {
        
        return SignalProducer
            { observer, disposable in

                if self.isDebug {
                    log.verbose("Current thread \(Thread.current)")
                }
                
                guard let moc = self.managedObjectContext else {
                    observer.send(error: CoreDataError.FetchEntityError)
                    return
                }
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                fetchRequest.predicate = object.fetchPredicate()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    _ = try moc.execute(deleteRequest)
                    observer.send(value: () )
                    observer.sendCompleted()
                } catch (let error) {
                    log.error(error.localizedDescription)
                    observer.send(error: CoreDataError.FetchEntityError)
                }
                
            }.producer.start(on: self._queueScheduler)
    }
    
    /// Fetch all objects for a given entity.
    ///
    ///   - entityName: The name of the entity.
    /// - Returns: a `SignalProducer`
    public func fetchAllObjects(_ entityName:String) -> SignalProducer<[EntityModeling], CoreDataError> {
       
        return self.fetchAllObjects(entityName, predicate: nil, sort: nil, limit: nil)
        
    }
    
    /// Fetch all objects for a given entity.
    ///
    ///   - entityName: The name of the entity.
    ///   - predicate: An optional predicate.
    /// - Returns: a `SignalProducer`
    public func fetchAllObjects(_ entityName:String,
                                predicate: NSPredicate?,
                                sort: [NSSortDescriptor]?,
                                limit: Int?
        ) -> SignalProducer<[EntityModeling], CoreDataError> {
        
        return SignalProducer { observer, disposable in
            if self.isDebug {
                log.verbose("Current thread \(Thread.current)")
            }
            
            guard let moc = self.managedObjectContext else {
                log.error("Failed to load managed object context.")
                observer.send(error: CoreDataError.FetchEntityError)
                return
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sort
            if let fetchLimit = limit {
                fetchRequest.fetchLimit = fetchLimit
            }
            
            do {
                let fetchedObjects = try moc.fetch(fetchRequest) as! [NSManagedObject]
                
                var models = [EntityModeling]()
                fetchedObjects.forEach({ result in
                    if let entity = result as? CDEntityModeling {
                        models.append(entity.toEntity())
                    }
                })

                observer.send(value: models)
            } catch (let error) {
                log.error(error)
                observer.send(error: CoreDataError.FetchEntityError)
            }
        }
    }
    
    /// Save managed context.
    ///
    /// - Returns:  a `SignalProducer`
    public func save() -> SignalProducer<Void, CoreDataError>  {
        return SignalProducer
            { observer, disposable in
                
                guard let moc = self.managedObjectContext else {
                    observer.send(error: CoreDataError.FetchEntityError)
                    return
                }
                
                do {
                    if self.isDebug {
                        log.verbose("Current thread \(Thread.current)")
                    }
                    try moc.save()
                    observer.send(value: ())
                    observer.sendCompleted()
                    if self.isDebug {
                        log.verbose("Saved.")
                    }
                } catch (let error) {
                    log.error(error)
                    observer.send(error: CoreDataError.FetchEntityError)
                }
            }.producer.start(on: self._queueScheduler)
    }
    
    /// A default initializer.
    ///
    /// - Parameters:
    ///   - modelUrl: A model url.
    ///   - storeUrl: A store url.
    ///   - concurrencyType: A concurrency policy.
    init(modelUrl: URL, storeUrl: URL, concurrencyType: NSManagedObjectContextConcurrencyType = .privateQueueConcurrencyType) {
        
        guard let modelAtUrl = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Error initializing managed object model from URL: \(modelUrl)")
        }
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        self.managedObjectModel = modelAtUrl
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        log.debug("Initializing persistent store at URL: \(storeUrl.path)")
        
        self._queue = DispatchQueue(label: "work.monkey.ATCoreDataManagerScheduler")
        self._queueScheduler = QueueScheduler(targeting: self._queue)
        
        self._managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        self._managedObjectContext!.persistentStoreCoordinator = self.persistentStoreCoordinator
        self._managedObjectContext!.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        self.printError({
            try self.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
        })
        
//        self._queue.async {
//            self.printError({
//                try self.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
//            })
//        }
    }
    
    
    /// Create a new managed object.
    ///
    /// - Parameter entityName: The name of the entity
    /// - Returns: a `SignalProducer` emitting a managed object.
    fileprivate func insertEntity(_ entityName:String) -> SignalProducer<NSManagedObject, CoreDataError> {
        
        return SignalProducer
            { observer, disposable in
                
                if self.isDebug {
                    log.verbose("Current thread \(Thread.current)")
                }
                
                guard let moc = self.managedObjectContext else {
                    observer.send(error: CoreDataError.FetchEntityError)
                    return
                }
                
                let newEntity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: moc)
                observer.send(value: newEntity)
                observer.sendCompleted()
            }.producer.start(on: self._queueScheduler)
    }
    
    /// Insert or fetch a managed object.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity.
    ///   - predicate: A predicate to use for fetching the object.
    /// - Returns: a `SignalProducer` emitting a managed object.
    fileprivate func insertOrFetchEntity(_ entityName:String, predicate:NSPredicate) -> SignalProducer<NSManagedObject, CoreDataError> {
        
        return SignalProducer { observer, disposable in
            
            if self.isDebug {
                log.verbose("Current thread \(Thread.current)")
            }
            
            let insertProducer = self.insertEntity(entityName)
                .on(value: { entity in
                    observer.send(value: entity)
                    observer.sendCompleted()
                })
                .on(failed: { error in
                    observer.send(error: error)
                }, interrupted: {
                    observer.sendInterrupted()
                })
            
            // 1. Try to fetch the object
            let fetchProducer = self.fetchEntity(entityName, predicate: predicate)
                .on(value: { entity in
                    if let entity = entity {
                        // 2. Return it if exists
                        observer.send(value: entity)
                        observer.sendCompleted()
                    } else {
                        // 3. Insert a new object otherwise
                        insertProducer.start()
                    }
                })
                .on(failed : { error in
                    observer.send(error: error)
                })
            
            fetchProducer.start()
        }
    }
    
    /// Fetch a managed object.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity.
    ///   - predicate: A predicate to use for fetching the object.
    /// - Returns: a `SignalProducer` emitting a managed object.
    fileprivate func fetchEntity(_ entityName:String, predicate:NSPredicate) -> SignalProducer<NSManagedObject?, CoreDataError> {
        
        return SignalProducer
            { observer, disposable in
                
                if self.isDebug {
                    log.verbose("Current thread \(Thread.current)")
                }
                
                guard let moc = self.managedObjectContext else {
                    observer.send(error: CoreDataError.FetchEntityError)
                    return
                }
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                fetchRequest.predicate = predicate
                
                do {
                    let fetchedObjects = try moc.fetch(fetchRequest) as! [NSManagedObject]
                    
                    if fetchedObjects.count == 1 {
                        observer.send(value: fetchedObjects.first!)
                        observer.sendCompleted()
                    } else {
                        observer.send(value: nil)
                        observer.sendCompleted()
                    }
                } catch (let error) {
                    log.error(error.localizedDescription)
                    observer.send(error: CoreDataError.FetchEntityError)
                }
            }.producer.start(on: self._queueScheduler)
    }
    
    /// Catch exceptions and print a general error.
    ///
    /// - Parameter completion: A block of code to execute.
    fileprivate func printError(_ completion: () throws -> Void)
    {
        do {
            try completion()
        } catch let error as NSError {
            log.error("CoreData manager failed with an error: \(error)")
            self.error = error
        } catch {
            log.error("CoreData manager has miserably failed and has no idea wtf the error is.")
        }
    }
    
    // Mark : - private
    
    fileprivate let managedObjectModel: NSManagedObjectModel
    fileprivate let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    fileprivate var error: NSError?
    
    fileprivate var _managedObjectContext: NSManagedObjectContext? = nil
    fileprivate let _queue: DispatchQueue
    fileprivate let _queueScheduler: QueueScheduler
    
    fileprivate let isDebug = false
    
    /// Managed object context is managed through a serial queue.
    fileprivate var managedObjectContext: NSManagedObjectContext? {
        guard let coordinator = self._managedObjectContext!.persistentStoreCoordinator else {
            return nil
        }
        if coordinator.persistentStores.isEmpty {
            return nil
        }
        return _managedObjectContext
    }
}
