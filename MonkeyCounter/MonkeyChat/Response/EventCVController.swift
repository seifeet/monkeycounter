//
//  EventCVController.swift
//  MonkeyCounter
//
//  Created by AT on 9/13/16.
//  Copyright © 2016 AT. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftLocation

class EventCVController: UICollectionViewController {
    
    // MARK: - injected properties
    public var layout: CounterCVLayout?
    
    internal var viewModel: EventViewModeling? {
        didSet {
            if let viewModel = self.viewModel {
                
                // number of items has changed
                viewModel.count.producer
                    .observeForUI()
                    .skipNil()
                    .on(value: { [weak self] count in
                        self?.collectionView?.reloadData()
                    })
                    .start()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        fetchLocations()
        
        if let viewModel = self.viewModel {
            viewModel.getAllEvents()
        }
        
    }
    
    // Mark: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.count.value ?? 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CounterCellIdentifier, for: indexPath) as! EventCVCell
        
        guard let event = self.viewModel?.events[indexPath.item] else {
            return aCell
        }
        
        aCell.backgroundColor = colorForIndex(index: indexPath.item)
        aCell.updateWith(count: event.count, text: event.text)
        
//
//        aCell.swiped = { (swipeType) in
//            
//            switch swipeType {
//            case .Left:
//                self.viewModel?.decrement(at: indexPath.item)
//                self.reloadItems([indexPath])
//                break
//            case .LeftMargin:
//                self.deleteCounter(counter: counter)
//                break
//            case .Right:
//                self.viewModel?.increment(at: indexPath.item)
//                self.reloadItems([indexPath])
//                break
//            case .RightMargin:
//                self.deleteCounter(counter: counter)
//                break
//            case .None:
//                break
//            }
//        }
//        
        return aCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView  {
        
        if kind == UICollectionElementKindSectionFooter{
            let aView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.FooterCellIdentifier, for: indexPath) as! FooterCollectionReusableView
            
            aView.addTapped = {
                self.performSegue(withIdentifier: "MonkeyChatSegue", sender: self)
//                let alert = UIAlertController(title: "What do you want to keep track of?",
//                                              message: nil,
//                                              preferredStyle: .alert)
//                
//                alert.addTextField { (textField) in
//                    textField.placeholder = "Type here..."
//                    textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
//                }
//                
//                self.addAction = UIAlertAction(title: "Add", style: .default, handler: { (_) in
//                    let textField = alert.textFields![0]
//                    guard let text = textField.text, !text.isEmpty  else {
//                        return
//                    }
//                    self.addCounter(with:text)
//                    self.addAction = nil
//                })
//                
//                self.addAction!.isEnabled = false
//                
//                alert.addAction(self.addAction!)
//                
//                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
//                    self.addAction = nil
//                }))
//                
//                self.present(alert, animated: true, completion: nil)
            }
            
            return aView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func textChanged(sender:UITextField) {
        self.addAction?.isEnabled = ((sender.text != nil) && (sender.text!.characters.count > 0))
    }
    
    // MARK: Navigation
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
        
        self.collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        if let layout = self.layout {
            layout.headerReferenceSize = CGSize(width: 0, height: 100)
            self.collectionView?.setCollectionViewLayout(layout, animated: true)
        } else {
            log.error("Failed to set main layout.")
        }
    }
    
    /// Delete a counter from the local storage.
    ///
    /// - Parameter counter: counter
//    private func deleteCounter(counter:ATCounter) {
//        
//        let title = "Are you sure you want to delete '\(counter.text)'?"
//        
//        let alert = UIAlertController(title: title,
//                                      message: nil,
//                                      preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
//            self.viewModel?.delete(counter: counter)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
//        }))
//        
//        self.present(alert, animated: true, completion: nil)
//    }
    
    /// Reload cells for index paths
    ///
    /// - Parameter indexPaths: indexPaths of the cells to reload
    func reloadItems(_ indexPaths:[IndexPath]){
        
        self.collectionView?.performBatchUpdates({ () -> Void in
            self.collectionView?.reloadItems(at: indexPaths)
            }, completion: { (finished) -> Void in
                
        })
    }
    
    /**
     *
     *  Create a gradient effect for cell background color
     *
     *
     */
    private func colorForIndex(index: Int) -> UIColor {
        guard let count = self.viewModel?.count.value else {
            return UIColor(red: 72.0 / 255, green: 61.0 / 255, blue: 139.0 / 255, alpha: 1.0)
        }
        let val:CGFloat = (CGFloat(index) / CGFloat(count))*20 + 61.0
        return UIColor(red: 72.0 / 255, green: val / 255, blue: 139.0 / 255, alpha: 1.0)
    }
    
    /// used to remember the action that is used to
    /// add a new counter
    fileprivate var addAction:UIAlertAction? = nil
    
    fileprivate struct Constants {
        static let CounterCellIdentifier: String = "CounterCell"
        static let FooterCellIdentifier: String = "FooterCell"
        static let PageSize = 20
    }
}

extension EventCVController {
    fileprivate func fetchLocations() {
        /////
        /////
        /////
        
        log.debug("Monitor location for Work (Cupertino)")
        do {
            let loc = CLLocationCoordinate2DMake(37.318677, -122.030996)
            let radius = 80.0
            try Location.monitor(regionAt: loc, radius: radius, enter: { _ in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "🙏🙏🙏🙏 Entered in region (Work)!")
                log.verbose("🙏🙏🙏🙏 Entered in region (Work)!")
            }, exit: { _ in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "🙏🙏🙏🙏 Exited from the region (Work)")
                log.verbose("🙏🙏🙏🙏 Exited from the region (Work)")
            }, error: { req, error in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "👺👺👺👺 An error has occurred \(error)")
                log.verbose("👺👺👺👺 An error has occurred \(error)")
                req.cancel() // abort the request (you can also use `cancelOnError=true` to perform it automatically
            })
        } catch {
            AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "👺👺👺👺 Cannot start heading updates: \(error)")
            log.verbose("👺👺👺👺 Cannot start heading updates: \(error)")
        }
        /////
        /////
        /////
        log.debug("Monitor location for Home")
        do {
            let loc = CLLocationCoordinate2DMake(37.348709, -121.971568)
            let radius = 30.0
            try Location.monitor(regionAt: loc, radius: radius, enter: { _ in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "🙏🙏🙏🙏 Entered in region (Home)!")
                log.verbose("🙏🙏🙏🙏 Entered in region (Home)!")
            }, exit: { _ in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "🙏🙏🙏🙏 Exited from the region (Home)")
                log.verbose("🙏🙏🙏🙏 Exited from the region (Home)")
            }, error: { req, error in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "👺👺👺👺 An error has occurred \(error)")
                log.verbose("👺👺👺👺 An error has occurred \(error)")
                req.cancel() // abort the request (you can also use `cancelOnError=true` to perform it automatically
            })
        } catch {
            AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "👺👺👺👺 Cannot start heading updates: \(error)")
            log.verbose("👺👺👺👺 Cannot start heading updates: \(error)")
        }
        /////
        /////
        /////
        log.debug("Monitor location for Panda")
        do {
            let loc = CLLocationCoordinate2DMake(37.322965, -122.006917)
            let radius = 80.0
            try Location.monitor(regionAt: loc, radius: radius, enter: { _ in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "🙏🙏🙏🙏 Entered in region (Panda)!")
                log.verbose("🙏🙏🙏🙏 Entered in region (Panda)!")
            }, exit: { _ in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "🙏🙏🙏🙏 Exited from the region (Panda)")
                log.verbose("🙏🙏🙏🙏 Exited from the region (Panda)")
            }, error: { req, error in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "👺👺👺👺 An error has occurred \(error)")
                log.verbose("👺👺👺👺 An error has occurred \(error)")
                req.cancel() // abort the request (you can also use `cancelOnError=true` to perform it automatically
            })
        } catch {
            AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "👺👺👺👺 Cannot start heading updates: \(error)")
            log.verbose("👺👺👺👺 Cannot start heading updates: \(error)")
        }
        /////
        /////
        /////
        log.debug("Monitor location for Campbell")
        do {
            let loc = CLLocationCoordinate2DMake(37.283046, -121.933476)
            let radius = 30.0
            try Location.monitor(regionAt: loc, radius: radius, enter: { _ in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "🙏🙏🙏🙏 Entered in region (Campbell)!")
                log.verbose("🙏🙏🙏🙏 Entered in region (Campbell)!")
            }, exit: { _ in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "🙏🙏🙏🙏 Exited from the region (Campbell)")
                log.verbose("🙏🙏🙏🙏 Exited from the region (Campbell)")
            }, error: { req, error in
                AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "👺👺👺👺 An error has occurred \(error)")
                log.verbose("👺👺👺👺 An error has occurred \(error)")
                req.cancel() // abort the request (you can also use `cancelOnError=true` to perform it automatically
            })
        } catch {
            AlertWrapper.statusBarMessage(withTitle: "SwiftLocation", andBody: "👺👺👺👺 Cannot start heading updates: \(error)")
            log.verbose("👺👺👺👺 Cannot start heading updates: \(error)")
        }
        /////
        /////
        /////
    }
}

