//
//  EntityModeling.swift
//  MonkeyCounter
//
//  Created by AT on 6/9/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreData

public protocol EntityModeling {

    
    /// A predicate that can be used to fetch an item.
    ///
    /// - Returns: A predicate.
    func fetchPredicate() -> NSPredicate

}
