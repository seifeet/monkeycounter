//
//  AppImages.swift
//  MonkeyCounter
//
//  Created by AT on 05/31/17.
//  Copyright © 2017 AT. All rights reserved.
//


import Foundation
import UIKit

public class AppImages {
    
    /// More (3 vertical dots)
    static public let more:UIImage? = {
        let name = "more"
        guard let image = UIImage(named: name) else {
            log.error("Failed to load image \(name)")
            return nil
        }
        return image
    }()
    
    /// Front gate open (not filled)
    static public let frontGateOpen:UIImage? = {
        let name = "front_gate_open"
        guard let image = UIImage(named: name) else {
            log.error("Failed to load image \(name)")
            return nil
        }
        return image
    }()
    
    /// Front gate closed (not filled)
    static public let frontGateClosed:UIImage? = {
        let name = "front_gate_closed"
        guard let image = UIImage(named: name) else {
            log.error("Failed to load image \(name)")
            return nil
        }
        return image
    }()
    
    /// Close button (x)
    static public let close:UIImage? = {
        let name = "close_normal"
        guard let image = UIImage(named: name) else {
            log.error("Failed to load image \(name)")
            return nil
        }
        return image
    }()
    
    /// Define location button ( o )
    static public let defineLocation:UIImage? = {
        let name = "define_location"
        guard let image = UIImage(named: name) else {
            log.error("Failed to load image \(name)")
            return nil
        }
        return image
    }()
    
    /// Application icon (transparent)
    static public let appIconClear:UIImage? = {
        let name = "app_icon_clear"
        guard let image = UIImage(named: name) else {
            log.error("Failed to load image \(name)")
            return nil
        }
        return image
    }()
    
    /// A background image with a dog.
    static public let dogBackground:UIImage? = {
        let name = "bonka"
        guard let image = UIImage(named: name) else {
            log.error("Failed to load image \(name)")
            return nil
        }
        return image
    }()
}
