//
//  MetaData.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 18-10-26.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

enum Protection: String, Codable {
    case none, protected, selfPrivate
}

struct MetaData {
    var author: String
    var name: String
    var protection: Bool
    var password: String
    var tags = [String]()
    var pngImage: UIImage
    var isBlurred:Bool
    var Private: Bool
    var username:String
    var id: String
    
    init() {
        self.author = ""
        self.name = ""
        self.protection = false
        self.password = ""
        tags = []
        self.pngImage = UIImage()
        self.isBlurred = false
        self.Private = false
        self.username = ""
        self.id = ""
    }

    init(author: String, name: String, protection: Bool, password: String, tags: [String], pngImage: UIImage, isBlurred: Bool, Private: Bool, username: String, id: String) {
        self.author = author
        self.name = name
        self.protection = protection
        self.password = password
        self.tags = tags
        self.pngImage = pngImage
        self.isBlurred = isBlurred
        self.Private = Private
        self.username = username
        self.id = id    
    }
}
