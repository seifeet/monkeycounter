//
//  UserSettingsModeling.swift
//  UVisit
//
//  Created by AT on 6/22/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

protocol UserSettingsModeling {
    
    /// Was intro help displayed to the user?
    var isIntroHelpShown: Bool { get }
    
    /// Was event add help displayed to the user?
    var isEventAddHelpShown: Bool { get }
    
    /// Intro help was displayed to the user.
    func setIntroHelpShown()
    
    /// Add event help was displayed to the user.
    func setEventAddHelpShown()
    
}
