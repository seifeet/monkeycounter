//
//  ChangeType.swift
//  MonkeyCounter
//
//  Created by AT on 6/5/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import UIKit

public enum ChangeType {
    case Update(IndexPath)
    case Insert(IndexPath)
    case Reload
}
