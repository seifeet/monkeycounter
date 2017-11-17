//
//  NSObject+Additions.swift
//  V15DB835
//
//  Created by AT on 1/17/17.
//  Copyright © 2017 Visva. All rights reserved.
//
//  Refer to: http://stackoverflow.com/questions/24494784/get-class-name-of-object-as-string-in-swift
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
