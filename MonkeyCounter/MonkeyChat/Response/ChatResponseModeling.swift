//
//  ChatResponseModeling.swift
//  MonkeyCounter
//
//  Created by AT on 5/3/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public protocol ChatResponseModeling {
    
    /// Time when the response was created
    var createdAt: Date { get }
}
