//
//  MCRegionMonitoring.swift
//  MonkeyCounter
//
//  Created by AT on 6/19/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveSwift
import Result

public protocol MCRegionMonitoring {
    
    /// Entered or exited a region.
    var regionEvent: Property<MCRegionEvent?> { get }
    
    /// Start monitoring a region.
    ///
    /// - Parameter region: A region to monitor.
    func startMonitoring(region: CLCircularRegion)
    
    /// Stop monitoring a region.
    ///
    /// - Parameter identifier: A region identifier.
    func stopMonitoring(identifier: String)
}
