//
//  MCRegionEvent.swift
//  MonkeyCounter
//
//  Created by AT on 6/19/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation


/// Region event (enter, exit)
///
/// - Enter: Entered into a region.
/// - Exit: Exited from a region.
public enum MCRegionEventType {
    case enter
    case exit
}

public struct  MCRegionEvent {
    let identifier: String
    let type: MCRegionEventType
}
