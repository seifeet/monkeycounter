//
//  CounterCVLayout.swift
//  MonkeyCounter
//
//  Created by AT on 9/13/16.
//  Copyright © 2016 AT. All rights reserved.
//

import Foundation
import UIKit

class CounterCVLayout: UICollectionViewFlowLayout {
    
    fileprivate struct Constants {
        static let itemWidth:    CGFloat = 80.0
        static let itemHeight:   CGFloat = 80.0
        static let footerHeight: CGFloat = 60.0
        static let itemSpacing:  CGFloat = 5.0
        static let marginX:      CGFloat = 5.0
        static let marginTop:    CGFloat = 20.0
        static let marginBottom: CGFloat = 60.0
    }
    

    let itemWidth: CGFloat
    let itemHeight: CGFloat = Constants.itemHeight
    let itemSpacing: CGFloat = Constants.itemSpacing
    let marginX: CGFloat = Constants.marginX
    
    var layoutInfo = [IndexPath:UICollectionViewLayoutAttributes]()
    var footerLayoutInfo = [IndexPath:UICollectionViewLayoutAttributes]()
    var maxYPos: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        self.itemWidth = UIScreen.main.bounds.width - Constants.marginX*2
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        self.itemWidth = UIScreen.main.bounds.width - Constants.marginX*2
        super.init()
        setup()
    }
    
    override func prepare() {

        createItemAttributes()
        createFooterAttributes()
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return layoutInfo[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return footerLayoutInfo[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        super.layoutAttributesForElements(in: rect)
        var allAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        
        for (_, attributes) in layoutInfo {
            if rect.intersects(attributes.frame) {
                allAttributes.append(attributes)
            }
        }
        
        for (_, attributes) in footerLayoutInfo {
            
            // bottom of the view
            let viewMaxY:CGFloat = self.collectionView!.bounds.maxY - self.collectionView!.contentInset.bottom - attributes.frame.size.height
            
            attributes.frame.origin.y = viewMaxY

            allAttributes.append(attributes)
        }
        
        return allAttributes
    }
    
    override var collectionViewContentSize : CGSize {
        let height = maxYPos + Constants.marginBottom
        
        return CGSize(width: itemWidth, height: height)
    }

    
    // MARK: private
    
    func setup() {
        // setting up some inherited values
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.minimumInteritemSpacing = itemSpacing
        self.minimumLineSpacing = itemSpacing
        self.scrollDirection = UICollectionViewScrollDirection.horizontal
//        self.sectionFootersPinToVisibleBounds = true
//        self.footerReferenceSize = CGSize(width: itemWidth, height: Constants.footerHeight)
    }
    
    func frameForItemAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        
        return CGRect(x: marginX, y: maxYPos, width: itemWidth, height: Constants.itemHeight)
    }
    
    /**
     *  Item attributes
     *
     *
     */
    func createItemAttributes() {
        layoutInfo = [IndexPath:UICollectionViewLayoutAttributes]()
        let itemCount = self.collectionView!.numberOfItems(inSection: 0)
        
        maxYPos = 0.0
        if itemCount == 0 {
            return
        }
        
        for i in 0...(itemCount-1) {
            let indexPath = IndexPath(row: i, section: 0)
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            itemAttributes.frame = frameForItemAtIndexPath(indexPath)
            
            maxYPos = itemAttributes.frame.origin.y + itemAttributes.frame.size.height + itemSpacing
            
            layoutInfo[indexPath] = itemAttributes
        }
    }
    
    /**
     *  Footer attributes
     *
     *
     */
    func createFooterAttributes() {
        footerLayoutInfo = [IndexPath:UICollectionViewLayoutAttributes]()
        let footerIndexPath = IndexPath(row: 0, section: 0)
        let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: footerIndexPath)
        footerAttributes.frame = CGRect(x: marginX, y: 0, width: itemWidth, height: Constants.footerHeight)
        footerAttributes.zIndex = 1
        
        footerLayoutInfo[footerIndexPath] = footerAttributes
    }
}
