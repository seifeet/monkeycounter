//
//  MonkeyChatModeling.swift
//  MonkeyCounter
//
//  Created by AT on 4/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import ReactiveSwift
import Result

public protocol MonkeyChatViewModeling {
    
    /// Is chat bot 'typing' a message?
    var isTyping: Property<Bool> { get }
    
    /// Is accessory view enabled?
    var accessoryEnabled: Property<Bool> { get }
    
    /// Is input toolbar text view enabled?
    var isTextViewEnabled: Property<Bool> { get }
    
    /// Total number of messages.
    var count: Int { get }
    
    /// Data change type (insert, update, etc.).
    var dataChanged: Property<ChangeType?> { get }
    
    /// Current chat message (a message sent by a chat flow)
    var flowMessage: ChatMessaging? { get }
    
    /// Add a new message to the chat
    func addMessage(_ message: JSQMessage)
    
    /// A chat message at an index.
    ///
    /// - Parameter index: The index of the message/
    /// - Returns: A jsq message.
    func message(at index: IndexPath) -> JSQMessage
    
    /// Add a new response from the user
    func addResponse(_ response: ChatResponseModeling)
    
    /// Start the messaging flow
    func startFlow()
}
