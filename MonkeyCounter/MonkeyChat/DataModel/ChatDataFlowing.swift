//
//  ChatDataFlowing.swift
//  MonkeyCounter
//
//  Created by AT on 5/2/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Result
import ReactiveSwift

protocol ChatDataFlowing {
    /// Set the current flow.
    ///
    /// - Parameter flow: An enum representing the flow.
    func setFlow(_ flow: MonkeyChatFlow)
    
    /// Get data for a flow
    ///
    /// - Parameter flow: The flow.
    /// - Returns: A chat data model
    func dataForFlow(_ flow: MonkeyChatFlow) -> ChatDataModeling
    
    /// A stream for messages
    var signal: Signal<ChatMessaging, NoError> { get }
    
    /// Send messages until a response is needed or no more messages left
    func start()
    
    /// Add a new response, and continue sending messages
    ///
    /// - Parameter response: A response
    func addResponse(_ response: ChatResponseModeling)
    
    /// A list of responses from the client
    var responses: [ChatResponseModeling] { get }
}
