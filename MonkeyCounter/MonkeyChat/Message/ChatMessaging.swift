//
//  ChatMessaging.swift
//  MonkeyCounter
//
//  Created by AT on 5/3/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public enum ResponseType {
    case None
    case Text
    case Location
    case LocationAuthorization
}

public protocol ChatMessaging {
    
    /// Does the message require a response
    var responseType: ResponseType { get }
}
