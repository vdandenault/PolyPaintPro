//
//  Channel.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-13.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class Channel {
    var channelName:String
    
    init(){
        self.channelName = ""
    }
    init(channelName:String) {
        self.channelName = channelName
    }
    func sendMessage(message: String) -> Bool {
        return Socket.shared.sendMessage(message: message, channelName: self.channelName)
    }
    func joinchat() {
        Socket.shared.chatJoin(channelName: self.channelName)
    }
    func leaveChat() {
        Socket.shared.leaveChat(channelName: self.channelName)
    }
}
