//
//  TextChatResponseModel.swift
//  MonkeyCounter
//
//  Created by AT on 5/3/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public class TextChatResponseModel: ChatResponseModeling {
    /// Time when the response was created
    public var createdAt: Date { return _createdAt }
    /// Response text
    public var text: String? { return _text }
    
    init(text: String) {
        self._text = text
    }

    // MARK:- private stuff
    fileprivate var _createdAt = Date()
    fileprivate var _text: String? = nil
}
