//
//  tailAnchorPoint.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-27.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import SocketIO

struct tailAnchorPoint: Codable, SocketData {
    
    var shapeId: String?
    var positionOnShape: String?
}
