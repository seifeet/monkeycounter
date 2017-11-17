//
//  EventAnnotation.swift
//  MonkeyCounter
//
//  Created by AT on 6/20/17.
//  Copyright © 2017 AT. All rights reserved.
//

import MapKit

class EventAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coord: CLLocationCoordinate2D) {
        self.title = title
        self._subtitle = "lat: \(coord.latitude) long: \(coord.longitude)"
        self.coordinate = coord
        
        super.init()
    }
    
    var subtitle: String? {
        return self._subtitle
    }
    
    // MARK:- private stuff
    private var _subtitle: String
}
