//
//  CounterAddDataModel.swift
//  MonkeyCounter
//
//  Created by AT on 5/3/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

public class CounterAddDataModel: ChatDataModel {
    
    init(withHelp: Bool) {
        super.init()
        
        if withHelp {
            self.messages.append(TextChatMessage(text: "Please provide a name for the location (for example Home or Office). It is ok to 🐝 creative!", responseType: ResponseType.None))
            
            self.messages.append(ImageChatMessage(path:"hlp_location_name",responseType: ResponseType.Text))
            
            self.messages.append(TextChatMessage(text: "Now let's add a location!", responseType: ResponseType.None))
            
            self.messages.append(ImageChatMessage(path:"hlp_location_coord",responseType: ResponseType.Location))
            
            self.messages.append(TextChatMessage(text: "Great! We are done.", responseType: ResponseType.None))
            
        } else {
            // no need to display help
            self.messages.append(TextChatMessage(text: "Please provide a name for the location (for example Home or Office). It is ok to 🐝 creative!", responseType: ResponseType.Text))
            
            self.messages.append(TextChatMessage(text: "Now let's add the location!", responseType: ResponseType.Location))
            
            self.messages.append(TextChatMessage(text: "Great! We are done.", responseType: ResponseType.None))
            
        }
    }
    
    // MARK:- private stuff
    fileprivate struct Const {
        fileprivate let TotalResponseCount = 2
    }
}
