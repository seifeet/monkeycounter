//
//  IntroDataModel.swift
//  MonkeyCounter
//
//  Created by AT on 5/3/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public class IntroDataModel: ChatDataModel {
    
    init(withHelp: Bool, withLocationAuthorization: Bool) {
        super.init()
        
        if withHelp {
            // just use English for now
            self.messages.append(TextChatMessage(text: "Hi there!", responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "I am here to help you.", responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "You probably wonder what this app is all about :)?", responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "Here is a simple example of why you might find it useful:", responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "You want to know how often you visit a certain place, let's say your favorite restaraunt.", responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "Just enter the location of the restaurant here and I will do the rest. I can count for you how many times you go there (as long as you don't mind my company of course).", responseType: ResponseType.None))
            
        } else {
            let randomIndex = Int(arc4random_uniform(UInt32(Const.Hello.count)))
            
            self.messages.append(TextChatMessage(text: Const.Hello[randomIndex], responseType: ResponseType.None))
        }
        
        if withLocationAuthorization {
            
            self.messages.append(TextChatMessage(text: "To do my job I must be able to access location services on this device but I will only use them sparsely. You will not even notice, I promise! Your battery is safe with me.", responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "So yes I am green (even though I look purple).", responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "Now I need your help.", responseType: ResponseType.None))
            
            self.messages.append(ImageChatMessage(path:"hlp_location_name",responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "Can I access location services on this device?", responseType: ResponseType.None))
            
            self.messages.append(TextChatMessage(text: "Please respond by typing `Yes` or `No`.", responseType: ResponseType.LocationAuthorization))
            self.resendMessages[self.messages.count] = TextChatMessage(text: "Sorry but I cannot function without location services. Can I access location services on this device?", responseType: ResponseType.LocationAuthorization)
            
            self.messages.append(TextChatMessage(text: "Let's start by adding the first location you want to keep track of.", responseType: ResponseType.None))
        }
    }
    
    
    /// Add a new response, and continue sending messages
    ///
    /// - Parameter response: A response
    public override func addResponse(_ response: ChatResponseModeling) {
        
        if let response = response as? ConfirmChatResponseModel {
            // resend the previous message
            if !response.confirm {
                self.resend()
            }
        } else if let response = response as? ContinueChatResponseModel {
            
            super.addResponse(response)
            
        } else {
            
            super.addResponse(response)
            
        }
    }
    
    
    // MARK:- private stuff
    fileprivate struct Const {
        static let TotalResponseCount = 0
        static let Hello = ["Mirëdita! (Albanian)",
                            "Parev! (Armenian)",
                            "Zdravei! (Bulgarian)",
                            "Nei Ho! (Cantonese)",
                            "Dobrý den! (Czech)",
                            "Goddag! (Danish)",
                            "Shalom! (Hebrew)",
                            "Bonjour! (French)",
                            "Guten! Tag (German)",
                            "Aloha! (Hawaiian)",
                            "Namaste! (Hindi)",
                            "Jó napot (Hungarian)",
                            "Salve! (Italian)",
                            "Kon-nichiwa! (Japanese)",
                            "Ni hao! (Mandarin)",
                            "Hola! (Spanish)",
                            "Zdravstvuyte! (Russian) ",
                            "Sa-wat-dee! (Thai)",
                            "Merhaba! (Turkish)",
                            "Sholem Aleychem! (Yiddish)",
                            "Xin chào! (Vietnamese)",
                            "Bunã ziua! (Romanian)"]
    }
    
}
