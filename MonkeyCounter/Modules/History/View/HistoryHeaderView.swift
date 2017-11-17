//
//  HistoryHeaderView.swift
//  MonkeyCounter
//
//  Created by AT on 6/14/17.
//  Copyright © 2017 AT. All rights reserved.
//

import UIKit
import MapKit

class HistoryHeaderView: UICollectionReusableView {
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addViews()
        
        self.backgroundColor = UIColor.flatYellowDark
    }
    
    public func updateWith(event: MCEvent) {
        
        let center = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        
        self.eventAnnotation = EventAnnotation(title: event.text, coord: center)
        
        let region = MKCoordinateRegionMakeWithDistance(center, 300, 300)
        
        // center the map
        self.mkMap.setRegion(region, animated: false)
        // remove all annotations
        self.mkMap.annotations.forEach { annotation in
            self.mkMap.removeAnnotation(annotation)
        }
        // add a new annotation
        if let eventAnnotation = self.eventAnnotation {
            self.mkMap.addAnnotation(eventAnnotation)
        }
    }
    
    fileprivate func addViews() {
        self.addSubview(self.mkMap)
        
        NSLayoutConstraint.activate([
            self.mkMap.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2),
            self.mkMap.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2),
            self.mkMap.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            self.mkMap.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            
            ])
    }
    
    fileprivate let mkMap: MKMapView = {
        let map = MKMapView()
        
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    fileprivate var eventAnnotation: EventAnnotation? = nil
    
}
