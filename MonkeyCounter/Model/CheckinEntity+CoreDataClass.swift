//
//  CheckinEntity+CoreDataClass.swift
//  
//
//  Created by AT on 6/6/17.
//
//

import CoreData
import CoreLocation
import ReactiveSwift
import Result


public class CheckinEntity: NSManagedObject {

    var checkinType: CheckinType {
        get {
            return CheckinType(rawValue: self.type_raw)!
        }
        set {
            self.type_raw = newValue.rawValue
        }
    }
}

extension CheckinEntity {
    
    /// Fetch all check-ins from the database.
    ///
    /// - Parameter coreDataManager: A manager for core data.
    /// - Returns: A list of check-ins.
    public static func fetchAll(for eventId:String, coreDataManager: ATCoreDataManaging) -> SignalProducer<[MCCheckin], CoreDataError> {
        return SignalProducer { observer, disposable in

            let uuidPredicate = NSPredicate(format: "event_uuid == %@", eventId)
            let typePredicate = NSPredicate(format: "type_raw = %d", CheckinType.Enter.rawValue)
            let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [uuidPredicate, typePredicate])
            
            let timeSort = NSSortDescriptor(key: "created_at", ascending: false)
            
            coreDataManager.fetchAllObjects(CheckinEntity.className,
                                            predicate: predicate,
                                            sort: [timeSort],
                                            limit: nil)
                .on(failed: { error in
                    observer.send(error: error)
                }, value: { objects in
                    if let events = objects as? [MCCheckin] {
                        observer.send(value: events)
                    }
                }).start()
        }
    }
    
    /// Fetch latest check-in from the database.
    ///
    /// - Parameters:
    ///   - eventId: And optional id of the event associated with the check-in.
    ///   - checkinType: A check-in type (i.e. entered, exited).
    ///   - coreDataManager: A manager for core data.
    /// - Returns: An optional check-in.
    public static func fetchLatest(for eventId:String?,
                                   checkinType: CheckinType,
                                   coreDataManager: ATCoreDataManaging,
                                   completed: @escaping ((MCCheckin?) -> Void) ) {
        // we can fetch the latest item
        // for a certain event or for all events.
        var predicate:NSPredicate? = nil
        if let eventUuid = eventId {
            let uuidPredicate = NSPredicate(format: "event_uuid == %@", eventUuid)
            let typePredicate = NSPredicate(format: "type_raw = %d", checkinType.rawValue)
            predicate = NSCompoundPredicate.init(type: .and, subpredicates: [uuidPredicate, typePredicate])
        } else {
            predicate = NSPredicate(format: "type_raw = %d", checkinType.rawValue)
        }
        
        let timeSort = NSSortDescriptor(key: "created_at", ascending: false)
        
        coreDataManager.fetchAllObjects(CheckinEntity.className,
                                        predicate: predicate,
                                        sort: [timeSort],
                                        limit: 1)
            .on(failed: { error in
                completed(nil)
            }, value: { objects in
                if let event = objects.first as? MCCheckin {
                    completed(event)
                } else {
                    completed(nil)
                }
            }).start()
    }
    
    
    /// Insert a check-in entity into the database.
    ///
    /// - Parameters:
    ///   - coreDataManager: A thread safe data manager.
    ///   - coord: Check-in longitude & latitude.
    ///   - eventUuid: Check-in event identifier.
    /// - Returns: A signal producer with a check-in entity
    public static func insert(_ coreDataManager: ATCoreDataManaging,
                              model:MCCheckin,
                              completed: @escaping ((Void) -> Void)) {
        coreDataManager.insertOrUpdate(CheckinEntity.className, model: model)
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

}

// MARK:- CDEntityModeling
extension CheckinEntity: CDEntityModeling {
    /// Convert an entity to a data model.
    ///
    /// - Returns: A data model.
    public func toEntity() -> EntityModeling {
        return MCCheckin(
            uuid: self.uuid ?? UUID().uuidString,
            eventUuid: self.event_uuid ?? UUID().uuidString,
            type: self.checkinType,
            latitude: self.latitude,
            longitude: self.longitude,
            createdAt: (self.created_at ?? NSDate()) as Date)
    }
    
    /// Convert a data model to an entity
    ///
    /// - Parameter model: A data model
    public func fromEntity(entity model: EntityModeling) {
        if let checkinModel = model as? MCCheckin {
            
            self.event_uuid = checkinModel.eventUuid
            self.uuid = checkinModel.uuid
            self.latitude = checkinModel.latitude
            self.longitude = checkinModel.longitude
            self.checkinType = checkinModel.type
            self.created_at = checkinModel.createdAt as NSDate
        }
    }
}
