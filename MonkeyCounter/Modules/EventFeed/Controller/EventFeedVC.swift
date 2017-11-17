//
//  EventFeedVC.swift
//  MonkeyCounter
//
//  Created by AT on 05/31/17.
//  Copyright © 2017 AT. All rights reserved.
//

import UIKit
import UserNotifications

class EventFeedVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var accessoryView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    
    // MARK: - injected properties
    public var layout: CounterCVLayout?
    
    internal var viewModel: EventViewModeling? {
        didSet {
//            if let viewModel = self.viewModel {
//                
//            }
        }
    }
    
    internal var checkinModel: CheckinStoreModeling? {
        didSet {
        }
    }
    
    internal var storeModel: EventStoreModeling? {
        didSet {
            if let storeModel = self.storeModel {
                
//                // number of items has changed
//                storeModel.count.producer
//                    .observeForUI()
//                    .skipNil()
//                    .on(value: { [weak self] count in
//                        guard let this = self, this.collectionView != nil else { return }
//                        
//                        this.collectionView.reloadData()
//                    })
//                    .start()
                
                // number of items has changed
                storeModel.dataChanged.producer
                    .observeForUI()
                    .skipNil()
                    .on(value: { changeType in
                        switch changeType {
                        case .Insert(let index):
                            self.insertItem(at: index)
                        case .Update(let index):
                            self.reloadItem(at: index)
                        case .Reload:
                            self.collectionView.collectionViewLayout.invalidateLayout()
                            self.collectionView.reloadData()
                        }
                    })
                    .start()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        configureView()
        
        if let storeModel = self.storeModel {
            storeModel.fetchAll(force: false, completed: {
                self.collectionView.reloadData()
            })
        }
        
    }
    
    func textChanged(sender:UITextField) {
        self.addAction?.isEnabled = ((sender.text != nil) && (sender.text!.characters.count > 0))
    }
    
    // MARK: Navigation
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let chatVC = appDelegate.appDependencies.container.resolve(MonkeyChatVC.self)!
        chatVC.senderId = AppConstants.MeChatSenderId
        chatVC.senderDisplayName = AppConstants.MeChatDisplayName
        
        // add navigation bar
        let nav = UINavigationController(rootViewController: chatVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let chatNC = segue.destination as? UINavigationController {
            if let chatVC = chatNC.viewControllers.first as? MonkeyChatVC {
                chatVC.senderId = AppConstants.MeChatSenderId
                chatVC.senderDisplayName = AppConstants.MeChatDisplayName
            }
        }
    }
    
    // MARK: - private stuff
    private func configureView() {
        
        // add spacing between the status bar and the first cell
        self.collectionView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
        
        self.collectionView.backgroundColor = UIColor.flatPurple
        self.accessoryView.backgroundColor = UIColor.flatPurple
        
        if let layout = self.layout {
            layout.headerReferenceSize = CGSize(width: 0, height: 100)
            self.collectionView.setCollectionViewLayout(layout, animated: true)
        } else {
            log.error("Failed to set main layout.")
        }
        
        // Add am animation to make + button more visible
        if let eventCount = self.storeModel?.count.value, eventCount == 0 {
            self.addHeartbeatAnimation(to: self.addButton)
        }
    }
    
    /// Insert a new item.
    ///
    /// - Parameter index: An item index.
    fileprivate func insertItem(at index: IndexPath) {
        self.collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.insertItems(at: [index])
        }, completion: { (finished) -> Void in
//            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    /// Reload an item.
    ///
    /// - Parameter index: An item index.
    fileprivate func reloadItem(at index: IndexPath) {
        self.collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.reloadItems(at: [index])
        }, completion: { (finished) -> Void in
        })
    }
    
    fileprivate func registerCells() {
        self.collectionView.register(EventCVCell.self, forCellWithReuseIdentifier: EventCVCell.className)
    }
    
    /// used to remember the action that is used to
    /// add a new counter
    fileprivate var addAction:UIAlertAction? = nil
    
    fileprivate struct Constants {
        static let PageSize = 20
    }
    
    /// Present a view that with 'more" options.
    ///
    /// - Parameter event: An event.
    /// - Returns: An action sheet.
    fileprivate func actionSheet(event: MCEvent) -> UIAlertController {
        
        let alert = UIAlertController()
        
        let historyButton = UIAlertAction(title: "History", style: .default, handler: { _ in
            
            self.presentHistory(for: event)
        })
        
        let notifButton = UIAlertAction(title: "Enable local notifications", style: .default, handler: { _ in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerForLocalNotifications()
        })
        
        let  deleteButton = UIAlertAction(title: "Delete forever", style: .destructive, handler: { _ in
            self.presentConfirm(for: event)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        
        alert.addAction(historyButton)
        alert.addAction(notifButton)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        
        return alert
    }
    
    /// Present a history view for the event.
    ///
    /// - Parameter event: An event.
    fileprivate func presentHistory(for event:MCEvent) {
        let historyVC = HistoryVC()
        historyVC.storeModel = self.checkinModel
        historyVC.event = event
        // add navigation bar
        let nav = UINavigationController(rootViewController: historyVC)
        
        self.present(nav, animated: true, completion: {
            
        })
    }
    
    /// Present a history view for the event.
    ///
    /// - Parameter event: An event.
    fileprivate func presentConfirm(for event:MCEvent) {
        let confirmVC = ConfirmVC()
        confirmVC.text = "Are you sure you want to forever remove `\(event.text)`?"
        
        confirmVC.confirmed = { [weak self] confirmed in
            
            guard let this = self else { return }
            
            if confirmed {
                if let storeModel = this.storeModel {
                    storeModel.delete(eventId: event.uuid)
                }
            }
        }
        // add navigation bar
        let nav = UINavigationController(rootViewController: confirmVC)
        confirmVC.title = "Confirm Delete"
        
        self.present(nav, animated: true)
    }
    
    fileprivate func addHeartbeatAnimation(to button:UIButton) {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 1.0
        pulse.toValue = 1.52
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.7
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse]
        
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        button.layer.add(animationGroup, forKey: "pulse")
    }
}

// Mark: - UICollectionViewDataSource
extension EventFeedVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.storeModel?.count.value ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCVCell.className, for: indexPath) as! EventCVCell
        
        guard let event = self.storeModel?.event(at: indexPath.item) else {
            return aCell
        }
        
        aCell.backgroundColor = colorForIndex(index: indexPath.item)
        aCell.updateWith(count: event.count, text: event.text)
        
        
        aCell.swiped = { (swipeType) in
            
            switch swipeType {
            case .Left:
                self.presentHistory(for: event)
            case .LeftMargin:
                self.presentConfirm(for: event)
            case .Right:
                if let storeModel = self.storeModel {
                    storeModel.incrementAndInsertCheckin(for: event)
                }
            case .RightMargin:
                self.presentConfirm(for: event)
            case .None:
                break
            }
        }
        
        aCell.moreTapped = {
            self.present(self.actionSheet(event: event), animated: true, completion: {
                
            })
        }
        
        return aCell
    }
    
    /**
     *
     *  Create a gradient effect for cell background color
     *
     *
     */
    private func colorForIndex(index: Int) -> UIColor {
        let count = (self.storeModel?.count.value ?? 1) + 1
        let val:CGFloat = (CGFloat(index) / CGFloat(count))*20 + 61.0
        return UIColor(red: 72.0 / 255, green: val / 255, blue: 139.0 / 255, alpha: 1.0)
    }
}

extension EventFeedVC {
    fileprivate func scheduleLocalNotification() {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.removeAllPendingNotificationRequests()
            
            let content = UNMutableNotificationContent()
            content.title = "Late wake up call"
            content.body = "The early bird catches the worm, but the second mouse gets the cheese."
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "fizzbuzz"]
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 25, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        } else {
            // Fallback on earlier versions
            let notification = UILocalNotification()
            notification.alertBody = "👺 A notif"
            notification.fireDate = Date(timeIntervalSinceNow: 5)
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
    }
}

