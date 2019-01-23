//
//  TitledRectangle.swift
//  Prototype_IOS
//
//  Created by Kathou on 2018-11-23.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class TitledRectangleSwift : ShapesSwift {
    var title: String
    var length: CGFloat
    var width: CGFloat
    
    init(type : String, positions: [CGPoint], title: String, length: CGFloat, width: CGFloat, id: IdSwift, author: String) {
        self.title = title
        self.width = width
        self.length = length
        super.init(type: TITLEDRECTANGLE, positions: positions, id: id, author: author)
    }
    
    override func toShape()-> shape{
        var jsonPositions : Array<PositionJSON> = []
        for position in positions {
            jsonPositions.append(PositionJSON(x: float_t(position.x), y: float_t(position.y)))
        }
        return shape(type: type, positions: jsonPositions, length: float_t(length), width: float_t(width), title: title, id: id(value: shapeId.value), author: author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "")
    }
}
