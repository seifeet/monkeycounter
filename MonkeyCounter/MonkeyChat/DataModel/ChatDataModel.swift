//
//  ChatDataModel.swift
//  MonkeyCounter
//
//  Created by AT on 5/3/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

public class ChatDataModel: ChatDataModeling {
   
    /// A stream for messages
    public var signal: Signal<ChatMessaging, NoError> { return self._signal }
    /// A list of responses from the client
    public var responses: [ChatResponseModeling] { return self._responses }
    
    init() {
        (_signal, _observer) = Signal<ChatMessaging, NoError>.pipe()
        _queue = DispatchQueue(label: "work.monkey.ChatDataModel")
    }
    
    /// Send messages until a response is needed or no more messages left
    public func start() {
        if self.index == self.messages.count {
            // no messages to send
            return
        }
        for i in self.index..<self.messages.count {
            let message = self.messages[i]
            self.index += 1
            let last = (self.index == self.messages.count)
            self._queue.async {
                Thread.sleep(forTimeInterval: self.randomInterval())
                self._observer.send(value: message)
                if  last {
                    self._observer.sendCompleted()
                }
            }
            if message.responseType != ResponseType.None {
                // we need a response from the client
                break
            }
        }
    }
    
    /// Resend the last sent message
    public func resend() {
        if self.index == 0 {
            // no messages to send
            return
        }
        
        let message = self.resendMessage(for: self.index)
        let last = (self.index == self.messages.count)
        self._queue.async {
            Thread.sleep(forTimeInterval: self.randomInterval())
            self._observer.send(value: message)
            if  last {
                self._observer.sendCompleted()
            }
        }
    }
    
    /// Add a new response, and continue sending messages
    ///
    /// - Parameter response: A response
    public func addResponse(_ response: ChatResponseModeling) {
        self._responses.append(response)
        self.start()
    }
    
    internal var messages = [ChatMessaging]()
    internal var resendMessages = [Int:ChatMessaging]()
    internal var _responses = [ChatResponseModeling]()
    
    /// Generate a random interval
    ///
    /// - Returns: An integer between 800 to 1000
    fileprivate func randomInterval() -> TimeInterval {
        return TimeInterval(arc4random_uniform(8) + 5) / 10.0
    }
    
    /// The index of the current item in the flow
    fileprivate var index = 0
    
    /// A stream for messages
    fileprivate var _signal: Signal<ChatMessaging, NoError>
    fileprivate var _observer: Observer<ChatMessaging, NoError>
    
    /// A queue to run all tasks serially
    fileprivate let _queue: DispatchQueue
    
    fileprivate func resendMessage(for index:Int) -> ChatMessaging {
        
        if let message = resendMessages[index] {
            return message
        }
        return self.messages[self.index - 1]
    }
}
