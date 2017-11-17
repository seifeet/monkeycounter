//
//  EventEntity+CoreDataClass.swift
//  
//
//  Created by AT on 5/11/17.
//
//

import CoreData
import CoreLocation
import ReactiveSwift
import Result

public class EventEntity: NSManagedObject {

}

extension EventEntity {
    
    /// Fetch all events from the database.
    ///
    /// - Parameter coreDataManager: A manager for core data.
    /// - Returns: A list of events.
    public static func fetchAll(_ coreDataManager: ATCoreDataManaging) -> SignalProducer<[MCEvent], CoreDataError> {
        return SignalProducer { observer, disposable in
            
            let countSort = NSSortDescriptor(key: "count", ascending: false)
            
            coreDataManager.fetchAllObjects(EventEntity.className,
                                            predicate: nil,
                                            sort: [countSort],
                                            limit: nil)
                .on(failed: { error in
                    observer.send(error: error)
                }, value: { objects in
                    if let events = objects as? [MCEvent] {
                        observer.send(value: events)
                    }
                }).start()
        }
    }
    
    public static func insertOrUpdate(_ coreDataManager: ATCoreDataManaging, event: MCEvent, completed: @escaping ((Void) -> Void)) {
        coreDataManager.insertOrUpdate(EventEntity.className, model: event)
            .on(failed: { error in
                log.error(error)
            }, value: { _ in
                coreDataManager.save()
                    .on(failed: { error in
                        log.error(error)
                    }, value: { _ in
                        completed()
                    }).start()
            }).start()
    }
    
    public static func delete(_ coreDataManager: ATCoreDataManaging, event: MCEvent, completed: @escaping ((Void) -> Void)) {
        
        coreDataManager.deleteObject(EventEntity.className, object: event)
            .on(failed: { error in
                log.error(error)
            }, value: { _ in
                coreDataManager.save()
                    .on(failed: { error in
                        log.error(error)
                    }, value: { _ in
                        completed()
                    }).start()
            }).start()
    }
    
    /// Create an Event entity from a list of chat responses
    ///
    /// - Parameters:
    ///   - coreDataManager: A manager for core data
    ///   - response: A list of chat responses.
    /// - Returns: An optional event entity.
    public static func fromChatResponse(_ response:[ChatResponseModeling], coreDataManager: ATCoreDataManaging) -> SignalProducer<MCEvent, CoreDataError> {
        return SignalProducer { observer, disposable in
            // 2 responses are required
            // a text response and a location response
            if response.count == 2 {
                
                var text:String? = nil
                var coord:CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
                
                for r in response {
                    if let textResponse = r as? TextChatResponseModel {
                        text = textResponse.text
                    }
                    if let response = r as? LocationChatResponseModel {
                        coord = response.coord
                    }
                }
                
                if let text = text, CLLocationCoordinate2DIsValid(coord) {
                    let eventModel =
                        MCEvent(text: text,
                                latitude: coord.latitude,
                                longitude: coord.longitude)
                    
                    observer.send(value: eventModel)
            
                    return
                }
            }
            observer.send(error: .Unknown)
        }
    }
    
}

// MARK:- CDEntityModeling
extension EventEntity: CDEntityModeling {
    /// Convert an entity to a data model.
    ///
    /// - Returns: A data model.
    public func toEntity() -> EntityModeling{
        return MCEvent(count: self.count,
                       step: self.step,
                       text: self.text ?? "",
                       latitude: self.latitude,
                       longitude: self.longitude,
                       uuid: self.uuid ?? UUID().uuidString,
                       createdAt: self.created_at ?? NSDate())
    }
    
    /// Convert a data model to an entity
    ///
    /// - Parameter model: A data model
    public func fromEntity(entity model: EntityModeling) {
        if let eventModel = model as? MCEvent {
            self.count = eventModel.count
            self.step = eventModel.step
            self.text = eventModel.text
            self.latitude = eventModel.latitude
            self.longitude = eventModel.longitude
            self.uuid = eventModel.uuid
            self.created_at = eventModel.createdAt as NSDate
            self.count = eventModel.count
        }
    }
}
