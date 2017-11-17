//
//  CheckinStoreModel.swift
//  MonkeyCounter
//
//  Created by AT on 6/14/17.
//  Copyright © 2017 AT. All rights reserved.
//

import CoreData
import Foundation
import JSQMessagesViewController
import ReactiveSwift
import Result

/// Represents a check-in list.
/// Not thread-safe.
/// Must be run on the main queue.
public final class CheckinStoreModel: CheckinStoreModeling {
    
    /// Total number of check-ins
    public var count:  Property<Int?> { return Property(_count) }

    /// Data change type (insert, update, etc.).
    public var dataChanged: Property<ChangeType?> { return Property(_dataChanged) }
    
    internal init(dataManager: ATCoreDataManager) {
        self.dataManager = dataManager
    }
    
    /// Get all events from the local storage.
    ///
    /// - Parameters:
    ///   - event: An id of the event.
    ///   - force: If true all items will be re-fetched.
    ///   - completed: Called once all items have been fetched.
    public func fetchAll(for eventId:String, force: Bool, completed: @escaping ((Void) -> Void)) {
        
        self.eventId = eventId
        
        if !force && (self._count.value ?? 0) > 0 {
            return
        }
        
        CheckinEntity.fetchAll(for: eventId, coreDataManager: self.dataManager).on { [weak self] checkins in
            
            guard let this = self else { return }
            
            this._checkinList = checkins
            
            this._count.value = this._checkinList.count
            
            // call completed
            completed()
        }.start()
    }
    
    /// An check-in at an index.
    ///
    /// - Parameter index: The index of the message.
    /// - Returns: A jsq message.
    public func checkin(at index: Int) -> MCCheckin {
        return self._checkinList[index]
    }

    /// Insert a checkin into the storage.
    ///
    /// - Parameter checkinModel: A check-in item to insert.
    public func insert(model: MCCheckin) {
        
        CheckinEntity.insert(self.dataManager, model: model) {
            // Update in-memory storage if needed.
            if self.eventId == model.eventUuid &&
                model.type == CheckinType.Enter {

                self._checkinList.insert(model, at: 0)
                self._count.value = self._checkinList.count
                
                let indexPath = IndexPath(item: 0, section: 0)
                self._dataChanged.value = ChangeType.Insert(indexPath)
            }
        }
    }

    // MARK:- private stuff
    fileprivate let dataManager:ATCoreDataManager
    
    fileprivate let _count  = MutableProperty<Int?>(nil)
    
    /// a list of all events
    fileprivate var _checkinList = [MCCheckin]()

    /// Data change type (insert, update, etc.).
    fileprivate var _dataChanged = MutableProperty<ChangeType?>(nil)
    
    /// Event id
    fileprivate var eventId:String? = nil
   
}
