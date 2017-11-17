//
//  MCRegionMonitor.swift
//  MonkeyCounter
//
//  Created by AT on 6/19/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveSwift
import Result

public class MCRegionMonitor: NSObject, MCRegionMonitoring {
    
    /// Entered or exited a region.
    public var regionEvent: Property<MCRegionEvent?> { return Property(_regionEvent) }
    
    /// init
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    /// Start monitoring a region.
    ///
    /// - Parameter region: A region to monitor.
    public func startMonitoring(region: CLCircularRegion) {
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            log.error("Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            log.warning("Your request to monitor a location is saved but will only be activated once you grant permission to access the device location.")
        }
        
        locationManager.startMonitoring(for: region)
    }
    
    /// Stop monitoring a region.
    ///
    /// - Parameter identifier: A region identifier.
    public func stopMonitoring(identifier: String) {
        for region in locationManager.monitoredRegions {
            guard let aRegion = region as? CLCircularRegion, aRegion.identifier == identifier else { continue }
            locationManager.stopMonitoring(for: aRegion)
        }
    }
    
    // MARK:- private stuff
    fileprivate let locationManager = CLLocationManager()
    
    fileprivate let _regionEvent  = MutableProperty<MCRegionEvent?>(nil)
}

/// CLLocationManager Delegate
extension MCRegionMonitor: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        log.error("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.error("Location Manager failed with the following error: \(error)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            self._regionEvent.value = MCRegionEvent(identifier: region.identifier, type: .enter)
            log.debug("Did enter region \(region)")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            self._regionEvent.value = MCRegionEvent(identifier: region.identifier, type: .exit)
            log.debug("Did exit region \(region)")
        }
    }
}
