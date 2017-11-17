//
//  EventStoreModel.swift
//  MonkeyCounter
//
//  Created by AT on 4/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import CoreData
import Foundation
import JSQMessagesViewController
import ReactiveSwift
import Result

/// Represents an event list.
/// Not thread-safe.
/// Must be run on the main queue.
public final class EventStoreModel: EventStoreModeling {
    
    /// Total number of events
    public var count:  Property<Int?> { return Property(_count) }

    /// Data change type (insert, update, etc.).
    public var dataChanged: Property<ChangeType?> { return Property(_dataChanged) }
    
    internal init(dataManager: ATCoreDataManager, checkinStore: CheckinStoreModeling, regionMonitor: MCRegionMonitoring) {
        
        self.dataManager = dataManager
        self.checkinStore = checkinStore
        self.regionMonitor = regionMonitor
    }
    
    /// Get all events from the local storage.
    ///
    /// - Parameters:
    ///   - force: If true all items will be re-fetched.
    ///   - completed: Called once all events have been fetched.
    public func fetchAll(force: Bool, completed: @escaping ((Void) -> Void)) {
        
        if !force && (self._count.value ?? 0) > 0 {
            return
        }
        
        EventEntity.fetchAll(dataManager).on { [weak self] events in
            
            guard let this = self else { return }
            
            this._eventMap = [String : Int]()
            this._eventList = events
            
            this._count.value = this._eventList.count
            
            for (index, event) in this._eventList.enumerated() {
                this._eventMap[event.uuid] = index
            }
            
            // call completed
            completed()
        }.start()
    }
    
    /// An event at an index.
    ///
    /// - Parameter index: The index of the message/
    /// - Returns: A jsq message.
    public func event(at index: Int) -> MCEvent {
        return self._eventList[index]
    }

    deinit {
        log.warning("EventStoreModel deinit")
    }
    
    
    /// Subscribe to region event monitoring.
    public func subscribe() {
        self.regionMonitor.regionEvent.producer
            .skipNil()
            .on(value: { [weak self] regionEvent in
                guard let this = self else { return }
                
                if regionEvent.type == .enter {
                    
                    this.increment(eventId: regionEvent.identifier)
                }
                
                this.insertCheckin(eventId: regionEvent.identifier, type: (regionEvent.type == .enter) ? CheckinType.Enter : CheckinType.Exit)
                
            }).start()
    }
    
    /// Start monitoring all locations
    public func startMonitoring() {
        
        // TODO: remove ot
        let manager = CLLocationManager()
        // some statistics
        log.verbose("Was monitoring \(manager.monitoredRegions.count) locations")

        // start monitoring
        for event in self._eventList {
            
            self.monitorLocation(for: event)
        }
        
    }
    
//    /// Retrieve and update state for all monitored regions.
//    public func updateAllRegions() {
//        // A delay is required because of
//        // an issue with CL
//        // requestState will fail if called immediately
//        // after we stop monitoring a region
//        let deadlineTime = DispatchTime.now() + .seconds(2)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//            for (index, request) in self._requestList.enumerated() {
//                _ = request.determineState({ [weak self] state in
//                    guard let this = self else { return }
//                    if state == CLRegionState.inside {
//                        let event = this._eventList[index]
//                        this.insertCheckinIfNeeded(for: event)
//                    }
//                })
//            }
//        }
//    }
    
    /// Increment event count and insert a check-in entry.
    ///
    /// - Parameters:
    ///   - event:  An event associated with the check-in.
    public func incrementAndInsertCheckin(for event: MCEvent) {
        self.increment(eventId: event.uuid)
        let checkin = MCCheckin(eventUuid: event.uuid, type: CheckinType.Enter, latitude: event.latitude, longitude: event.longitude)
        self.checkinStore.insert(model: checkin)
    }
    
    /// Increment event counter by 1
    ///
    /// - Parameter eventId: The id of the event counter
    public func increment(eventId: String) {
        if let index = self._eventMap[eventId] {
            
            let event = self._eventList[index].increment()
            self._eventList[index] = event
            
            // TODO: remove it
            self.localNotification(for: event.text)
            
            EventEntity.insertOrUpdate(self.dataManager, event: event) { [weak self] in
                guard let this = self else { return }
                let indexPath = IndexPath(item: index, section: 0)
                this._dataChanged.value = ChangeType.Update(indexPath)
            }
            
        }
    }
    
    /// Decrement event counter by 1
    ///
    /// - Parameter eventId: The id of the event counter
    public func decrement(eventId: String) {
        if let index = self._eventMap[eventId] {
            self._eventList[index] = self._eventList[index].decrement()
            
            EventEntity.insertOrUpdate(self.dataManager, event: self._eventList[index]) { [weak self] in
                guard let this = self else { return }
                let indexPath = IndexPath(item: index, section: 0)
                this._dataChanged.value = ChangeType.Update(indexPath)
            }
            
        }
    }
    
    /// Remove and event from the storage.
    ///
    /// - Parameter eventId: The id of the event counter
    public func delete(eventId: String) {
        if let index = self._eventMap[eventId] {
            self._eventList[index] = self._eventList[index].decrement()
            
            EventEntity.delete(self.dataManager, event: self._eventList[index]) { [weak self] in
                guard let this = self else { return }
                this.fetchAll(force: true) {
                    this.startMonitoring()
                    this._dataChanged.value = ChangeType.Reload
                }
            }
            
        }
    }
    
    /// Insert an event into the storage.
    ///
    /// - Parameter event: The event to insert.
    public func insert(event: MCEvent) {
        
        EventEntity.insertOrUpdate(self.dataManager, event: event) {
            // insert the model
            let itemIndex = self._eventList.count
            self._eventMap[event.uuid] = itemIndex
            self._eventList.append(event)
            self._count.value = self._eventList.count
            
            self.startMonitoring()
            
            let indexPath = IndexPath(item: itemIndex, section: 0)
            self._dataChanged.value = ChangeType.Insert(indexPath)
        }
    }
    
    // MARK:- private stuff
    fileprivate let dataManager: ATCoreDataManager
    fileprivate let checkinStore: CheckinStoreModeling
    fileprivate let regionMonitor: MCRegionMonitoring
    
    fileprivate let _count  = MutableProperty<Int?>(nil)
    
    /// a list of all events
    fileprivate var _eventList = [MCEvent]()
    
    /// a map from event id to event
    fileprivate var _eventMap = [String : Int]()
    
    /// Data change type (insert, update, etc.).
    fileprivate var _dataChanged = MutableProperty<ChangeType?>(nil)
    
    fileprivate func monitorLocation(for event: MCEvent) {
        log.verbose("Start monitoring \(event.text)")
        
        self.regionMonitor.startMonitoring(region: event.toRegion())
    }
    
    fileprivate func localNotification(for name: String) {
        log.verbose("🙏 Entered in region \(name).")
        //  present a local notification
        let notification = UILocalNotification()
        notification.alertBody = "Entered \(name) 🙏"
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    fileprivate func localNotification(for error: Error, name: String) {
        log.verbose("👺 An error has occurred \(error)")
        // present a local notification
        let notification = UILocalNotification()
        notification.alertBody = "👺 \(name) reg failed"
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    /// Insert a check-in if the latest check-in is not in the event region.
    ///
    /// - Parameters:
    ///   - event:  An event associated with the check-in.
    fileprivate func insertCheckinIfNeeded(for event: MCEvent) {
        
        CheckinEntity.fetchLatest(for: nil, checkinType: CheckinType.Enter, coreDataManager: self.dataManager) { latestCheckin in
            if let latestId = latestCheckin?.uuid {
                // if the latest check-in is from a different region
                if latestId != event.uuid {
                    self.incrementAndInsertCheckin(for: event)
                }
            } else {
                self.incrementAndInsertCheckin(for: event)
            }
        }
    }
    
    /// Insert checkin for an event.
    ///
    /// - Parameters:
    ///   - eventId: An id of the event.
    ///   - type: A type of the event.
    fileprivate func insertCheckin(eventId: String, type:CheckinType) {
        if let index = self._eventMap[eventId] {
            
            let event = self._eventList[index]

            let checkin = MCCheckin(eventUuid: event.uuid, type: type, latitude: event.latitude, longitude: event.longitude)
            self.checkinStore.insert(model: checkin)
        }
    }
}
