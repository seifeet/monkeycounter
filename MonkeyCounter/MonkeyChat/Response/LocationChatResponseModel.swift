//
//  LocationChatResponseModel.swift
//  MonkeyCounter
//
//  Created by AT on 5/22/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationChatResponseModel: ChatResponseModeling {
    /// Time when the response was created
    public var createdAt: Date { return _createdAt }
    
    /// A structure that contains a geographical coordinate.
    public var coord: CLLocationCoordinate2D { return _coord }
    
    init(coord: CLLocationCoordinate2D) {
        self._coord = coord
    }

    // MARK:- private stuff
    fileprivate var _createdAt = Date()
    fileprivate var _coord = kCLLocationCoordinate2DInvalid
}
