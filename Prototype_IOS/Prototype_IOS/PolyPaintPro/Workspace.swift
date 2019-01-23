//
//  Workspace.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-03.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

class Workspace {
    var name: String
    var sessionID: String
    var author: String
    
    init() {
        self.name = ""
        self.sessionID = ""
        self.author = ""
    }
    init(name:String, sessionId: String, author: String) {
        self.name = name
        self.sessionID = sessionId
        self.author = author
    }
    func setSessionId(sessionId: String) {
        self.sessionID = sessionId
    }
    func leaveWorkspace() {
        Socket.shared.leaveWorkSpace()
    }
    func joinWorkspace() {
        Socket.shared.editorJoin(sessionId: self.sessionID)
    }
    
    func sendOperations(jsonDataStruct: JSONDataStruct) -> Bool {
        return Socket.shared.sendOperation(jsonDataStruct: jsonDataStruct)
    }
}
