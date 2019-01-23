//
//  DuplicateShape.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-08.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

class DuplicateShape : OperationSwift {
    var shapeId: String
    
    init(shapeId: String, type: String){
        self.shapeId = shapeId
        super.init(type: DUPLICATESHAPE)
    }
}
