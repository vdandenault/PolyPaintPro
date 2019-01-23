//
//  Shapes.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-14.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class ShapesSwift {
    var type : String
    var positions: [CGPoint]
    var shapeId: IdSwift
    var author: String
    
    init () {
        self.type = "error"
        self.positions = []
        self.shapeId = IdSwift(value: "error")
        self.author = "error"
    }
    init(type : String, positions: [CGPoint], id: IdSwift, author: String){
        self.positions = positions
        self.shapeId = id
        self.author = author
        self.type = type
    }
    
    init(positions: [CGPoint]){
        self.positions = positions
        self.type = "error"
        self.shapeId = IdSwift(value: "error")
        self.author = "error"
    }

    func toShape()-> shape{
        var jsonPositions : Array<PositionJSON> = []
        for position in positions {
            jsonPositions.append(PositionJSON(x: float_t(position.x), y: float_t(position.y)))
        }
        return shape(type: type, positions: jsonPositions, length: nil, width: nil, title: "", id: id(value: shapeId.value), author: author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeId.value, positionOnShape: ""))
    }
}
