//
//  ModifyShape.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-08.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

class ModifyShapeSwift : OperationSwift {
    var shape: ShapesSwift
    
    init(shape: ShapesSwift, type : String) {
        self.shape = shape
        super.init(type: type)
    }
    
    override init() {
        self.shape = ShapesSwift()
        super.init()
    }
}
