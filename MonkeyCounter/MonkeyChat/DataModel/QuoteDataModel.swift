//
//  QuoteDataModel.swift
//  MonkeyCounter
//
//  Created by AT on 5/3/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public class QuoteDataModel: ChatDataModel {
    
    override init() {
        super.init()
        
        self.messages.append(TextChatMessage(text: "Do not take life too seriously. You will never get out of it alive (Elbert Hubbard).", responseType: ResponseType.None))
        
        self.messages.append(TextChatMessage(text: "Everything is funny, as long as it's happening to somebody else (Will Rogers).", responseType: ResponseType.None))
        
    }
    
    // MARK:- private stuff
    fileprivate struct Const {
        fileprivate let TotalResponseCount = 0
    }
    
}
