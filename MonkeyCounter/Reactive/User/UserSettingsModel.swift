//
//  UserSettingsModel.swift
//  UVisit
//
//  Created by AT on 6/22/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

class UserSettingsModel: UserSettingsModeling {
    
    /// Was intro help displayed to the user?
    var isIntroHelpShown: Bool {
        return UserDefaults.standard.bool(forKey: Const.IsIntroHelpShown)
    }
    
    /// Was add event help displayed to the user?
    var isEventAddHelpShown: Bool {
        return UserDefaults.standard.bool(forKey: Const.IsEventAddHelpShown)
    }
    
    
    /// Intro help was displayed to the user.
    func setIntroHelpShown() {
        UserDefaults.standard.set(true, forKey: Const.IsIntroHelpShown)
    }
    
    /// Add event help was displayed to the user.
    func setEventAddHelpShown() {
        UserDefaults.standard.set(true, forKey: Const.IsEventAddHelpShown)
    }
    
    
    // MARK: - Private stuff
    fileprivate struct Const {
        static let IsIntroHelpShown: String = "isIntroHelpShown"
        static let IsEventAddHelpShown: String = "isEventAddHelpShown"
    }
}
