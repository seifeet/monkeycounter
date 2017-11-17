//
//  ChatResponseFactory.swift
//  MonkeyCounter
//
//  Created by AT on 6/1/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation
import CoreLocation

/// A class that generates chat responses
public class ChatResponseFactory {
    
    /// Generate a chat response from a text
    ///
    /// - Parameters:
    ///   - text: A text
    ///   - force: If true force a parsed response
    /// - Returns: A chat response.
    public static func from(text: String, force: Bool) -> ChatResponseModeling {
        let trimmed = text
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet.punctuationCharacters)
            .lowercased()
        
        if force {
            if Const.YesWords.contains(trimmed) {
                return ConfirmChatResponseModel(confirm: true, text: text)
            }
            return ConfirmChatResponseModel(confirm: false, text: text)
        }
        
        if Const.YesWords.contains(trimmed) {
            return ConfirmChatResponseModel(confirm: true, text: text)
        } else if Const.NoWords.contains(trimmed) {
            return ConfirmChatResponseModel(confirm: false, text: text)
        }
        
        return TextChatResponseModel(text: text)
    }
    
    public static func from(coord: CLLocationCoordinate2D) -> ChatResponseModeling {
        return LocationChatResponseModel.init(coord: coord)
    }
    
    // MARK:- private stuff
    fileprivate struct Const {
        // --------------------------
        static let YesWords = ["yes",
                               "ok",
                               "good",
                               "great",
                               "sure"]
        // --------------------------
        static let NoWords = ["no",
                              "nay",
                              "nope"]
    }
}
