//
//  AddShapeSwift.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-15.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

class AddShapeSwift : OperationSwift {
    var user: String
    var shape: ShapesSwift
    
    init(shape: ShapesSwift, user: String, type : String) {
        self.shape = shape
        self.user = user
        super.init(type: type)
    }
    
    override init() {
        self.shape = ShapesSwift()
        self.user = "error"
        super.init()
    }
}

