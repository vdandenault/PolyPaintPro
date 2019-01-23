//
//  JSONStructures.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-24.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import SocketIO


struct SignUpPost: Codable {
    let name : String
    let email: String
    let username: String
    let password: String
}

struct SignInPost: Codable {
    let usernameOrEmail: String
    let password: String
    
    init(usernameOrEmail: String, password: String) {
        self.usernameOrEmail = usernameOrEmail
        self.password = password
    }
}

struct Channels: SocketData, Codable {
    let channels: [String]
    
    init (json: [String: Any])
    {
        channels = json ["channels"] as? [String] ?? [];
    }
}

struct Workspaces: SocketData, Codable {
    let sessions: [String]
    
    init (json: [String: Any])
    {
        sessions = json ["sessions"] as? [String] ?? [];
    }
}

struct SessionId: SocketData, Codable {
    let sessionId : String
    
    init (json: [String: Any])
    {
        sessionId = json ["sessionId"] as? String ?? "";
    }
}

struct LogIn : SocketData, Codable {
    var username: String
    var userId: String
    
    func socketRepresentation() -> SocketData {
        return ["username": username, "userId": userId]
    }
}

struct JoinLeaveChat : SocketData, Codable  {
    var channel: String
    func socketRepresentation() -> SocketData {
        return ["channel": channel]
    }
}

struct JoinEditor : SocketData, Codable  {
    var sessionId: String
    func socketRepresentation() -> SocketData {
        return ["sessionId": sessionId]
    }
}

struct EditorCreate : SocketData, Codable {
    var name: String
    func socketRepresentation() -> SocketData {
        return ["name": name]
    }
}

struct MessageIO : SocketData, Codable  {
    let channel: String
    let from: String
    let text: String
    
    func socketRepresentation() -> SocketData {
        return ["channel": channel, "from": from, "text": text]
    }
}

struct MessageIORecieved : Decodable {
    let channel: String
    let from: String
    let text: String
    let createdAt: String
    
    init (json: [String: Any])
    {
        channel = json ["channel"] as? String ?? "";
        from = json ["from"] as? String ?? "";
        text = json["text"] as? String ?? "";
        createdAt = json["createdAt"] as? String ?? "";
    }
}



