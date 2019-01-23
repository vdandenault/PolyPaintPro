//
//  Operation.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-11.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit
import SocketIO

struct operation: Codable, SocketData{
    var type: String?
    var shape: shape?
    var user: String?
    var shapeId : String?
    
    init(type: String, shape: shape, user: String) {
        self.type = type
        self.shape = shape
        self.user = user
    }
    
    init(type: String, shapeId :String) {
        self.type = type
        self.shapeId = shapeId
    }
}


