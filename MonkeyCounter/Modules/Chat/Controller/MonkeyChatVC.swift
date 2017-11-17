//
//  MonkeyChatVC.swift
//  MonkeyCounter
//
//  Created by AT on 4/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import ChameleonFramework
import CoreLocation
import JSQMessagesViewController
import LocationPicker
import Result
import ReactiveCocoa
import ReactiveSwift

final class MonkeyChatVC: JSQMessagesViewController {
    
    // MARK: - injected properties
    internal var viewModel: MonkeyChatViewModeling? {
        didSet {
            if let viewModel = self.viewModel {
                // chat messages sent by the bot
                viewModel.dataChanged.producer
                    .observeForUI()
                    .skipNil()
                    .on(value: { changeType in
                        switch changeType {
                        case .Insert(let index):
                            self.insertItem(at: index)
                        default: break
                        }
                    })
                    .start()
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        if let viewModel = self.viewModel {
            
            // bind typing indicator
            self.rac_showTypingIndicator <~ viewModel.isTyping
            // bind accessory view enabled
            self.rac_accessoryEnabled <~ viewModel.accessoryEnabled
            // bind text view enabled
            self.rac_textViewEnabled <~ viewModel.isTextViewEnabled
            
            // start the messaging flow
            viewModel.startFlow()
        }
        
    }
    
    // MARK: - private stuff
    private func configureView() {
        
        self.collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 40, 0)
        
        // send message accessory button
        let height = self.inputToolbar.contentView.leftBarButtonContainerView.frame.size.height
        let button = UIButton(type: .infoDark)
        button.setImage(AppImages.defineLocation, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: height)
        self.inputToolbar.contentView.leftBarButtonItem = button
        
        // navigation button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: AppImages.close, style: .plain, target: self, action: #selector(closePressed))

        // location services
        self.locationManager.delegate = self
    }
    
    /// Insert a new message.
    ///
    /// - Parameter index: A message index.
    fileprivate func insertItem(at index: IndexPath) {
        self.collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.insertItems(at: [index])
        }, completion: { (finished) -> Void in
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.scrollToBottom(animated: false)
        })
    }
    
    func closePressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    /// Outgoing message bubble
    fileprivate lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    /// Incoming message bubble
    fileprivate lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    /// Avatar background color
    fileprivate let monkeyColor = RandomFlatColorWithShade(.dark)
    
    /// Location manager (to request location services permission)
    fileprivate let locationManager = CLLocationManager()
    
    /// Location authorization requested
    fileprivate var requestedAuthorization = false
}

extension MonkeyChatVC {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.viewModel?.message(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        if let message = self.viewModel?.message(at: indexPath) {
            if message.senderId == self.senderId {
                cell.textView?.textColor = UIColor.flatWhite
            } else {
                cell.textView?.textColor = UIColor.flatBlackDark
            }
        }
        return cell
    }
    
    /// Avatar images
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        if let message = self.viewModel?.message(at: indexPath) {
            let backgroundColor = (message.senderId == self.senderId) ? UIColor.flatLime : monkeyColor

            
            let avatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: message.senderId, backgroundColor: backgroundColor, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: 36)
            
            return avatar
        }

        return nil
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let locationPicker = LocationPickerViewController()
        
        // button placed on right bottom corner
        locationPicker.showCurrentLocationButton = true // default: true
        
        // ignored if initial location is given, shows that location instead
        locationPicker.showCurrentLocationInitially = true // default: true
        
        locationPicker.mapType = .standard // default: .Hybrid
        
        // for searching, see `MKLocalSearchRequest`'s `region` property
        locationPicker.useCurrentLocationAsHint = true // default: false
        
        locationPicker.completion = { location in
            // location received
            guard let location = location else {
                return
            }
            guard let viewModel = self.viewModel else {
                return
            }
            let media = JSQLocationMediaItem()
            media.setLocation(location.location, withCompletionHandler: {
                let message: JSQMessage = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), media: media)
                viewModel.addMessage(message)
                viewModel.addResponse(ChatResponseFactory.from(coord: location.coordinate))
            })
            
            self.finishSendingMessage(animated: true)

        }
        
        self.navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    /// Bubble images
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {

        if let message = self.viewModel?.message(at: indexPath) {
            if message.senderId == senderId {
                return outgoingBubbleImageView
            } else {
                return incomingBubbleImageView
            }
        }
        return outgoingBubbleImageView
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {

        guard let viewModel = self.viewModel else {
            return
        }
        let isAuthorizationFlow = self.isLocationAuthorizationFlow()
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        let response = ChatResponseFactory.from(text: text, force: isAuthorizationFlow)
        
        if isAuthorizationFlow {
            
            if let response = response as? ConfirmChatResponseModel,
                response.confirm {
                self.requestAuthorization()
            }
        }
        
        viewModel.addMessage(message!)
        viewModel.addResponse(response)

        self.finishSendingMessage(animated: true)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if let image = self.getImage(indexPath: indexPath) {
            print(image)
        }
    }
    
    // MARK: private stuff
    
    fileprivate func isLocationAuthorizationFlow() -> Bool {
        
        guard let viewModel = self.viewModel else {
            return false
        }
        
        if let flowMessage = viewModel.flowMessage {
            // handle location services permission request
            return flowMessage.responseType == .LocationAuthorization
        }
        
        return false
    }
    
    fileprivate func requestAuthorization() {
        guard let viewModel = self.viewModel else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            viewModel.addResponse(ContinueChatResponseModel())
        } else {
            self.requestedAuthorization = true
            self.locationManager.requestAlwaysAuthorization()
            // see CLLocationManagerDelegate
        }
    }
    
    fileprivate func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    fileprivate func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    fileprivate func getImage(indexPath: IndexPath) -> UIImage? {
        
        guard let viewModel = self.viewModel else {
            return nil
        }
        
        let message = viewModel.message(at: indexPath)
        if message.isMediaMessage == true {
            if let mediaItem = message.media as? JSQPhotoMediaItem {
                return mediaItem.image
            }
        }
        return nil
    }
}

// MARK:- CLLocationManagerDelegate
extension MonkeyChatVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if !self.requestedAuthorization {
            return
        }
        switch status {
        case .notDetermined:
            break
        case .authorizedWhenInUse:
            break
        case .authorizedAlways:
            if let viewModel = self.viewModel {
                // will continue the flow
                viewModel.addResponse(ContinueChatResponseModel())
                self.requestedAuthorization = false
            }
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
    }
}
