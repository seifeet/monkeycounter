//
//  ContinueChatResponseModel.swift
//  MonkeyCounter
//
//  Created by AT on 5/22/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreLocation

public class ContinueChatResponseModel: ChatResponseModeling {
    
    /// Time when the response was created
    public var createdAt: Date { return _createdAt }

    // MARK:- private stuff
    fileprivate var _createdAt = Date()
}
