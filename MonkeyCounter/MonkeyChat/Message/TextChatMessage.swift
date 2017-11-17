//
//  TextChatMessage.swift
//  MonkeyCounter
//
//  Created by AT on 5/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public struct TextChatMessage: ChatMessaging {
    
    public let text: String
    public let responseType: ResponseType
}
