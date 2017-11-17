//
//  ConfirmChatResponseModel.swift
//  MonkeyCounter
//
//  Created by AT on 5/22/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreLocation

public class ConfirmChatResponseModel: TextChatResponseModel {
    
    /// True if the response is positive.
    public var confirm: Bool { return _confirm }
    
    init(confirm: Bool, text: String) {
        
        super.init(text: text)
        
        self._confirm = confirm
    }

    // MARK:- private stuff
    fileprivate var _confirm = false
}
