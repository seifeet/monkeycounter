//
//  AlertDisplayModel.swift
//  V15DB835
//
//  Created by Thomas Klucher on 2/27/17.
//  Copyright © 2017 Visva. All rights reserved.
//

import Foundation
import SwiftMessages

class AlertWrapper {
    
    /// Show error view at the top
    ///
    /// - Parameters:
    ///   - title: title
    ///   - body: body
    static func statusBarMessage(withTitle title: String, andBody body: String) {
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(.info)
        view.configureDropShadow()
        view.configureContent(title: title, body: body)
        view.button?.isHidden = true
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 2)
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        SwiftMessages.show(config: config, view: view)
    }
    
}
