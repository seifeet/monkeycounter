//
//  Localized.swift
//  MonkeyCounter
//
//  Created by AT on 5/11/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public struct Localized {
    
    // MARK: - Common Localized Strings
    struct Common {
        
        struct NetworkError {
            static let Unknown      = NSLocalizedString("NetworkError.Unknown", comment: "Error description")
            static let InvalidURL   = NSLocalizedString("NetworkError.InvalidUrl", comment: "Error description")
            static let NotConnected = NSLocalizedString("NetworkError.NotConnectedToInternet", comment: "Error description")
            static let RoamingOff   = NSLocalizedString("NetworkError.InternationalRoamingOff", comment: "Error description")
            static let ServerNotReach = NSLocalizedString("NetworkError.NotReachedServer", comment: "Error description")
            static let ConnectionLost = NSLocalizedString("NetworkError.ConnectionLost", comment: "Error description")
            static let BadData = NSLocalizedString("NetworkError.IncorrectDataReturned", comment: "Error description")
        }
        
        struct CoreDataError {
            static let Unknown              = NSLocalizedString("CoreDataError.Unknown", comment: "CoreData unknow error.")
            static let PersistentStoreError = NSLocalizedString("CoreDataError.PersistentStoreError", comment: "Persistent store errors.")
            static let ContextInitError     = NSLocalizedString("CoreDataError.ContextInitError", comment: "Context initialization error.")
            static let FetchEntityError     = NSLocalizedString("CoreDataError.FetchEntityError", comment: "Fetch entity error.")
        }
    }
    
}
