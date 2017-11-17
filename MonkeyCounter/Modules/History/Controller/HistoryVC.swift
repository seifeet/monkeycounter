//
//  HistoryVC.swift
//  MonkeyCounter
//
//  Created by AT on 06/13/17.
//  Copyright © 2017 AT. All rights reserved.
//

import UIKit
import UserNotifications

class HistoryVC: UIViewController {
    
    public var collectionView: UICollectionView!
    
    // MARK: - injected properties
    public var layout: HistoryCVLayout!
    
    internal var event:MCEvent? = nil
    
    internal var viewModel: HistoryViewModeling? {
        didSet {
//            if let viewModel = self.viewModel {
//                
//            }
        }
    }
    
    internal var storeModel: CheckinStoreModeling? {
        didSet {
            if let storeModel = self.storeModel {
                
                // number of items has changed
                storeModel.dataChanged.producer
                    .observeForUI()
                    .skipNil()
                    .on(value: { [weak self] type in
                        guard let this = self else { return }
                        guard this.isLoaded else { return }
                        
                        switch type {
                        case .Insert(let index):
                            this.insertItem(at: index)
                        case .Update(let index):
                            this.reloadItem(at: index)
                        case .Reload:
                            this.collectionView.collectionViewLayout.invalidateLayout()
                            this.collectionView.reloadData()
                        }
                        
                        this.updateTitle()
                    }).start()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        registerCells()
        
        if let storeModel = self.storeModel, let evenUuid = self.event?.uuid {
            storeModel.fetchAll(for: evenUuid, force: true, completed: { [weak self] in
                
                guard let this = self else { return }
                this.collectionView.reloadData()
                this.isLoaded = true
                this.updateTitle()
            })
        }
        
    }
    
    deinit {
        log.verbose("HistoryVC deinit")
    }
    
    // MARK: - private stuff
    
    private var isLoaded = false
    
    private func configureView() {
        
        self.layout = HistoryCVLayout()
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: self.layout)
        // add spacing between the status bar and the first cell
        self.collectionView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
        
        self.collectionView.dataSource = self
        
        self.collectionView.backgroundColor = self.colorForIndex(index: 0)
        
        self.view.addSubview(self.collectionView)
        
        // navigation button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: AppImages.close, style: .plain, target: self, action: #selector(closePressed))
        
    }
    
    func closePressed(_ sender: UIBarButtonItem) {
        self.isLoaded = false
        self.storeModel = nil
        self.dismiss(animated: true)
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
        // cells
        self.collectionView.register(HistoryCVCell.self, forCellWithReuseIdentifier: HistoryCVCell.className)
        // header
        self.collectionView.register(HistoryHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HistoryHeaderView.className)
    }
    
    fileprivate struct Constants {
        static let PageSize = 20
    }

}

// Mark: - UICollectionViewDataSource
extension HistoryVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.storeModel?.count.value ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCVCell.className, for: indexPath) as! HistoryCVCell
        
        guard let checkin = self.storeModel?.checkin(at: indexPath.item) else {
            return aCell
        }
        
        aCell.backgroundColor = self.colorForIndex(index: indexPath.item)
        aCell.updateWith(date: checkin.createdAt)
        
        return aCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        if (kind == UICollectionElementKindSectionHeader) {
            // Create Header
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HistoryHeaderView.className, for: indexPath)
            
            if let headerView = reusableView as? HistoryHeaderView,
                let event = self.event {
                headerView.updateWith(event: event)
            }
            
            reusableView?.backgroundColor = self.colorForIndex(index: indexPath.item)
        }
        return reusableView!
    }
    
    /**
     *
     *  Create a gradient effect for cell background color
     *
     *
     */
    fileprivate func colorForIndex(index: Int) -> UIColor {
        let count = (self.storeModel?.count.value ?? 1) + 1
        let val:CGFloat = (CGFloat(index) / CGFloat(count))*5 + 61.0
        return UIColor(red: 72.0 / 255, green: val / 255, blue: 139.0 / 255, alpha: 1.0)
    }
    
    fileprivate func updateTitle() {
        if let count = self.storeModel?.count.value,
            let text = self.event?.text {
            
            self.title = "\(String(describing: text)) (\(count))"
        } else {
            self.title = self.event?.text
        }
    }
}
