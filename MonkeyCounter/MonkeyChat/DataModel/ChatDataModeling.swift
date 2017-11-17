//
//  ChatDataModeling.swift
//  MonkeyCounter
//
//  Created by AT on 5/3/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

public protocol ChatDataModeling {
    
    /// A stream for messages
    var signal: Signal<ChatMessaging, NoError> { get }
    
    /// A list of responses from the client
    var responses: [ChatResponseModeling] { get }
    
    /// Send messages until a response is needed or no more messages left
    func start()
    
    /// Resend the last sent message
    func resend()
    
    /// Add a new response, and continue sending messages
    ///
    /// - Parameter response: A response
    func addResponse(_ response: ChatResponseModeling)
}
