//
//  CounterViewModel.swift
//  MonkeyCounter
//
//  Created by AT on 4/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import ReactiveSwift
import Result
import Toucan

public final class MonkeyChatModel: MonkeyChatViewModeling {

    /// Is chat bot 'typing' a message?
    public var isTyping: Property<Bool> { return Property(_isTyping) }
    
    /// Is accessory view enabled?
    public var accessoryEnabled: Property<Bool> { return Property(_accessoryEnabled) }
    
    /// Is input toolbar text view enabled?
    public var isTextViewEnabled: Property<Bool> { return Property(_isTextViewEnabled) }
    
    /// Data change type (insert, update, etc.).
    public var dataChanged: Property<ChangeType?> { return Property(_dataChanged) }
    
    /// Total number of messages.
    public var count: Int { return _count }
    
    /// Current chat message (a message sent by a chat flow)
    public var flowMessage: ChatMessaging? { return _flowMessage }
    
    internal init(dataManager: ATCoreDataManager,
                  eventStore: EventStoreModeling,
                  chatData: ChatDataFlowing,
                  userSettings: UserSettingsModeling) {
        
        self.dataManager = dataManager
        self.eventStore = eventStore
        self.chatData = chatData
        self.userSettings = userSettings
    }
    
    /// Start the messaging flow
    public func startFlow() {
        // let the client know messages are coming his way
        self._isTyping.value = true
        self._accessoryEnabled.value = false
        self._isTextViewEnabled.value = false
        
        let introSignal = self.chatData.dataForFlow(.Intro).signal
        let addSignal = self.chatData.dataForFlow(.Add).signal
        
        // we start with intro flow
        self.chatData.setFlow(.Intro)
        introSignal.observeCompleted  { [weak self] in
            guard let this = self else {
                return
            }
            this._flowMessage = nil
            // and continue with add flow
            this.chatData.setFlow(.Add)
            this.chatData.start()
            
            if !this.userSettings.isIntroHelpShown {
                this.userSettings.setIntroHelpShown()
            }
        }
        
        introSignal.observeValues { [weak self] message in
            guard let this = self else {
                return
            }
            this._flowMessage = message
            if message.responseType != ResponseType.None {
                this._isTyping.value = false
            }
            this._isTextViewEnabled.value = (message.responseType == ResponseType.LocationAuthorization)
            this._accessoryEnabled.value = false
            
            if let jsqMessage = this.toJSQMessage(message) {
                this.addMessage(jsqMessage)
            }
        }
        
        // add flow
        
        // add signal completes once the flow is over
        addSignal.observeCompleted { [weak self] in
            guard let this = self else {
                return
            }
            this._flowMessage = nil
            this._isTyping.value = false
            this._accessoryEnabled.value = false
            // we are ready to add a new even
            EventEntity.fromChatResponse(this.chatData.responses,
                                         coreDataManager: this.dataManager)
                .on(value: { eventModel in
                    // persist to disk
                    this.eventStore.insert(event: eventModel)
                }).start()
            
            if !this.userSettings.isEventAddHelpShown {
                this.userSettings.setEventAddHelpShown()
            }
        }
        
        addSignal.observeValues { [weak self] message in
            guard let this = self else {
                return
            }
            this._flowMessage = message
            if message.responseType != ResponseType.None {
                this._isTyping.value = false
            }
            this._isTextViewEnabled.value = (message.responseType == ResponseType.Text)
            this._accessoryEnabled.value = (message.responseType == ResponseType.Location)
            
            if let jsqMessage = this.toJSQMessage(message) {
                this.addMessage(jsqMessage)
            }
        }
        
        self.chatData.start()
    }
    
    /// Add a new message to the chat
    public func addMessage(_ message: JSQMessage) {
        let index = IndexPath(item: self._messages.count, section: 0)
        self._messages.append(message)
        self._count = self._messages.count
        self._dataChanged.value = ChangeType.Insert(index)
    }
    
    
    /// A chat message at an index.
    ///
    /// - Parameter index: The index of the message/
    /// - Returns: A jsq message.
    public func message(at index: IndexPath) -> JSQMessage {
        return self._messages[index.item]
    }
    
    /// Add a new response from the user
    ///
    /// - Parameter response: A user response
    public func addResponse(_ response: ChatResponseModeling) {
        // let the client know messages are coming his way
        self._isTyping.value = true
        // no need to input anything for now
        self._isTextViewEnabled.value = false
        // time to add the location
        self._accessoryEnabled.value = false
        // once the response is received flow will resume
        self.chatData.addResponse(response)
    }
    
    // MARK:- private stuff
    fileprivate var _messages = [JSQMessage]()
    fileprivate var _isTyping = MutableProperty<Bool>(false)
    fileprivate var _accessoryEnabled = MutableProperty<Bool>(false)
    fileprivate var _isTextViewEnabled = MutableProperty<Bool>(false)
    fileprivate var _dataChanged = MutableProperty<ChangeType?>(nil)
    fileprivate var _flowMessage: ChatMessaging? = nil
    fileprivate var _count: Int = 0
    
    fileprivate var dataManager: ATCoreDataManager
    fileprivate var eventStore: EventStoreModeling
    fileprivate var chatData: ChatDataFlowing
    fileprivate let userSettings: UserSettingsModeling
    
    /// Convert a caht message to JSQ message
    ///
    /// - Parameter message: A chat message
    /// - Returns: A JSQ message
    fileprivate func toJSQMessage(_ message: ChatMessaging) -> JSQMessage? {
        if let textMessage = message as? TextChatMessage {
            return JSQMessage(senderId: AppConstants.MonkeyChatSenderId,
                              displayName: AppConstants.MonkeyChatDisplayName,
                              text: textMessage.text)
        } else if let imageMessage = message as? ImageChatMessage {
            let image = UIImage(named: imageMessage.path)
            let media = PhotoMediaItem(image: image)
            
            return JSQMessage(senderId: AppConstants.MonkeyChatSenderId,
                              senderDisplayName: AppConstants.MonkeyChatDisplayName,
                              date: Date(),
                              media: media)
        }
        return nil
    }
}

class PhotoMediaItem : JSQPhotoMediaItem {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    override init!(image: UIImage!) {
        super.init(image: image)
        // resize to fit the screen
        let width = UIScreen.main.bounds.size.width * 0.8
        
        self.image = Toucan(image: image!).resize(self.scaledSize(image.size, width: width), fitMode: .scale).image
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return self.image.size
    }
    
    // MARK:- private stuff
    
    /// Size scaled to fit the width.
    ///
    /// - Parameters:
    ///   - size: Original image size.
    ///   - width: Desired width.
    /// - Returns: A size scaled to fit the width
    fileprivate func scaledSize(_ size: CGSize, width: CGFloat) -> CGSize {
        let imageSize = CGSize(width: size.width, height: size.height)
        let horizontalScale = width / imageSize.width

        return CGSize(width: round(horizontalScale * imageSize.width), height: round(horizontalScale * imageSize.height))
    }
}
