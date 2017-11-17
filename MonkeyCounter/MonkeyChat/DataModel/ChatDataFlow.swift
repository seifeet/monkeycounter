//
//  ChatDataFlow.swift
//  MonkeyCounter
//
//  Created by AT on 5/2/17.
//  Copyright © 2017 AT. All rights reserved.
//

import CoreLocation
import JSQMessagesViewController
import Result
import ReactiveSwift

public enum MonkeyChatFlow {
    case NotSet
    case Intro
    case Add
}

public class ChatDataFlow: ChatDataFlowing {
    
    
    init(userSettings: UserSettingsModeling) {
        self.userSettings = userSettings
        
        let locationAuthorization = ChatDataFlow.isLocationAuthorizationRequired()
        let needHelpIntro = !self.userSettings.isIntroHelpShown
        let needHelpAdd = !self.userSettings.isEventAddHelpShown
        
        self.introModel = IntroDataModel(withHelp: needHelpIntro, withLocationAuthorization: locationAuthorization)
        self.addModel = CounterAddDataModel(withHelp: needHelpAdd)
    }
    
    /// Set the current flow.
    ///
    /// - Parameter flow: An enum representing the flow.
    public func setFlow(_ flow: MonkeyChatFlow) {
        self._flow = flow
    }
    
    /// Get data for a flow
    ///
    /// - Parameter flow: The flow.
    /// - Returns: A chat data model
    public func dataForFlow(_ flow: MonkeyChatFlow) -> ChatDataModeling {
        
        switch flow {
        case MonkeyChatFlow.NotSet:
            return self._quotes
        case MonkeyChatFlow.Intro:
            return self.introModel
        case MonkeyChatFlow.Add:
            return self.addModel
        }
    }
    
    /// A stream for messages
    public var signal: Signal<ChatMessaging, NoError> {
        let messages = self.dataForFlow(self._flow)
        return messages.signal
    }
    
    /// Send messages until a response is needed or no more messages left
    public func start() {
        let messages = self.dataForFlow(self._flow)
        return messages.start()
    }
    
    /// Add a new response
    ///
    /// - Parameter response: A response
    public func addResponse(_ response: ChatResponseModeling) {
        let messages = self.dataForFlow(self._flow)
        messages.addResponse(response)
    }
    
    /// A list of responses from the client
    public var responses: [ChatResponseModeling] {
        let messages = self.dataForFlow(self._flow)
        return messages.responses
    }
    
    // MARK:- private stuff
    fileprivate let userSettings: UserSettingsModeling
    
    fileprivate var _quotes = QuoteDataModel()
    
    /// Chat flow
    fileprivate var _flow = MonkeyChatFlow.NotSet
    
    /// Is waiting for a response?
    fileprivate var _isWaiting = false
    
    /// Is location authorization required?
    ///
    /// - Returns: true, if location authorization is required.
    fileprivate static func isLocationAuthorizationRequired() -> Bool {
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedAlways:
                return false
            default:
                return true
            }
        }
        
        return true
    }
    
    fileprivate let introModel: IntroDataModel
    fileprivate let addModel: CounterAddDataModel
}
