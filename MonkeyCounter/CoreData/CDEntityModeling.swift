//
//  CDEntityModeling.swift
//  MonkeyCounter
//
//  Created by AT on 6/9/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public protocol CDEntityModeling {
    
    /// Convert an entity to a data model.
    ///
    /// - Returns: A data model.
    func toEntity() -> EntityModeling
    
    /// Convert a data model to an entity
    ///
    /// - Parameter model: A data model
    func fromEntity(entity: EntityModeling)
}
