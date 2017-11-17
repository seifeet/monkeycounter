//
//  CoreDataError.swift
//  MonkeyCounter
//
//  Created by AT on 5/11/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreData

public enum CoreDataError: Error, CustomStringConvertible {
    /// Unknown or not supported error.
    case Unknown
    
    /// Persistent store error.
    case PersistentStoreError
    
    /// Context initialization error.
    case ContextInitError
    
    /// Fetch entity error.
    case FetchEntityError

    internal init(error: NSError) {
        switch error.code {
        case NSPersistentStoreSaveError:
            self = .PersistentStoreError
        case NSPersistentStoreOpenError:
            self = .PersistentStoreError
        default:
            self = .Unknown
        }
    }
    
    public var description: String {
        let text: String
        switch self {
        case .Unknown:
            text = Localized.Common.CoreDataError.Unknown
        case .PersistentStoreError:
            text = Localized.Common.CoreDataError.PersistentStoreError
        case .ContextInitError:
            text = Localized.Common.CoreDataError.ContextInitError
        case .FetchEntityError:
            text = Localized.Common.CoreDataError.FetchEntityError
        }
        return text
    }
}
