//
//  AnchorPointSwift.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-16.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

class AnchorPointSwift {
    var shapeId: String
    var positionOnShape: float_t
    
    init(shapeId: String, positionOnShape: float_t){
        self.shapeId = shapeId
        self.positionOnShape = positionOnShape
    }
}
