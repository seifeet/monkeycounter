//
//  EventViewModel.swift
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

public final class EventViewModel: EventViewModeling {
    

    internal init(eventStore: EventStoreModeling) {
        self.eventStore = eventStore
    }
    
    weak var timer: Timer?
    
    fileprivate func startTimer() {
        
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                
                // do something

            }
        }
    }
    
    fileprivate func stopTimer() {
        timer?.invalidate()
    }
    
    // MARK:- private stuff
    fileprivate let eventStore: EventStoreModeling
}
